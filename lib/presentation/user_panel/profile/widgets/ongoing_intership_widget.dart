import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/internship/user_internship_controller.dart';

// ✅ Ye widget user ki Ongoing Internship show karta hai
class OngoingInternshipWidget extends StatelessWidget {
  const OngoingInternshipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller jahan se internship data aata hai
    final controller = Get.find<UserInternshipController>();

    // Obx => Reactive widget. Jab bhi applications list me change hoga
    // ye widget automatically rebuild ho jayega.
    return Obx(() {
      // ✅ Applications filter karke sirf ongoing wali internships le li
      final ongoing = controller.applications
          .where((app) => app.status == "ongoing")
          .toList();

      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          // Card design: dark theme + border + rounded corners
          color: const Color(0xFF101014),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey, width: 1),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Heading Row
                Row(
                  children: const [
                    Icon(Icons.work, color: Colors.green, size: 25),
                    SizedBox(width: 8),
                    Text(
                      "Ongoing Internship",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔹 Agar koi ongoing internship nahi hai
                if (ongoing.isEmpty)
                  const Text(
                    "No ongoing internship right now.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  )
                // 🔹 Agar internships hain to unki list show karo
                else
                  Column(
                    children: ongoing.map((app) {
                      // Controller se tasks ka data
                      final totalTasks = controller.totalTasks(app.internshipId); // total tasks
                      final completedTasks = controller.completedTasksSafe(app.internshipId); // completed tasks
                      final progress = controller.progress(app.internshipId); // progress ratio (0.0 - 1.0)

                      // Internship ki remaining days nikalna
                      int remainingDays = 0;
                      if (app.internshipEndDate != null) {
                        remainingDays = app.internshipEndDate!
                            .toDate()
                            .difference(DateTime.now())
                            .inDays;
                      }

                      // ✅ Ek internship card
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Internship ka naam
                            Text(
                              app.internshipName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Progress bar (LinearProgressIndicator)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress, // percentage value
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade700,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tasks progress text
                            Text(
                              "Progress: $completedTasks / $totalTasks tasks",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            // Dates info
                            if (app.internshipStartDate != null)
                              Text(
                                "Start: ${app.internshipStartDate!.toDate().toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            if (remainingDays > 0)
                              Text(
                                "Remaining Days: $remainingDays",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
