import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/internship/user_internship_controller.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../home/widgets/drawer_widget.dart';
import 'certificate_screen.dart';

/// This screen shows the internships that a user has applied for.
/// Based on the status of each internship (e.g., ongoing, payment pending, completed, expired),
/// different UI is shown.
class UserInternshipScreen extends StatelessWidget {
  /// GetX controller that holds the list of user internship applications
  /// and provides helper methods like totalTasks, completedTasksSafe, progress.
  final controller = Get.find<UserInternshipController>();

  UserInternshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Top App Bar with title
      appBar: AppBar(
        title: const Text("Your Internship"),
        backgroundColor: AppColors.primary,
      ),

      /// Custom drawer widget (navigation menu on the left side)
      drawer: DrawerWidget(),

      /// Body listens to changes in controller.applications reactively using Obx
      body: Obx(() {
        /// If no internship applications are found → Show empty state
        if (controller.applications.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "No Internships available. Please apply for an internship related to your field first.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        }

        /// If internships exist → Show them in a list
        return ListView.builder(
          itemCount: controller.applications.length,
          itemBuilder: (context, index) {
            final app = controller.applications[index];

            /// Total number of tasks for this internship
            final total = controller.totalTasks(app.internshipId);

            /// Completed tasks (safe function to avoid null errors)
            final done = controller.completedTasksSafe(app.internshipId);

            /// Progress value between 0 and 1
            final progress = controller.progress(app.internshipId);

            /// Based on status of internship, show different card UI
            switch (app.status) {
            /// Case 1: Payment is still under verification
              case "payment_pending":
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      app.internshipName,
                      style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Your payment is under verification. Please wait 48 hours",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                );

            /// Case 2: Ongoing internship (show progress bar)
              case "ongoing":
                final percent = (progress * 100).toInt(); // Convert to %
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Internship title
                        Text(
                          app.internshipName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        /// Show completed vs total tasks (e.g. 2 of 5 tasks)
                        Text("$done of $total tasks"),

                        /// Progress bar + percentage
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress, // Between 0 and 1
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0
                                      ? Colors.green
                                      : AppColors.primary,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "$percent%",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: progress == 1.0
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// Button to navigate to task screen
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                /// Navigate to InternshipTaskScreen
                                /// Pass internshipId as argument
                                Get.toNamed(
                                  "/internshipTask",
                                  arguments: {
                                    "internshipId":
                                    controller.applications[index]
                                        .internshipId,
                                  },
                                );
                              },
                              child: const Text("View Tasks"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

            /// Case 3: Internship completed → Show certificate button
              case "completed":
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Row with check icon + internship name + status text
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 35),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.internshipName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$done of $total tasks • Complete",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// Button to view certificate
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Get.to(() => CertificateScreen(
                                  internshipName: app.internshipName,
                                  interneeName: app.name, // Pass the user's name here
                                ));
                              },
                              child: const Text("View Certificate"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

            /// Case 4: Internship expired → Show expired info
              case "expired":
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.block, color: Colors.red, size: 40),
                        const SizedBox(width: 7),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.internshipName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$done of $total tasks • Expired without completion",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              case "rejected":
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.block, color: Colors.red, size: 40),
                        const SizedBox(width: 7),

                        // Wrap Column with Expanded
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.internshipName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Your Application for this internship is rejected",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2, // 2 lines tak wrap hoga
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  ,
                );


            /// Default fallback (in case status is unknown)
              default:
                return const SizedBox();
            }
          },
        );
      }),
    );
  }
}
