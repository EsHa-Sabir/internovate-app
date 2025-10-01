import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing an Internship Application
class InternshipApplicationModel {
  /// Firestore Document ID (unique identifier for the application)
  final String? applicationId;

  /// Reference to the user who applied
  final String userId;

  /// Reference to the internship (id of the internship)
  final String internshipId;

  /// Internship title (stored for quick access instead of fetching again)
  final String internshipName;

  /// Internship category reference (id of category)
  final String categoryId;

  /// Application status:
  ///  "payment_pending", "verified", "completed", "expired", "rejected"
  final String status;

  /// Timestamp when user applied
  final Timestamp appliedAt;

  /// Timestamp when application got accepted (nullable)
  final Timestamp? acceptedAt;

  /// Internship start date (nullable)
  final Timestamp? internshipStartDate;

  /// Internship end date (nullable)
  final Timestamp? internshipEndDate;

  /// Resume file URL (stored on Cloudinary / Firebase)
  final String? resumeUrl;

  /// Resume file public ID (for deletion from Cloudinary)
  final String? resumePublicId;

  /// Payment receipt image/file URL
  final String? paymentReceiptUrl;

  /// Payment receipt public ID (for deletion from Cloudinary)
  final String? paymentReceiptPublicId;

  /// Applicant's personal details
  final String name;
  final String fatherName;
  final String idCardNo;
  final String instituteName;

  /// Additional information (optional fields)
  final String? experience;
  final String? linkedInPortfolioUrl;
  final String? expectation;

  /// Applicant phone number
  final String? phoneNumber;

  /// Constructor for creating a new InternshipApplicationModel instance
  InternshipApplicationModel({
    this.applicationId,
    required this.userId,
    required this.internshipId,
    required this.internshipName,
    required this.categoryId,
    required this.status,
    required this.appliedAt,
    this.acceptedAt,
    required this.internshipStartDate,
    required this.internshipEndDate,
    this.resumeUrl,
    this.resumePublicId,
    this.paymentReceiptUrl,
    this.paymentReceiptPublicId,
    required this.name,
    required this.fatherName,
    required this.idCardNo,
    required this.instituteName,
    this.experience,
    this.linkedInPortfolioUrl,
    this.expectation,
    this.phoneNumber,
  });

  /// Factory method to create a model object from Firestore JSON
  factory InternshipApplicationModel.fromJson(
      Map<String, dynamic> json) {
    return InternshipApplicationModel(
      applicationId: json["applicationId"],
      userId: json['userId'] ?? '',
      internshipId: json['internshipId'] ?? '',
      internshipName: json['internshipName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      status: json['status'] ?? 'payment_pending',
      appliedAt: json['appliedAt'],
      acceptedAt: json['acceptedAt'],
      internshipStartDate: json['internshipStartDate'],
      internshipEndDate: json['internshipEndDate'],
      resumeUrl: json['resumeUrl'],
      resumePublicId: json['resumePublicId'],
      paymentReceiptUrl: json['paymentReceiptUrl'],
      paymentReceiptPublicId: json['paymentReceiptPublicId'],
      name: json['name'] ?? '',
      fatherName: json['fatherName'] ?? '',
      idCardNo: json['idCardNo'] ?? '',
      instituteName: json['instituteName'] ?? '',
      experience: json['experience'],
      linkedInPortfolioUrl: json['linkedInPortfolioUrl'],
      expectation: json['expectation'],
      phoneNumber: json['phoneNumber'],
    );
  }

  /// Converts model object into a JSON map (to save in Firestore)
  Map<String, dynamic> toJson() {
    return {
      "applicationId": applicationId,
      "userId": userId,
      "internshipId": internshipId,
      "internshipName": internshipName,
      "categoryId": categoryId,
      "status": status,
      "appliedAt": appliedAt,
      "acceptedAt": acceptedAt,
      "internshipStartDate": internshipStartDate,
      "internshipEndDate": internshipEndDate,
      "resumeUrl": resumeUrl,
      "resumePublicId": resumePublicId,
      "paymentReceiptUrl": paymentReceiptUrl,
      "paymentReceiptPublicId": paymentReceiptPublicId,
      "name": name,
      "fatherName": fatherName,
      "idCardNo": idCardNo,
      "instituteName": instituteName,
      "experience": experience,
      "linkedInPortfolioUrl": linkedInPortfolioUrl,
      "expectation": expectation,
      "phoneNumber": phoneNumber,
    };
  }
}
