import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/internship/internship_application_model.dart';

class ProfileController extends GetxController {
  // ✅ Stats (Reactive variables using RxInt, UI automatic update hogi)
  var internshipsCount = 0.obs; // Total internships applied by user
  var certificatesCount = 0.obs; // Internships completed => Certificates earned
  var ongoingCount = 0.obs; // Currently ongoing internships

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Current logged-in user ka ID store karne ke liye
  String? userId;

  @override
  void onInit() {
    super.onInit();
    try {
      // 🔹 FirebaseAuth se current user ka UID lena
      userId = FirebaseAuth.instance.currentUser?.uid;

      // 🔹 Agar user logged in hai to profile stats fetch karo
      if (userId != null) {
        fetchProfileStats();
      } else {
        // 🔹 Agar user login hi nahi to snackbar show karo
        Get.snackbar("Error", "User not logged in!");
      }
    } catch (e) {
      // 🔹 Agar user UID fetch karte waqt error aaya
      Get.snackbar("Error", "Failed to get current user: $e");
    }
  }

  /// 🔹 Ye function Firestore se user ke internship applications laata hai
  /// aur unki stats (total, completed, ongoing) calculate karta hai
  Future<void> fetchProfileStats() async {
    if (userId == null) return; // Agar user null hai to function end

    try {
      // 🔹 Firestore query: internshipApplications collection se
      // sirf wo documents laa jo is userId ke hain
      final appsSnapshot = await _firestore
          .collection('internshipApplications')
          .where('userId', isEqualTo: userId)
          .get();

      // 🔹 Snapshot ke sare docs ko InternshipApplicationModel me convert karna
      final applications = appsSnapshot.docs.map((doc) {
        try {
          // doc.data() ke sath doc.id bhi pass kar rahe (docId as applicationId)
          return InternshipApplicationModel.fromJson(doc.data());
        } catch (e) {
          // Agar koi doc parse na ho paya to print kardo aur skip karo
          print("Error parsing application doc ${doc.id}: $e");
          return null;
        }
      }).whereType<InternshipApplicationModel>().toList();

      // ✅ Stats calculation:
      internshipsCount.value = applications.length; // Total applications
      certificatesCount.value =
          applications.where((app) => app.status == 'completed').length; // Completed
      ongoingCount.value =
          applications.where((app) => app.status == 'ongoing').length; // Ongoing
    } on FirebaseException catch (e) {
      // 🔹 Firestore related error (jaise collection access issue, permission error)
      Get.snackbar("Database Error", e.message ?? "Unknown Firestore error");
    } catch (e) {
      // 🔹 General error (kisi bhi aur wajah se)
      Get.snackbar("Error", "Failed to fetch profile stats: $e");
    }
  }
}
