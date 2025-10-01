class Project {
  String title;
  String summary;
  String? projectLink;

  Project({
    required this.title,
    required this.summary,
    this.projectLink,
  });

  factory Project.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Project(title: '', summary: '', projectLink: '');
    }else{
    return Project(
      title: map['title'] as String,
      summary: map['summary'] as String,
      projectLink: map['projectLink'] as String?,
    );
    }
  }
  // ADD THIS FACTORY CONSTRUCTOR
  factory Project.empty() {
    return Project(title: '', summary: '', projectLink: '');
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'projectLink': projectLink,
    };
  }
}
