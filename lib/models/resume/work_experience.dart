class Experience {
  String title;
  String company;
  String startDate;
  String endDate;
  String description;

  Experience({
    required this.title,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory Experience.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Experience(
        title: '',
        company: '',
        startDate: '',
        endDate: '',
        description: '',
      );
    }
    return Experience(
      title: data['title']?.toString() ?? '',
      company: data['company']?.toString() ?? '',
      startDate: data['startDate']?.toString() ?? '',
      endDate: data['endDate']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
    );
  }
  // ADD THIS FACTORY CONSTRUCTOR
  factory Experience.empty() {
    return Experience(
      title: '',
      company: '',
      startDate: '',
      endDate: '',
      description: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}
