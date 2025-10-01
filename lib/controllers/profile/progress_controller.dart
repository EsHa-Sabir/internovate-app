import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../models/internship/user_task_status_model.dart';
import '../../models/internship/internship_application_model.dart';

class ProgressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  var monthlyProgress = <String, double>{}.obs;
  var monthlyTotalTasks = <String, int>{}.obs;
  var monthlyDoneTasks = <String, int>{}.obs;

  final List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchMonthlyProgress();
      } else {
        _resetMaps();
      }
    });
  }

  void fetchMonthlyProgress() async {
    if (userId == null) {
      _resetMaps();
      return;
    }

    try {
      final applicationsSnapshot = await _firestore
          .collection('internshipApplications')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'ongoing')
          .limit(1)
          .get();

      if (applicationsSnapshot.docs.isEmpty) {
        _resetMaps();
        return;
      }

      final ongoingInternshipId = applicationsSnapshot.docs.first.data()['internshipId'] as String;

      final tasksQuery = _firestore
          .collection('internshipTasks')
          .where('internshipId', isEqualTo: ongoingInternshipId);

      final userStatusQuery = _firestore
          .collection('userTaskStatus')
          .where('userId', isEqualTo: userId)
          .where('internshipId', isEqualTo: ongoingInternshipId);

      tasksQuery.snapshots().listen((tasksSnapshot) {
        userStatusQuery.snapshots().listen((userStatusSnapshot) {
          _resetMaps();

          for (var doc in tasksSnapshot.docs) {
            final taskData = doc.data();
            // ✅ Yahan null check lagaya gaya hai
            final createdAt = (taskData['createdAt'] as Timestamp? ?? Timestamp.now()).toDate();
            final monthName = months[createdAt.month - 1];
            monthlyTotalTasks[monthName] = (monthlyTotalTasks[monthName] ?? 0) + 1;
          }

          for (var doc in userStatusSnapshot.docs) {
            final taskStatus = doc.data();
            if (taskStatus['isCompleted'] == true && taskStatus['completedAt'] != null) {
              final completedAt = (taskStatus['completedAt'] as Timestamp).toDate();
              final monthName = months[completedAt.month - 1];
              monthlyDoneTasks[monthName] = (monthlyDoneTasks[monthName] ?? 0) + 1;
            }
          }

          for (var m in months) {
            final total = monthlyTotalTasks[m] ?? 0;
            final done = monthlyDoneTasks[m] ?? 0;
            monthlyProgress[m] = total > 0 ? (done / total) : 0.0;
          }

          monthlyProgress.refresh();
        });
      });
    } catch (e) {
      print("❌ Error fetching monthly progress: $e");
      _resetMaps();
    }
  }

  void _resetMaps() {
    monthlyProgress.clear();
    monthlyTotalTasks.clear();
    monthlyDoneTasks.clear();
    for (var m in months) {
      monthlyProgress[m] = 0.0;
      monthlyTotalTasks[m] = 0;
      monthlyDoneTasks[m] = 0;
    }
  }
}