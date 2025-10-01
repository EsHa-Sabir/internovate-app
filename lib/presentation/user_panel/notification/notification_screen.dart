import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import 'package:intern_management_app/services/notification/notification_service.dart';
import 'package:intern_management_app/models/notification/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: "Your Notifications",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.getUserNotifications(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notification_important_outlined,size: 70,),
                SizedBox(height: 20,),
                const Center(
                  child: Text("No notifications yet.",style: TextStyle(color: AppColors.hintColor,fontSize: 14),),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final formattedTime =
              DateFormat('dd MMM yyyy, hh:mm a').format(notif.timestamp.toDate());

              return ListTile(
                leading: const Icon(Icons.notifications, color: AppColors.primary),
                title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.body),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
