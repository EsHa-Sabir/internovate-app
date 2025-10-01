// File: lib/models/hackathons/hackathon_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Hackathon {
  final String id;
  final String title;
  final String description;
  final String publicId;
  final String imageUrl;
  final Timestamp startDate;
  final Timestamp endDate;
  final String registrationLink;
  String status;

  Hackathon({
    required this.id,
    required this.title,
    required this.description,
    required this.publicId,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.registrationLink,
    required this.status,
  });

  // Firestore document se Hackathon object banata hai.
  factory Hackathon.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    Timestamp startTimestamp = data['startDate'] ?? Timestamp.now();
    Timestamp endTimestamp = data['endDate'] ?? Timestamp.now();

    final now = DateTime.now();
    String calculatedStatus;
    if (now.isAfter(endTimestamp.toDate())) {
      calculatedStatus = 'Finished';
    } else if (now.isBefore(startTimestamp.toDate())) {
      calculatedStatus = 'Register'; // ✅ 'Register' se badal kar 'Registration Open'
    } else {
      calculatedStatus = 'Live'; // 'In Progress' ki jagah 'Live'
    }

    return Hackathon(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      publicId: data['publicId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startDate: startTimestamp,
      endDate: endTimestamp,
      registrationLink: data['registrationLink'] ?? '',
      status: calculatedStatus,
    );
  }
}
