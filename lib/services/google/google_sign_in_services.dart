import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user/user_model.dart';
import '../database/user/firsestore_services.dart';
import '../notification/onesignal_player_service.dart';

class GoogleSignInService {

  // ✅ Step 1: Create GoogleSignIn instance to manage Google login
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ✅ Step 2: FirebaseAuth instance for authentication with Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle Google Sign-In process and return UserCredential
  Future<UserCredential?> signInWithGoogle() async {
    try {

      // 3️⃣ Initialize the Google Sign-In process (prepare)
      await _googleSignIn.initialize();

      // 4️⃣ Prompt user to select a Google account and authenticate
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      // 5️⃣ If user cancels the login (no account selected), return null
      if (googleUser == null) {
        return null;
      }

      // 6️⃣ Show loading indicator while signing in
      EasyLoading.show(status: "Please wait...");

      // 7️⃣ Get authentication tokens from Google account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 8️⃣ Create Firebase credential using the Google idToken
      // Note: accessToken is optional in this context
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 9️⃣ Sign in to Firebase using the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      // 🔟 If user is not null, save user data to Firestore
      if (user != null) {
        UserModel userModel = UserModel(
          userId: user.uid,
          username: user.displayName ?? '',
          email: user.email ?? '',
          imageUrl: user.photoURL,
          about: "",
          phone: '',
          isAdmin: false,
          token: OneSignalPlayerService.getPlayerId(),
          createdAt: Timestamp.now(),
        );

        await FireStoreServices().addUser(userModel);
      }

      // 1️⃣1️⃣ Dismiss loading indicator after process completes
      EasyLoading.dismiss();

      // 1️⃣2️⃣ Return the signed-in user credentials
      return userCredential;
    } catch (e) {
      // Handle errors by dismissing loading and logging error
      EasyLoading.dismiss();
      print("Google Sign-In Error: ${e.toString()}");
      return null;
    }
  }
}
