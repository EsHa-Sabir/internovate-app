import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_colors.dart';


// Custom SnackBar
showSnackBar(String title, String message,Color color) {
  return Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    colorText: Colors.white,
  );
}
