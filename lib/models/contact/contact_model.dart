import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String userId;
  final String name;
  final String email;
  final String message;
  final Timestamp createdAt;

  ContactModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "email": email,
      "message": message,
      "createdAt": createdAt,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      userId: json["userId"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      message: json["message"] ?? "",
      createdAt: json["createdAt"] ?? Timestamp.now(),
    );
  }
}
