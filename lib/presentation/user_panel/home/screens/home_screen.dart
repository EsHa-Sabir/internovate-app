import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/controllers/user/get_user_controller.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/banner_widget.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/categories_widget.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/hackathon_widgets.dart';
import 'package:intern_management_app/services/notification/onesignal_player_service.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../../controllers/notification/notification_controller.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for fetching current user data
  final GetUserController getUserController = Get.put(GetUserController());
  final notificationController = Get.put(NotificationController());




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    OneSignalPlayerService.savePlayerIdToFirestore();
    // current user ka UID pass karo
    final uid = getUserController.user.value?.userId;
    if (uid != null) {
      notificationController.listenToUnreadNotifications(uid);
    }

  }

  @override
  Widget build(BuildContext context) {
    // Scaffold key to control drawer opening
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Reactive App Bar that updates when user data changes
            Obx(() {
              // If user data is still loading or null → return empty space
              if (getUserController.user.value == null) {
                return SizedBox();
              }

              // Get user data from controller
              final user = getUserController.user.value!;

              return AppBar(
                scrolledUnderElevation: 0,
                backgroundColor: AppColors.darkBackground,
                elevation: 0,

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with username
                    Text(
                      "Salaam, ${user.username} 👋",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Subheading
                    Text(
                      "Welcome to Internee App",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),


                // 🔹 Profile Picture / Drawer Icon
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      // Open Drawer when profile avatar is tapped
                      _scaffoldKey.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,

                      // Show user profile image (from Firebase) if available
                      backgroundImage: user.imageUrl != null &&
                          user.imageUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.imageUrl!)
                          : null,

                      // If no image → show first letter of username
                      child: user.imageUrl == null || user.imageUrl!.isEmpty
                          ? Text(
                        user.username[0],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
                // 🔔 Notification Icon (Right Side)
                actions:  [
                  Obx(() {
                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 3, end: 10),
                  showBadge: notificationController.unreadCount.value > 0,
                  badgeContent: Text(
                    notificationController.unreadCount.value.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      final user = getUserController.user.value;
                      if(user != null) {
                        // Mark all as read jab user notification screen par jaye
                        notificationController.markAllAsRead(user.userId);
                        Get.toNamed("/notification");
                      }
                    },
                  ),
                );
              }),
              ],
              );
            }),

            SizedBox(height: 15),

            // 🔹 Banner Section
            BannerWidget(),

            SizedBox(height: 20),

            // 🔹 Categories Section (Internship fields)
            CategoriesWidget(),
            SizedBox(height: 20,),

            LatestHackathonsWidget()
          ],
        ),
      ),

      // 🔹 Drawer widget for navigation
      drawer: DrawerWidget(),
    );
  }
}
