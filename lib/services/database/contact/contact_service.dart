import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../models/contact/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Function to add contact message in Firestore
  Future<void> addContactMessage(
    String userId,
    String name,
    String email,
    String message,
  ) async {
    try {
      ContactModel contactModel = ContactModel(
        userId: userId,
        name: name,
        email: email,
        message: message,
        createdAt: Timestamp.now(),
      );
      EasyLoading.show(status: "Please Wait...");
      await _firestore.collection("contacts").add(contactModel.toJson());
      EasyLoading.dismiss();
      Future.delayed(const Duration(milliseconds: 300), () {
        showSnackBar("Success", "Your message sent successfully",AppColors.primary);
      });

      print("✅ Contact message added successfully");
    } catch (e) {
      EasyLoading.dismiss();
      print("❌ Error adding contact message: $e");
      rethrow;
    }
  }
}
