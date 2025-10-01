import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intern_management_app/models/user/user_model.dart';
import 'package:intern_management_app/services/notification/onesignal_player_service.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import '../../common/widgets/snackbar_widget.dart';


class AuthService {
  // Step 1: FirebaseAuth instance to interact with Firebase authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // ✅ SIGNUP method: create account with email and password
  Future<String?> signUpWithEmail(
      String email,
      String password,
      String username,
      String phone,
      ) async {
    try {
      EasyLoading.show(status: "Creating account..."); // Show loading indicator

      // Step 1: Create user with email & password in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Send email verification if not verified
      if (!userCredential.user!.emailVerified) {

        await userCredential.user!.sendEmailVerification();
      }

      // Step 3: Create user model to store user details in Firestore
      UserModel userModel = UserModel(
        userId: userCredential.user!.uid,
        username: username,
        email: email,
        phone: phone,
        isAdmin: false,
        token: OneSignalPlayerService.getPlayerId(),
        createdAt: Timestamp.now(),
      );

      // Step 4: Save user data in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel.userId)
          .set(userModel.toJson());
      await _auth.signOut();

      EasyLoading.dismiss(); // Hide loading

      // ✅ Success case → return null (means no error)
      return null;

    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      // ✅ Firebase error message return
      return e.message ?? "Something went wrong!";
    } catch (e) {
      EasyLoading.dismiss();
      // ✅ Other error message return
      return e.toString();
    }
  }


  // ✅ LOGIN method: sign in with email and password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      EasyLoading.show(status: "Logging in...");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        EasyLoading.dismiss();
        return "Please verify your email before login.";
      }

      EasyLoading.dismiss();

        return "/home";
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      switch (e.code) {
        case "invalid-email":
          return "The email address is badly formatted.";
        case "user-disabled":
          return "This user account has been disabled.";
        case "user-not-found":
          return "No account found with this email.";
        case "wrong-password":
          return "Incorrect password. Please try again.";
        default:
          return "Login failed: ${e.message}";
      }
    } catch (e) {
      EasyLoading.dismiss();
      return "An error occurred during login.";
    }
  }


  // SIGNOUT method: sign out from Firebase and Google if used
  Future<void> signOut() async {
    final user = _auth.currentUser;

    if (user != null) {
      // Step 1: Check if user signed in with Google
      for (final provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          // Step 2: Sign out from Google sign-in
          await GoogleSignIn.instance.signOut();
          break; // Only one provider needed
        }
      }

      // Step 3: Sign out from Firebase Auth
      await _auth.signOut();
    }
  }

  // PASSWORD RESET: send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      EasyLoading.show(status: "Sending reset link..."); // Show loading

      // Step 1: Send reset email via Firebase
      await _auth.sendPasswordResetEmail(email: email);

      EasyLoading.dismiss();

      // Step 2: Show snackbar confirmation
      showSnackBar(
        "Password Reset Email Sent",
        "Please check your inbox to reset your password.",AppColors.primary
      );

      // Step 3: Wait few seconds to let snackbar show
      await Future.delayed(Duration(seconds: 5));

      // Step 4: Go back to previous screen
      Get.back();
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();

      String errorMessage;
      // Step 5: Handle Firebase errors for reset
      switch (e.code) {
        case "invalid-email":
          errorMessage = "The email address is badly formatted.";
          break;
      // "user-not-found" not returned here due to security reasons
        default:
          errorMessage = "Failed to send reset email: ${e.message}";
      }

      // Step 6: Show error snackbar
      showSnackBar("Error", errorMessage,Colors.red);
    } catch (e) {
      EasyLoading.dismiss();

      // Step 7: Generic error message
      showSnackBar("Error", "Something went wrong. Please try again.",Colors.red);
    }
  }

// check user
  bool isLogin(){
    final user = _auth.currentUser;
    return user!=null;
  }
}
