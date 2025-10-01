import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing the status of a specific task
/// for a particular user in an internship
class UserTaskStatusModel {
  /// The unique ID of the task
  final String taskId;

  /// The ID of the internship this task belongs to
  final String internshipId;

  /// The ID of the user who is performing the task
  final String userId;

  /// (Optional) LinkedIn post URL submitted as proof of task completion
  final String? linkedInPostUrl;

  /// (Optional) GitHub repository URL submitted by the user
  final String? gitHubRepoUrl;

  /// (Optional) Deployment URL (for projects/web apps)
  final String? deploymentUrl;

  /// Whether the task has been marked as completed by the user
  bool isCompleted;

  final Timestamp? completedAt;

  UserTaskStatusModel({
    required this.taskId,
    required this.internshipId,
    required this.userId,
    this.linkedInPostUrl,
    this.gitHubRepoUrl,
    this.deploymentUrl,
    required this.isCompleted,
    required this.completedAt,
  });

  /// Factory constructor to create [UserTaskStatusModel]
  /// from a Firestore JSON map
  factory UserTaskStatusModel.fromJson(Map<String, dynamic> json) {
    return UserTaskStatusModel(
      taskId: json['taskId'] ?? '',
      internshipId: json['internshipId'] ?? '',
      userId: json['userId'] ?? '',
      linkedInPostUrl: json['linkedInPostUrl'],
      gitHubRepoUrl: json['gitHubRepoUrl'],
      deploymentUrl: json['deploymentUrl'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] ?? '',
    );
  }

  /// Converts the task status object into a JSON map
  /// (useful for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      "taskId": taskId,
      "internshipId": internshipId,
      "userId": userId,
      "linkedInPostUrl": linkedInPostUrl ?? "",
      "gitHubRepoUrl": gitHubRepoUrl ?? "",
      "deploymentUrl": deploymentUrl ?? "",
      "isCompleted": isCompleted,
      "completedAt": completedAt,
    };
  }
}
