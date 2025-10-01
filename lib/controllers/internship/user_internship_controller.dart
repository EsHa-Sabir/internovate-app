import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../common/widgets/snackbar_widget.dart';
import '../../models/internship/internship_application_model.dart';
import '../../models/internship/internship_task_model.dart';
import '../../models/internship/user_task_status_model.dart';
import '../../services/notification/notification_service.dart';
import '../../utils/constants/app_colors.dart';

class UserInternshipController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;

  /// ✅ List of internships applied by the logged-in user
  var applications = <InternshipApplicationModel>[].obs;

  /// ✅ internshipId -> List of tasks of that internship
  var tasksMap = <String, List<InternshipTaskModel>>{}.obs;

  /// ✅ internshipId -> (taskId -> UserTaskStatusModel) mapping
  var userTaskStatusMap = <String, Map<String, UserTaskStatusModel>>{}.obs;

  /// ✅ internshipId -> whether status update is already running (to prevent duplicate calls)
  var updatingStatusMap = <String, bool>{};

  @override
  void onInit() {
    super.onInit();
    // 🔑 Listen to Firebase Authentication state (login/logout changes)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // ✅ User is logged in → Save userId and fetch internships
        userId = user.uid;
        fetchAllInternships();
      } else {
        // ❌ User logged out → clear all data
        userId = null;
        applications.clear();
        tasksMap.clear();
        userTaskStatusMap.clear();
        print("User is logged out or not yet logged in");
      }
    });
  }

  /// ✅ Fetch internships in which current user has applied
  void fetchAllInternships() {
    try {
      _firestore
          .collection("internshipApplications")
          .where("userId", isEqualTo: userId) // only for logged-in user
          .orderBy("appliedAt", descending: true)
          .snapshots()
          .listen((query) {
        // 🔄 Convert Firestore documents into InternshipApplicationModel list
        applications.value = query.docs
            .map((doc) =>
            InternshipApplicationModel.fromJson(doc.data()))
            .toList();

        // ✅ For each application → fetch tasks and user’s task status
        for (var app in applications) {
          fetchTasks(app.internshipId);
          fetchUserTaskStatus(app.internshipId);
        }
      }, onError: (e) {
        print("❌ Error fetching internships: $e");
        applications.clear();
      });
    } catch (e) {
      print("❌ Exception in fetchAllInternships: $e");
    }
  }

  /// ✅ Fetch all tasks of a specific internship
  void fetchTasks(String internshipId) {
    try {
      _firestore
          .collection("internshipTasks")
          .where("internshipId", isEqualTo: internshipId)
          .snapshots()
          .listen((query) {
        final list = query.docs
            .map((doc) => InternshipTaskModel.fromJson(doc.data(), doc.id))
            .toList();



        tasksMap[internshipId] = list;
        tasksMap.refresh();
      });
    } catch (e) {
      print("❌ Exception in fetchTasks: $e");
    }
  }


  /// ✅ Fetch task completion status of the current user for a specific internship
  void fetchUserTaskStatus(String internshipId) {
    try {
      _firestore
          .collection("userTaskStatus")
          .where("internshipId", isEqualTo: internshipId)
          .where("userId", isEqualTo: userId) // only for logged-in user
          .snapshots()
          .listen((query) {
        final map = <String, UserTaskStatusModel>{};

        // 🔄 Convert Firestore docs into UserTaskStatusModel and store in map
        for (var doc in query.docs) {
          final status = UserTaskStatusModel.fromJson(doc.data());
          map[status.taskId] = status;
        }

        userTaskStatusMap[internshipId] = map;
        userTaskStatusMap.refresh();

        // 🔄 Update internship progress & status after fetching task statuses
        checkAndUpdateStatus(internshipId);
        applications.refresh();
      }, onError: (e) {
        print("❌ Error fetching user task status: $e");
      });
    } catch (e) {
      print("❌ Exception in fetchUserTaskStatus: $e");
    }
  }

  /// ✅ Check if a specific task is completed by the user
  bool isTaskCompleted(String internshipId, String taskId) {
    return userTaskStatusMap[internshipId]?[taskId]?.isCompleted ?? false;
  }

  /// ✅ Toggle task completion (submit task + URLs if provided)
  Future<void> toggleTaskCompletion(
      String internshipId,
      String taskId,
      String linkedInPostUrl,
      String gitHubRepoUrl,
      String? deploymentUrl,
      ) async {
    try {
      EasyLoading.show(status: "Please wait...");

      // 🔍 Check if task already exists
      final existing = userTaskStatusMap[internshipId]?[taskId];

      final updatedStatus = UserTaskStatusModel(
        userId: userId!,
        internshipId: internshipId,
        taskId: taskId,
        linkedInPostUrl: linkedInPostUrl,
        gitHubRepoUrl: gitHubRepoUrl,
        deploymentUrl: deploymentUrl?.isNotEmpty == true ? deploymentUrl : null,
        isCompleted: existing != null ? !existing.isCompleted : true,
        completedAt: Timestamp.now(),
      );

      // ✅ Save status in Firestore
      await _firestore
          .collection("userTaskStatus")
          .doc("${userId}_$taskId")
          .set(updatedStatus.toJson());

      // ✅ Local map me turant update karo
      userTaskStatusMap[internshipId] ??= {};
      userTaskStatusMap[internshipId]![taskId] = updatedStatus;
      userTaskStatusMap.refresh();

      // 🔄 Update internship progress
      await checkAndUpdateStatus(internshipId);
      applications.refresh();
      // Back with success result
      Get.back(result: true);

      EasyLoading.dismiss();
      showSnackBar("Success", "Task submitted successfully!", AppColors.primary);
    } catch (e) {
      EasyLoading.dismiss();
      print("❌ Error while toggling task completion: $e");
      showSnackBar("Error", "Failed to update task. Please try again.", Colors.red);
    }
    return null;
  }

  /// ✅ Count how many tasks user has completed in given internship
  int completedTasks(String internshipId) {
    final allTasks = tasksMap[internshipId] ?? [];
    final userStatus = userTaskStatusMap[internshipId] ?? {};
    return allTasks
        .where((task) => userStatus[task.taskId]?.isCompleted == true)
        .length;
  }

  /// ✅ Calculate internship progress (ratio between 0 and 1)
  double progress(String internshipId) {
    final total = tasksMap[internshipId]?.length ?? 0;
    final done = completedTasks(internshipId);
    return total == 0 ? 0 : done / total;
  }

  /// ✅ Check and update internship status automatically
  // ✅ checkAndUpdateStatus function ka updated code
  // File: lib/controllers/user/user_internship_controller.dart

  Future<void> checkAndUpdateStatus(String internshipId) async {
    // Yeh check pehle se hi maujood hai, duplicate call se bachne ke liye
    if (updatingStatusMap[internshipId] == true) return;
    updatingStatusMap[internshipId] = true;

    try {
      final appQuery = await _firestore
          .collection("internshipApplications")
          .where("userId", isEqualTo: userId)
          .where("internshipId", isEqualTo: internshipId)
          .limit(1)
          .get();

      if (appQuery.docs.isEmpty) return;

      final appDoc = appQuery.docs.first;
      final app = InternshipApplicationModel.fromJson(appDoc.data());

      final total = tasksMap[internshipId]?.length ?? 0;
      final done = completedTasks(internshipId);
      final now = DateTime.now();

      // 🎯 Sirf ek baar status update aur notification bhejein
      // Jab internship complete ho jaye
      if (total > 0 && done == total && app.status != "completed") {
        await _firestore
            .collection("internshipApplications")
            .doc(appDoc.id)
            .update({"status": "completed"});
        await _sendInternshipNotification(app, "completed");
        print("✅ Status updated → completed");
      }
      // Ya jab internship expire ho jaye
      else if (app.internshipEndDate != null &&
          now.isAfter(app.internshipEndDate!.toDate()) &&
          app.status != "expired") {
        await _firestore
            .collection("internshipApplications")
            .doc(appDoc.id)
            .update({"status": "expired"});
        await _sendInternshipNotification(app, "expired");
        print("✅ Status updated → expired");
      }
      // 🗓️ Har 5 din baad reminder bhejein
      // ✅ Yeh hai behtar logic
      else if (app.status == "ongoing") {
        final endDate = app.internshipEndDate?.toDate();
        if (endDate != null) {
          final lastReminder = (appDoc.data()["lastReminderSent"] as Timestamp?)?.toDate();
          final now = DateTime.now();

          // Agar pehla reminder hai, ya aakhri reminder ko 5 din guzar chuke hain
          // Toh hi naya reminder bhejo
          if (lastReminder == null || now.difference(lastReminder).inDays >= 5) {
            final remaining = endDate.difference(now).inDays;
            if (remaining > 0) {
              await _sendInternshipNotification(app, "ongoing", remainingDays: remaining);

              // Firestore me lastReminderSent update karo
              await _firestore
                  .collection("internshipApplications")
                  .doc(appDoc.id)
                  .update({"lastReminderSent": Timestamp.now()});

              print("✅ Internship reminder sent and date updated");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error updating status: $e");
    } finally {
      updatingStatusMap[internshipId] = false;
    }
  }
  /// helper function
  Future<void> _sendInternshipNotification(
      InternshipApplicationModel app,
      String type, {
        int? remainingDays,
      }) async {
    try {
      // get user Player ID
      final userDoc = await _firestore.collection("users").doc(app.userId).get();
      final playerId = userDoc.data()?["playerId"];
      if (playerId == null) return;

      String title;
      String body;

      if (type == "completed") {
        title = "🎉 Congratulations!";
        body = "You have completed your internship: ${app.internshipName}.";
      } else if (type == "expired") {
        title = "⚠ Internship Expired";
        body = "Your internship ${app.internshipName} has expired.";
      } else {
        title = "⏳ Internship Reminder";
        body =
        "You have $remainingDays days left to complete your internship: ${app.internshipName}.";
      }

      await NotificationService.sendPushNotification(
        uid: app.userId,
        title: title,
        body: body,
        playerId: playerId,

      );
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }

  /// ✅ Total number of tasks in internship
  int totalTasks(String internshipId) {
    return tasksMap[internshipId]?.length ?? 0;
  }

  /// ✅ Safe completed task count
  int completedTasksSafe(String internshipId) {
    return completedTasks(internshipId);
  }
}
