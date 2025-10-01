import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/certificate_screen.dart';
import '../../../../controllers/internship/user_internship_controller.dart';

// ✅ Ye widget user ke saare "Completed Internships" show karta hai.
class CompletedInternshipsWidget extends StatelessWidget {
  const CompletedInternshipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller jahan se internships data aa raha hai (GetX ke through manage ho raha hai)
    final controller = Get.find<UserInternshipController>();

    // Obx => Reactive widget. Jab bhi controller.applications update honge,
    // ye widget automatically rebuild ho jayega.
    return Obx(() {
      // ✅ Controller se applications filter kar ke sirf wahi rakhe jinka status "completed" hai
      final completed = controller.applications
          .where((app) => app.status == "completed")
          .toList();

      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          // Card ka design: dark background + rounded border
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
                // 🔹 Heading Row (Icon + Title)
                Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.green, size: 25),
                    SizedBox(width: 8),
                    Text(
                      "Completed Internships",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // 🔹 Agar completed internships empty hain
                if (completed.isEmpty)
                  const Text(
                    "No completed internships yet.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  )
                // 🔹 Agar internships available hain to unki list show karo
                else
                  ListView.builder(
                    shrinkWrap: true,
                    // Column ke andar list allow karega
                    physics: const NeverScrollableScrollPhysics(),
                    // Scroll disable, parent scroll handle karega
                    itemCount: completed.length,
                    itemBuilder: (context, index) {
                      final internship = completed[index];

                      // ✅ Har internship ke liye ek styled container banate hain
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Row(
                          children: [
                            // Left side: Internship icon (circle avatar with premium icon)
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.green,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Middle section: Internship name + certificate text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Internship ka naam
                                  Text(
                                    internship.internshipName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Certificate available text
                                  Text(
                                    "Certificate available",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right side: Download button (certificate open karne ke liye)
                            IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                              onPressed: () {
                              Get.to(()=>  CertificateScreen(internshipName: internship.internshipName, interneeName: internship.name));
                                print(
                                  "Open certificate for ${internship.internshipName}",
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
