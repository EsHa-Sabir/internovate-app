import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String bannerId;
  final String bannerImage;   // image url
  final String bannerPublicId; // agar cloudinary/public id use kar rahe ho
  final String title;
  final String description;
  final Timestamp createdAt;

  BannerModel({
    required this.bannerId,
    required this.bannerImage,
    required this.bannerPublicId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  // 🔹 Convert Firestore document → Model
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerId: json["bannerId"],
      bannerImage: json['bannerImage'] ?? "",
      bannerPublicId: json['bannerPublicId'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  // 🔹 Convert Model → Firestore document
  Map<String, dynamic> toJson() {
    return {
      "bannerImage": bannerImage,
      "bannerPublicId": bannerPublicId,
      "title": title,
      "description": description,
      "createdAt": createdAt,
    };
  }
}
