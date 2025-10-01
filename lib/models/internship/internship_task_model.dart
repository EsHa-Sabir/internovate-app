import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a single internship task
class InternshipTaskModel {
  /// Unique ID of the task (Firestore document ID)
  final String taskId;

  /// The ID of the internship this task belongs to
  final String internshipId;

  /// Title of the task
  final String title;

  /// Detailed description of the task
  final String description;

  final Timestamp createdAt;

  InternshipTaskModel({
    required this.taskId,
    required this.internshipId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  /// Factory constructor to create [InternshipTaskModel]
  /// from a Firestore JSON map and document ID
  factory InternshipTaskModel.fromJson(Map<String, dynamic> json, String docId) {
    return InternshipTaskModel(
      taskId: docId,
      internshipId: json['internshipId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt']
          : Timestamp.now(), // fallback agar null ya missing ho
    );
  }


  /// Converts the task object into a JSON map
  /// (useful for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      "internshipId": internshipId,
      "title": title,
      "description": description,
      "createdAt": createdAt,
    };
  }
}
