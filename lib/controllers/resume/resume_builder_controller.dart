// resume_builder_controller.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/resume/resume_model.dart';
import '../../services/cloudinary/cloudinary_service.dart';
import '../../services/database/resume/resume_service.dart';

class ResumeBuilderController {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance for current user
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Firestore instance
  final ResumeService _resumeService = ResumeService(); // Custom service for generating resume (AI/logic)
  final CloudinaryService _cloudinaryService = CloudinaryService(); // Service for handling Cloudinary uploads/deletes

  /// 🔹 Fetch existing resume data from Firestore (users/{uid}/resume/data)
  Future<Resume?> fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _db.collection('users').doc(user.uid).collection('resume').doc('data');

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return Resume.fromMap(data); // Convert Firestore map into Resume model
      }
      return null;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  /// 🔹 Save/update resume data in Firestore (users/{uid}/resume/data)
  Future<void> saveUserData(Resume resumeData) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      print('User not logged in.');
      return;
    }

    final docRef = _db.collection('users').doc(user.uid).collection('resume').doc('data');
    try {
      await docRef.set(resumeData.toMap(), SetOptions(merge: true));
      // merge: true ensures existing data is not overwritten completely
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  /// 🔹 Call ResumeService to generate AI resume (string or file link etc.)
  Future<String> generateResume(Resume resumeData) async {
    return await _resumeService.generateResume(resumeData);
  }

  /// 🔹 Save generated PDF file to Cloudinary and Firestore
  Future<void> savePdfToCloudinary(String filePath) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // 1. Check if any old PDF is already stored
    final existingResume = await fetchSavedPdf();
    final existingPublicId = existingResume?['publicId'] ?? '';

    // 2. Upload new PDF to Cloudinary (resource type "raw" for non-images)
    final uploadedData = await _cloudinaryService.uploadImage(File(filePath), "raw");
    if (uploadedData == null) {
      throw Exception('Failed to upload PDF to Cloudinary.');
    }

    // 3. Delete old PDF (if exists) from Cloudinary + Firestore
    if (existingPublicId.isNotEmpty) {
      await deletePdf(existingPublicId);
    }

    // 4. Save new PDF metadata in Firestore
    final docRef = _db.collection('users').doc(user.uid).collection('resume').doc('ai_resume');
    await docRef.set({
      'url': uploadedData['url'],          // Cloudinary file URL
      'publicId': uploadedData['public_id'], // Cloudinary resource ID
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ New PDF saved to Firestore and Cloudinary.');
  }

  /// 🔹 Delete resume PDF from Cloudinary + Firestore
  Future<void> deletePdf(String publicId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    if (publicId.isNotEmpty) {
      await _cloudinaryService.deleteImageFromCloudinary(publicId, "raw");
      // "raw" = non-image file
    }

    final docRef = _db.collection('users').doc(user.uid).collection('resume').doc('ai_resume');
    await docRef.delete();

    print('🗑️ Old PDF deleted from Firestore and Cloudinary.');
  }

  /// 🔹 Fetch latest saved PDF info (url + publicId) from Firestore
  Future<Map<String, String>?> fetchSavedPdf() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _db.collection('users').doc(user.uid).collection('resume').doc('ai_resume');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return {
        'url': data?['url'] ?? '',
        'publicId': data?['publicId'] ?? '',
        'docId': docSnapshot.id,
      };
    }
    return null;
  }

  /// 🔹 Listen in real-time to saved PDF changes in Firestore
  Stream<Map<String, String>?> streamSavedPdf() {
    final User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('resume')
        .doc('ai_resume')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data();
        return {
          'url': data?['url'] ?? '',
          'publicId': data?['publicId'] ?? '',
          'docId': doc.id,
        };
      }
      return null;
    });
  }
}
