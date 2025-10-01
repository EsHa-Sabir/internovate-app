import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing an Internship Category
/// Each internship has an ID, name, image URL, optional Cloud storage public ID, and creation timestamp
class InternshipCategoryModel {
  /// Unique ID of the internship (Firestore document ID)
  final String categoryId;

  /// Name/title of the internship (e.g., "Web Development")
  final String categoryName;

  /// URL or path of the internship image
  final String categoryImage;

  /// Optional public ID for image in cloud storage (e.g., Cloudinary)
  final String? categoryImagePublicId;

  /// Timestamp when the internship was created
  final Timestamp? createdAt;

  InternshipCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
    this.categoryImagePublicId,
    this.createdAt,
  });

  /// Convert InternshipCategoryModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryImage': categoryImage,
      'categoryImagePublicId': categoryImagePublicId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create InternshipCategoryModel from Firestore JSON
  factory InternshipCategoryModel.fromJson(Map<String, dynamic> json) {
    return InternshipCategoryModel(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryImage: json['categoryImage'] ?? '',
      categoryImagePublicId: json['categoryImagePublicId'],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] : null,
    );
  }
}
