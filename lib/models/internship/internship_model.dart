import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing an Internship
class InternshipModel {
  /// Unique ID of the internship (Firestore document ID)
  final String internshipId;

  /// Name/title of the internship (e.g., "Frontend Developer Intern")
  final String internshipName;

  /// Detailed description of the internship
  final String internshipDescription;

  /// ID of the related internship
  final String categoryId;

  /// Name of the related internship
  final String categoryName;

  /// Duration of the internship (default = "2 months")
  final String duration;

  /// Location of the internship (default = "Remote")
  final String location;

  /// Optional internship image URL
  final String? internshipImage;

  /// Optional public ID for image in cloud storage (e.g., Cloudinary)
  final String? internshipImagePublicId;

  /// Timestamp when the internship was created
  final Timestamp? createdAt;

  InternshipModel({
    required this.internshipId,
    required this.internshipName,
    required this.internshipDescription,
    required this.categoryId,
    required this.categoryName,
    this.duration = "2 months",
    this.location = "Remote",
    this.internshipImage,
    this.internshipImagePublicId,
    this.createdAt,
  });

  /// Convert InternshipModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'internshipId': internshipId,
      'internshipName': internshipName,
      'internshipDescription': internshipDescription,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'duration': duration,
      'location': location,
      'internshipImage': internshipImage,
      'internshipImagePublicId': internshipImagePublicId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create InternshipModel from Firestore JSON
  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      internshipId: json['internshipId'] ?? '',
      internshipName: json['internshipName'] ?? '',
      internshipDescription: json['internshipDescription'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      duration: json['duration'] ?? '2 months',
      location: json['location'] ?? 'Remote',
      internshipImage: json['internshipImage'],
      internshipImagePublicId: json['internshipImagePublicId'],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] : null,
    );
  }
}
