

class AIChapter {
  String id;
  String title;
  String content;
  int durationMinutes;
  String? videoUrl;

  AIChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.durationMinutes,
    this.videoUrl,
  });

  bool get hasContent => content.isNotEmpty;

  factory AIChapter.fromMap(Map<String, dynamic> data, String id) {
    return AIChapter(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      videoUrl: data['videoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'durationMinutes': durationMinutes,
      'videoUrl': videoUrl,
    };
  }
}