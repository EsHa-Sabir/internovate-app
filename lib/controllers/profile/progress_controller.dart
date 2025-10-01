import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../models/internship/internship_task_model.dart';
import '../../models/internship/user_task_status_model.dart';

class ProgressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  var isLoading = true.obs;
  var hasOngoingInternship = false.obs;

  // Sirf ek map progress ke liye
  var monthlyCumulativeProgress = <String, double>{}.obs;

  var allTasks = <InternshipTaskModel>[].obs;
  var userTaskStatuses = <UserTaskStatusModel>[].obs;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _statusSubscription;

  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  @override
  void onInit() {
    super.onInit();
    _resetMaps();
    // Jab bhi data streams mein se koi update ho, progress dobara calculate ho
    everAll([allTasks, userTaskStatuses], (_) => _calculateCumulativeProgress());

    if (userId != null) {
      _listenToProgressData();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _statusSubscription?.cancel();
    super.onClose();
  }

  Future<void> _listenToProgressData() async {
    if (userId == null) return;
    try {
      isLoading.value = true;
      final applicationsSnapshot = await _firestore
          .collection('internshipApplications')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['ongoing', 'completed'])
          .orderBy('appliedAt', descending: true).limit(1).get();

      if (applicationsSnapshot.docs.isEmpty) {
        hasOngoingInternship.value = false;
        _resetMaps();
        isLoading.value = false;
        return;
      }

      hasOngoingInternship.value = true;
      final ongoingInternshipId = applicationsSnapshot.docs.first.data()['internshipId'];

      _tasksSubscription = _firestore.collection('internshipTasks').where('internshipId', isEqualTo: ongoingInternshipId)
          .snapshots().listen((snapshot) {
        allTasks.value = snapshot.docs.map((doc) => InternshipTaskModel.fromJson(doc.data(), doc.id)).toList();
      });

      _statusSubscription = _firestore.collection('userTaskStatus').where('userId', isEqualTo: userId).where('internshipId', isEqualTo: ongoingInternshipId)
          .snapshots().listen((snapshot) {
        userTaskStatuses.value = snapshot.docs.map((doc) => UserTaskStatusModel.fromJson(doc.data())).toList();
      });

      // Pehli baar data aane par loading state false karein
      once(allTasks, (_) => isLoading.value = false);

    } catch (e) {
      print("❌ Error setting up progress listeners: $e");
      _resetMaps();
      isLoading.value = false;
    }
  }

  // --- NAYI AUR BEHTAR CALCULATION LOGIC ---
  void _calculateCumulativeProgress() {
    _resetMaps();
    if (allTasks.isEmpty) return;

    int cumulativeTotal = 0;
    int cumulativeDone = 0;

    // 1 saal ke 12 mahinon ke liye loop chalayein
    for (int i = 0; i < 12; i++) {
      int month = i + 1;

      // Us mahine tak total tasks count karein
      cumulativeTotal = allTasks.where((task) => task.createdAt.toDate().month <= month).length;

      // Us mahine tak completed tasks count karein
      cumulativeDone = userTaskStatuses.where((status) =>
      status.isCompleted &&
          status.completedAt != null &&
          status.completedAt!.toDate().month <= month
      ).length;

      // Is mahine ki progress calculate karein
      final monthName = months[i];
      if (cumulativeTotal > 0) {
        monthlyCumulativeProgress[monthName] = cumulativeDone / cumulativeTotal;
      } else {
        monthlyCumulativeProgress[monthName] = 0.0;
      }
    }

    monthlyCumulativeProgress.refresh();
  }

  void _resetMaps() {
    for (var m in months) {
      monthlyCumulativeProgress[m] = 0.0;
    }
  }
}