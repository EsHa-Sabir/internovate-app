import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_management_app/services/database/user/firsestore_services.dart';

class GetUserController extends GetxController {


  // Rxn ka matlab reactive null value
  Rxn<UserModel> user = Rxn<UserModel>();

  @override
  onInit() {
    super.onInit();
    fetchUserStream();
  }

  // User fetch karne ka function
  void fetchUserStream() {
    FireStoreServices()
        .getUserStream(FirebaseAuth.instance.currentUser!.uid)
        .listen((userData) {
          user.value = userData;
        });
  }

  // update user data
  Future<void> updateUser(
    String userId,
    String username,
    String phone,
    String? imagePublicId,
    String? imageUrl,
    String about,
    String instituteName,
    String experience,

  ) async {

    await FireStoreServices().updateUserData(
      userId: userId,
      username: username,
      imageUrl: imageUrl,
      imagePublicId: imagePublicId,
      phone: phone,
      about: about,
      instituteName: instituteName,
      experience: experience,
    );

  }
}
