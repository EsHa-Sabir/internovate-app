import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/models/internship/internship_application_model.dart';
import 'package:intern_management_app/services/cloudinary/cloudinary_service.dart';

class InternshipApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> applyInternship({
    required String internshipId,
    required String internshipName,
    required String categoryId,
    required String name,
    required String fatherName,
    required String phone,
    required String cnic,
    required String institute,
    required String? experience,
    required String? linkedIn,
    required String? expectation,
    required File resumeFile,
    required File receiptFile,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // ✅ Restriction: Only one pending application
    final existing = await _firestore
        .collection("internshipApplications")
        .where("userId", isEqualTo: userId)
        .where("status", whereIn: ["ongoing", "payment_pending"])
        .get();


    if (existing.docs.isNotEmpty) {
      showSnackBar("Warning", "You can apply only one internship at a time.",Colors.red);
      throw Exception("You already have a pending internship application.");
    }

    // ✅ Upload files to Cloudinary
    final resumeData =
    await _cloudinaryService.uploadImage(resumeFile, "raw"); // raw for PDF
    final receiptData =
    await _cloudinaryService.uploadImage(
        receiptFile, "image"); // image for receipt

    if (resumeData == null || receiptData == null) {
      throw Exception("File upload failed, try again.");
    }
    // ✅ Generate new doc reference first
    final docRef = _firestore.collection("internshipApplications").doc();

    InternshipApplicationModel application = InternshipApplicationModel(
      // ✅ Save Firestore generated id into model
      applicationId: docRef.id,
      userId: userId,
      internshipId: internshipId,
      internshipName: internshipName,
      categoryId: categoryId,
      status: "payment_pending",
      appliedAt: Timestamp.now(),
      internshipStartDate: null, // will be set by admin
      internshipEndDate: null, // will be set by admin
      acceptedAt: null,// will be set by admin
      name: name,
      fatherName: fatherName,
      idCardNo: cnic,
      instituteName: institute,
      phoneNumber: phone,
      experience: experience??"",
      linkedInPortfolioUrl: linkedIn??"",
      expectation: expectation??"",
      resumeUrl: resumeData["url"],
      resumePublicId: resumeData["public_id"],
      paymentReceiptUrl: receiptData["url"],
      paymentReceiptPublicId: receiptData["public_id"],
    );


    // ✅ Save to Firestore
    await docRef.set(application.toJson());
  }
}
