import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var unreadCount = 0.obs;

  void listenToUnreadNotifications(String uid) {
    _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .where("read", isEqualTo: false) // ✅ only unread
        .snapshots()
        .listen((snapshot) {
      unreadCount.value = snapshot.docs.length;
    });
  }

  Future<void> markAllAsRead(String uid) async {
    final batch = _firestore.batch();
    final query = await _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .where("read", isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      batch.update(doc.reference, {"read": true});
    }

    await batch.commit();
  }
}
