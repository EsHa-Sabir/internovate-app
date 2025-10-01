// lib/models/job_portal/job_model.dart

import 'package:get/get.dart';

class Job {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String jobType;
  final String postedDate;
  final String applyLink;
  final String category;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.postedDate,
    required this.applyLink,
    required this.category,
  });

  factory Job.fromMap(Map<String, dynamic> json) {
    String locationText;
    bool isRemote = json['job_is_remote'] ?? false;
    String city = json['job_city'] ?? '';
    String country = json['job_country'] ?? '';
    String jobType = json['job_employment_type'] ?? 'N/A';

    if (isRemote) {
      locationText = 'Remote';
    } else if (city.isNotEmpty && country.isNotEmpty) {
      locationText = '$city, $country';
    } else if (city.isNotEmpty) {
      locationText = city;
    } else if (country.isNotEmpty) {
      locationText = country;
    } else {
      locationText = 'N/A'; // Agar koi location nahi hai to 'N/A' dikhao
    }

    return Job(
      id: json['job_id'] ?? 'N/A',
      title: json['job_title'] ?? 'N/A',
      companyName: json['employer_name'] ?? 'N/A',
      location: locationText,
      jobType: jobType,
      postedDate: json['job_posted_at_datetime_utc'] ?? 'N/A',
      applyLink: json['job_apply_link'] ?? 'N/A',
      category: json['category'] ?? 'General',
    );
  }
}