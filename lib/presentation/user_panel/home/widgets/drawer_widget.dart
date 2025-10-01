import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/services/auth/auth_services.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import '../../../../controllers/drawer/drawer_selection_controller.dart';
import '../../../../controllers/user/get_user_controller.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({super.key});

  // Controller to fetch logged-in user details
  final GetUserController getUserController = Get.put(GetUserController());

  // Controller to manage drawer menu selection state
  final DrawerSelectionController selectionController =
  Get.put(DrawerSelectionController());

  // Text color for menu items
  final Color _textColor = const Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.7, // Drawer width is 70% of screen
      child: Drawer(
        backgroundColor: AppColors.primary, // Drawer background color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
        child: ListView(
          children: [
            // ================= USER HEADER =================
            Obx(() {
              // Show nothing if user is not loaded yet
              if (getUserController.user.value == null) {
                return const SizedBox();
              }

              // Get logged-in user object
              final user = getUserController.user.value!;

              return SizedBox(
                height: Get.height * 0.24,
                child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Image + Edit Button
                      Stack(
                        children: [
                          // Profile picture (or first letter of username if no image)
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.darkBackground,
                            backgroundImage: user.imageUrl != null &&
                                user.imageUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(user.imageUrl!)
                                : null,
                            child: user.imageUrl == null ||
                                user.imageUrl!.isEmpty
                                ? Text(
                              user.username[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            )
                                : null,
                          ),

                          // Small edit icon overlay on profile picture
                          Positioned(
                            top: 50,
                            left: 56,
                            child: GestureDetector(
                              onTap: () {
                                Get.back(); // Close drawer first
                                Get.toNamed("/editProfile"); // Navigate to edit profile
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.darkBackground,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Username
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.darkBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ================= MENU ITEMS =================
            _buildSimpleMenu("Home", Icons.home, "/home"),
            _buildSimpleMenu("Profile", Icons.person, "/profile"),
            _buildSimpleMenu("Internship", Icons.work, "/userInternshipScreen"),
            _buildSimpleMenu("Job Portal", Icons.business, "/jobPortal"),
            _buildSimpleMenu("AI Resume", Icons.psychology, "/aiResumeScreen"),
            _buildSimpleMenu("AI Courses", Icons.school, "/aiCourse"),
            _buildSimpleMenu("Contact Us", Icons.contact_mail, "/contact"),
            _buildSimpleMenu("Logout", Icons.logout, "/logout"),
          ],
        ),
      ),
    );
  }

  // ================= SIMPLE MENU BUILDER =================
  Widget _buildSimpleMenu(String title, IconData icon, String route) {
    return Obx(() {
      // Check if this menu is currently selected
      bool isSelected = selectionController.selectedParent.value == title;

      return Container(
        // Highlight background if selected
        color: isSelected ? _textColor.withOpacity(0.15) : Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: _textColor, size: 20), // Menu icon
          title: Text(
            title,
            style: TextStyle(
              color: _textColor,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          onTap: () {
            if (title == "Logout") {
              // Logout process
              AuthService().signOut();
              Get.offAllNamed("/onBoarding"); // Go to onboarding screen
            } else {
              // Update selected item
              selectionController.selectParent(title);
              Get.back(); // Close drawer
              Get.toNamed(route); // Navigate to selected screen
            }
          },
        ),
      );
    });
  }
}
