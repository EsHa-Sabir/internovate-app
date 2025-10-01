class Education {
  String title;
  String university;
  String startDate;
  String endDate;
  String description;

  Education({
    required this.title,
    required this.university,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory Education.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Education(
        title: '',
        university: '',
        startDate: '',
        endDate: '',
        description: '',
      );
    }
    return Education(
      title: data['title']?.toString() ?? '',
      university: data['university']?.toString() ?? '',
      startDate: data['startDate']?.toString() ?? '',
      endDate: data['endDate']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
    );
  }
  // ADD THIS FACTORY CONSTRUCTOR
  factory Education.empty() {
    return Education(
      title: '',
      university: '',
      startDate: '',
      endDate: '',
      description: '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'university': university,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}
