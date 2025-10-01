import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalPlayerService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Get Player ID from OneSignal (new SDK v4+)
  static String? getPlayerId() {
    try {
      var subscription = OneSignal.User.pushSubscription;
      return subscription.id; // This is the Player ID
    } catch (e) {
      print("❌ Error getting Player ID: $e");
      return null;
    }
  }

  /// ✅ Save Player ID to Firestore
  static Future<void> savePlayerIdToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final playerId = await getPlayerId();
    if (playerId == null) return;

    await _firestore.collection("users").doc(user.uid).set(
      {"playerId": playerId},
      SetOptions(merge: true),
    );

    print("✅ Player ID saved to Firestore: $playerId");
  }

  /// ✅ Fetch Player ID from Firestore (for current user)
  static Future<String?> fetchPlayerIdFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection("users").doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data()?["playerId"];
  }

  /// ✅ Fetch Player ID of ANY user (by UID)
  static Future<String?> fetchPlayerIdByUid(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (!doc.exists) return null;

    return doc.data()?["playerId"];
  }
}
