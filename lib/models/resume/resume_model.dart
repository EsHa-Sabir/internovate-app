import 'package:intern_management_app/models/resume/project.dart';
import 'package:intern_management_app/models/resume/work_experience.dart';

import 'certification.dart';
import 'education.dart';

class Resume {
  String name;
  String email;
  String mobile;
  String linkedin;
  String twitter;
  String summary;
  String skills;
  // ADDED NEW FIELD FOR LANGUAGES
  String languagesSpoken;
  List<Experience> workExperience;
  List<Education> education;
  List<Project> projects;
  List<Certification> certifications;

  Resume({
    required this.name,
    required this.email,
    required this.mobile,
    required this.linkedin,
    required this.twitter,
    required this.summary,
    required this.skills,
    // ADDED NEW PARAMETER TO CONSTRUCTOR
    required this.languagesSpoken,
    required this.workExperience,
    required this.education,
    required this.projects,
    required this.certifications,
  });

  factory Resume.fromMap(Map<String, dynamic> data) {
    return Resume(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      linkedin: data['linkedin'] ?? '',
      twitter: data['twitter'] ?? '',
      summary: data['summary'] ?? '',
      skills: data['skills'] ?? '',
      // ADDED THIS LINE
      languagesSpoken: data['languagesSpoken'] ?? '',
      workExperience: (data['workExperience'] as List? ?? [])
          .map((item) => Experience.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      education: (data['education'] as List? ?? [])
          .map((item) => Education.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      projects: (data['projects'] as List? ?? [])
          .map((item) => Project.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      certifications: (data['certifications'] as List? ?? [])
          .map((item) => Certification.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'linkedin': linkedin,
      'twitter': twitter,
      'summary': summary,
      'skills': skills,
      // ADDED THIS LINE
      'languagesSpoken': languagesSpoken,
      'workExperience': workExperience.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'projects': projects.map((e) => e.toMap()).toList(),
      'certifications': certifications.map((e) => e.toMap()).toList(),
    };
  }

  // Factory constructor to create an empty Resume object.
  factory Resume.empty() {
    return Resume(
      name: '',
      email: '',
      mobile: '',
      linkedin: '',
      twitter: '',
      summary: '',
      skills: '',
      // ADDED THIS LINE
      languagesSpoken: '',
      workExperience: [],
      education: [],
      projects: [],
      certifications: [],
    );
  }
}