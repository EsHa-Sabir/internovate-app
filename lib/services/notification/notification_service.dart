// lib/services/notification_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intern_management_app/api_key.dart';
import '../../models/notification/notification_model.dart';



class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Save notification to Firestore
  static Future<void> saveNotificationToFirestore({
    required String uid,
    required String title,
    required String body,
  }) async {
    final docRef = _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .doc(); // ✅ Firestore auto ID banata hai

    final notification = AppNotification(
      id: docRef.id, // ✅ yahan Firestore ka generated ID dal do
      title: title,
      body: body,
      read: false,
      timestamp: Timestamp.now(),
    );

    await docRef.set(notification.toMap());
  }

  /// ✅ Send push notification using OneSignal REST API
  static Future<void> sendPushNotification({
    required String uid,
    required String title,
    required String body,
    required String playerId
  }) async {


    const String restApiKey = oneSignalRestAPIKey;

    var url = Uri.parse("https://onesignal.com/api/v1/notifications");
    var headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Basic $restApiKey"
    };

    var bodyData = jsonEncode({
      "app_id": oneSignalAppId,
      "include_player_ids": [playerId],
      "headings": {"en": title},
      "contents": {"en": body},
    });

    final response = await http.post(url, headers: headers, body: bodyData);

    if (response.statusCode == 200) {
      await saveNotificationToFirestore(uid: uid, title: title, body: body);
    } else {
      print("❌ Failed to send push notification: ${response.body}");
    }
  }

  /// ✅ Fetch user notifications
  static Stream<List<AppNotification>> getUserNotifications(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
