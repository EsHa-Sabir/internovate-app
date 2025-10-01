import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/controllers/profile/profile_controller.dart';

import '../../../../controllers/user/get_user_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class ProfileHeaderWidget extends StatelessWidget {
  // GetX controllers inject kiye ja rahe hain
  // GetUserController -> user ka data (name, email, image, etc.)
  final GetUserController getUserController = Get.put(GetUserController());

  // ProfileController -> user ke stats (internships count, certificates, ongoing, etc.)
  final ProfileController profileController = Get.put(ProfileController());

  ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx -> reactive widget, agar controller ki value change ho to UI update ho jata hai
    return Obx(() {
      // Agar user data abhi load nahi hua to empty space show kare
      if (getUserController.user.value == null) {
        return const SizedBox();
      }

      // User ka data get karna (already observable hai)
      final user = getUserController.user.value!;

      return Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xff1E1E1E),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 4),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            // ========== Avatar + Name + Email + Edit Button ==========
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture (agar image available hai to show karo warna initials)
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user.imageUrl != null &&
                      user.imageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(user.imageUrl!)
                      : null,
                  child: user.imageUrl == null || user.imageUrl!.isEmpty
                      ? Text(
                    user.username[0].toUpperCase(), // pehla letter naam ka
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 16),

                // Name + Email + Edit Profile Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis, // agar lamba email ho
                      ),
                      const SizedBox(height: 6),

                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.toNamed("/editProfile"); // edit profile page par le jao
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size
                              .zero, // button ka size content ke mutabiq ho
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // ========== Stats Row (Internships, Certificates, Ongoing) ==========
            Container(
              padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xff2E2E2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Obx(() {
                // Profile stats dynamically reactive hain
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Internships",
                        "${profileController.internshipsCount}"),
                    _buildDivider(),
                    _buildStatItem("Certificates",
                        "${profileController.certificatesCount}"),
                    _buildDivider(),
                    _buildStatItem("Ongoing",
                        "${profileController.ongoingCount}"),
                  ],
                );
              }),
            ),

            const SizedBox(height: 20),

            // ========== About Section ==========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff2E2E2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Title
                  const Text(
                    "About",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // About Description (agar user ne kuch likha hai to show karo warna placeholder text)
                  Text(
                    user.about != null && user.about!.isNotEmpty
                        ? user.about!
                        : "No bio information provided",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper function -> ek stat item (value + title) banata hai
  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  // Helper function -> Stats ke beech ek divider line
  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
    );
  }
}
