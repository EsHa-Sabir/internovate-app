class Certification {
  String title;
  String organization;
  String link;
  String date;

  Certification({
    required this.title,
    required this.organization,
    required this.link,
    required this.date,
  });


  // ADD THIS FACTORY CONSTRUCTOR
  factory Certification.empty() {
    return Certification(
      title: '',
      organization: '',
      link: '',
      date: '',
    );
  }

  factory Certification.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Certification(
        title: '',
        organization: '',
        link: '',
        date: '',
      );
    }
    return Certification(
      title: data['title']?.toString() ?? '',
      organization: data['organization']?.toString() ?? '',
      link: data['link']?.toString() ?? '',
      date: data['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organization': organization,
      'link': link,
      'date': date,
    };
  }
}
