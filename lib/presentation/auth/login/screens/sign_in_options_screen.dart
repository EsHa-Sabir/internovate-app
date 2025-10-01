import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/utils/constants/app_images.dart';
import '../../../../services/google/google_sign_in_services.dart';
import '../../../../utils/constants/app_colors.dart';

class SignInOptionsScreen extends StatelessWidget {
  const SignInOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.07),

            // App logo image
            SizedBox(height: Get.height * 0.4, child: Image.asset(appLogo)),

            // Welcome message text
            Text(
              "Welcome to Internovate",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),

            // Subtitle description
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Text(
                "Turning learners into professionals, one internship at a time.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: Get.height * 0.1),

            // Sign-in buttons
            Column(
              children: [
                // Google Sign-In button
                SizedBox(
                  height: Get.height * 0.06,
                  width: Get.width * 0.8,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Attempt Google sign-in
                      final userCredential = await GoogleSignInService().signInWithGoogle();

                      // If sign-in successful
                      if (userCredential != null) {
                        Get.offAllNamed("/home");                 // Navigate to home screen
                        showSnackBar("Sign In Successful", "Welcome",AppColors.primary);
                      } else {
                        // If sign-in failed or cancelled
                        showSnackBar("Sign In Failed", "Please Try Again",Colors.red);
                      }
                    },
                    label: Text("Sign in with Google"),
                    icon: Brand(Brands.google),                   // Google icon
                  ),
                ),

                SizedBox(height: Get.height * 0.03),

                // Email sign-in button
                SizedBox(
                  height: Get.height * 0.06,
                  width: Get.width * 0.8,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed("/signIn");                       // Navigate to email sign-in screen
                    },
                    label: Text("Sign in with email"),
                    icon: Icon(Icons.email, size: 26),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
