// lib/common/widgets/app_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final bool isLeading;
  final VoidCallback? onLeadingPressed; // ✅ Naya parameter

  const AppBarWidget({
    super.key,
    required this.title,
    this.backgroundColor,
    required this.isLeading,
    this.onLeadingPressed, // ✅ Parameter ko initialize karein
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(title, style: const TextStyle(fontSize: 19)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? Colors.transparent,

      leading: isLeading
          ? IconButton(
        onPressed: () {
          // ✅ onLeadingPressed callback ko call karein
          if (onLeadingPressed != null) {
            onLeadingPressed!();
          } else {
            Get.back();
          }
        },
        icon: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 15,
            color: Colors.white,
          ),
        ),
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}