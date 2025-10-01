import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../../controllers/internship/user_internship_controller.dart';

/// This screen displays the list of tasks assigned to a user
/// for a specific internship. The user can view task details
/// and submit their work.
class InternshipTaskScreen extends StatefulWidget {
  InternshipTaskScreen({super.key});

  @override
  State<InternshipTaskScreen> createState() => _InternshipTaskScreenState();
}

class _InternshipTaskScreenState extends State<InternshipTaskScreen> {
  /// Controller that manages internship applications and tasks
  final controller = Get.find<UserInternshipController>();

  /// Internship ID passed as argument from previous screen
  String internshipId = Get.arguments["internshipId"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Custom App Bar (reusable widget)
      appBar: AppBarWidget(
        title: "Your Task",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),

      /// Reactive body → updates automatically whenever controller data changes
      body: Obx(() {
        /// Fetch tasks for this internship from the controller's map
        final tasks = controller.tasksMap[internshipId] ?? [];

        /// Case 1: No tasks assigned yet
        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              "No tasks assigned yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        /// Case 2: Tasks exist → Show list of tasks
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            /// Check if this task is already completed by the user
            final isCompleted = controller.isTaskCompleted(
              internshipId,
              task.taskId,
            );

            /// Card for each task
            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Task title
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),

                    /// Task status text (Completed / Assigned)
                    Text("Status: ${isCompleted ? "Completed" : "Assigned"}"),
                    const SizedBox(height: 10),

                    /// Divider line
                    const SizedBox(
                      width: double.infinity,
                      child: Divider(color: Colors.grey),
                    ),

                    /// If task is completed → Show green check icon
                    isCompleted
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 28),
                      ],
                    )

                    /// If task is not completed → Show actions
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /// Button to view task description in dialog
                        TextButton(
                          onPressed: () {
                            dialogBox(task.title, task.description);
                          },
                          child: Text(
                            "View Description",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        /// Button to submit task → navigates to SubmitTask screen
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Get.toNamed(
                              "/submitTask",
                              arguments: {
                                "internshipId": internshipId,
                                "taskId": task.taskId,
                              },
                            );

                            // 👇 Agar result true aaya, to screen ko dobara build karao
                            if (result == true) {
                              setState(() {}); // Force rebuild to reflect new status
                            }
                          },
                          child: const Text("Submit Task"),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// A simple dialog box to show task details (title + description)
  dialogBox(String title, String description) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(description),
        ),
        actions: [
          /// Close button for dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: AppColors.primary),
            ),
          )
        ],
      ),
    );
  }
}
