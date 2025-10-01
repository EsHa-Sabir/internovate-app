// fire_store_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_management_app/models/user/user_model.dart';

/// Service class to handle Firestore operations for `UserModel`
class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new user to Firestore
  /// - Creates a document in the `users` collection with the user's ID
  /// - Converts the `UserModel` to JSON before storing
  Future<void> addUser(UserModel userModel) async {
    await _firestore
        .collection("users")
        .doc(userModel.userId)
        .set(userModel.toJson());
  }



  /// Get real-time updates of a user using `snapshots()`
  /// - Returns a `Stream<UserModel>` which updates automatically on data changes
  Stream<UserModel> getUserStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((doc) => UserModel.fromJson(doc.data()!));
  }

  /// Update user data in Firestore
  /// - Only updates the fields provided (null values are ignored)
  /// - `updateData` map is built dynamically based on non-null inputs
  Future<void> updateUserData({
    required String userId,
    String? username,
    String? phone,
    String? imageUrl,
    String? imagePublicId,
    String? about,
    String? instituteName,
    String? experience,
  }) async {
    Map<String, dynamic> updateData = {};

    // Only add fields that are not null
    if (username != null) updateData['username'] = username;
    if (phone != null) updateData['phone'] = phone;
    if (imageUrl != null) updateData['imageUrl'] = imageUrl;
    if (imagePublicId != null) updateData['imagePublicId'] = imagePublicId;
    if (about != null) updateData['about'] = about;
    if (instituteName != null) updateData['instituteName'] = instituteName;
    if (experience != null) updateData['experience'] = experience;

    // Update the Firestore document
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(updateData);
  }
}
