import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? imageUrl;
  final String phone;
  final String? about;
  final String? instituteName;
  final String? experience;
  final bool isAdmin;
  final String? imagePublicId;
  String? token;
  final Timestamp createdAt;

  // Constructor
  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.imageUrl,
    this.instituteName,
    this.experience,
    required this.phone,
    this.about,
    required this.isAdmin,
    this.imagePublicId,
    this.token,
    required this.createdAt,

  });

  // Convert to JSON (Map) for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'phone': phone,
      'about': about,
      'instituteName': instituteName,
      'experience': experience,
      'isAdmin': isAdmin,
      'imagePublicId': imagePublicId,
      'token': token,
      'createdAt': createdAt,
    };
  }

  // Create object from JSON (Map) from Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      instituteName: json['instituteName'],
      experience: json['experience'],
      phone: json['phone'] ?? '',
      about: json['about'],
      isAdmin: json['isAdmin'] ?? false,
      imagePublicId: json['imagePublicId'],
      token: json['token'],
      createdAt:json["createdAt"],
    );
  }
}
