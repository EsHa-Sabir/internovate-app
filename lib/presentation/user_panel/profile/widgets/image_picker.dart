import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';



// pick Image From gallery
Future<File?> pickImage() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Only images
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return null; // User cancelled picking
    }

    File file = File(result.files.single.path!);
    int fileSize = await file.length(); // Size in bytes

    if (fileSize > 500 * 1024) {
      // More than 500 KB
      showSnackBar(
        "File size exceeds 500 KB",
        "Please choose an image under 500KB.",Colors.red
      );
      return null;
    }

    return file; // Valid image
  } catch (e) {
    print("Error picking image: $e");
    return null;
  }
}
