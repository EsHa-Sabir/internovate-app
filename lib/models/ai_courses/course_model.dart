
class AICourse {
  String id;
  String title;
  String category;
  String topic;
  String description;
  String skillLevel;
  String duration;
  String creatorId;
  int numberOfChapters;
  bool includesVideo;

  AICourse({
    required this.id,
    required this.title,
    required this.category,
    required this.topic,
    required this.description,
    required this.skillLevel,
    required this.duration,
    required this.creatorId,
    required this.numberOfChapters,
    required this.includesVideo,
  });

  factory AICourse.fromMap(Map<String, dynamic> data, String id) {
    return AICourse(
      id: id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      topic: data['topic'] ?? '',
      description: data['description'] ?? '',
      skillLevel: data['skillLevel'] ?? '',
      duration: data['duration'] ?? '',
      creatorId: data['creatorId'] ?? '',
      numberOfChapters: data['numberOfChapters'] ?? 0,
      includesVideo: data['includesVideo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'topic': topic,
      'description': description,
      'skillLevel': skillLevel,
      'duration': duration,
      'creatorId': creatorId,
      'numberOfChapters': numberOfChapters,
      'includesVideo': includesVideo,
    };
  }
}