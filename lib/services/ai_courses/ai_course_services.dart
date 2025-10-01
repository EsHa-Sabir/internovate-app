// lib/services/ai_courses/ai_course_services.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api_key.dart';
import '../../models/ai_courses/chapter_model.dart';
import '../../models/ai_courses/course_model.dart';
import 'gemini_api_client.dart';
import 'package:http/http.dart' as http;

class AICourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiApiClient _geminiClient = GeminiApiClient();

  final String _youtubeApiKey = youtubeAPIKey;

  Future<String?> searchYoutubeVideo(String query) async {
    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'snippet',
        'q': query,
        'key': _youtubeApiKey,
        'type': 'video',
        'maxResults': '1',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final videoId = data['items'][0]['id']['videoId'];
          return 'https://www.youtube.com/watch?v=$videoId';
        }
      }
    } catch (e) {
      print('YouTube search error: $e');
    }
    return null;
  }

  Stream<List<AICourse>> getMyAICourses() {
    if (_auth.currentUser == null) return const Stream.empty();
    return _firestore
        .collection('ai_courses')
        .where('creatorId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AICourse.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<AICourse> generateCourseLayout({
    required String category,
    required String topic,
    String? description,
    required String skillLevel,
    required String duration,
    required int numberOfChapters,
    required bool includesVideo,
  }) async {
    final String prompt =
    '''
    Generate a course layout.
    Category: $category
    Topic: $topic
    Description: ${description ?? 'No description provided.'}
    Skill Level: $skillLevel
    Duration: $duration
    Chapters: $numberOfChapters

    Return JSON with keys: "title", "description", "chapters".
    "chapters" should be an array of { "title": string }.
    ''';

    final aiResponse = await _geminiClient.generateLayout(prompt: prompt);
    final courseRef = _firestore.collection('ai_courses').doc();
    final newCourse = AICourse(
      id: courseRef.id,
      title: aiResponse['title'] ?? 'Untitled Course',
      category: category,
      topic: topic,
      description: aiResponse['description'] ?? 'A course on $topic.',
      skillLevel: skillLevel,
      duration: duration,
      creatorId: _auth.currentUser!.uid,
      numberOfChapters: numberOfChapters,
      includesVideo: includesVideo,
    );
    await courseRef.set(newCourse.toMap());

    if (aiResponse['chapters'] != null) {
      for (var i = 0; i < aiResponse['chapters'].length; i++) {
        var chapterData = aiResponse['chapters'][i];
        await courseRef.collection('chapters').add({
          'title': chapterData['title'] ?? 'Untitled Chapter',
          'index': i,
        });
      }
    }
    return newCourse;
  }

  Future<List<AIChapter>> generateCourseContent(String courseId) async {
    final courseSnapshot = await _firestore
        .collection('ai_courses')
        .doc(courseId)
        .get();
    if (!courseSnapshot.exists || courseSnapshot.data() == null) {
      throw Exception("Course not found");
    }

    final courseData = AICourse.fromMap(
      courseSnapshot.data()!,
      courseSnapshot.id,
    );
    final chapterLayouts = await _getChapterLayouts(courseId);

    const int maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final String prompt =
        '''
Generate a course on "${courseData.topic}" (Skill: ${courseData.skillLevel}). The total duration is ${courseData.duration}.
The course must have exactly ${courseData.numberOfChapters} chapters with these titles:
${chapterLayouts.map((e) => '- ${e['title']}').join('\n')}

**INSTRUCTIONS FOR EACH CHAPTER'S CONTENT:**
For each chapter, generate a JSON object with these keys:
1. "title": The title of the chapter.
2. "content": A detailed article in **strict Markdown format**.
   - **Headings**: Use `# Heading 1` for main titles, `## Heading 2` for sub-headings, and `### Heading 3` for smaller sub-sections.
   - **Text Styling**: Use `**text**` for **bold** text. Do not use *italic* text.
   - **Lists**: Use `* Item` or `1. Item` for lists. The app will automatically format them with bullets. Do NOT use any other bullet characters like `-`.
   - **Code Examples**: If the topic is programming, include well-commented code in fenced blocks (e.g., ```dart, ```python). If not, skip this.

**FINAL RESPONSE FORMAT:**
- Return **ONLY** a single, valid JSON object.
- The root must be a JSON object containing a "chapters" array. jitny nummber of chapter hain woh sary du yr 
- The "chapters" array MUST contain exactly ${courseData.numberOfChapters} items.
- No extra text, notes, or explanations outside the JSON.


**Example Format:**
{
  "chapters": [
    {
      "title": "Introduction to Programming",
      "content": "# What is Programming?\n\nThis is an introduction to what programming is...\n\n## Basic Concepts\n\n**Variables**: Store data.\n**Functions**: Perform tasks.\n\n### My First Code\n\n```dart\n// This is a comment\nvoid main() {\n  print('Hello, World!');\n}\n```"
    }
  ]
}
''';
        final aiResponse = await _geminiClient.generateContent(prompt: prompt);

        if (aiResponse['chapters'] == null || aiResponse['chapters'] is! List) {
          throw Exception(
            "Invalid AI response: 'chapters' array missing or not a list.",
          );
        }

        if (aiResponse['chapters'].length != courseData.numberOfChapters) {
          throw Exception(
            "Content generation failed: Number of chapters in AI response (${aiResponse['chapters'].length}) does not match course layout (${courseData.numberOfChapters}).",
          );
        }

        final chapterRefs = await _firestore
            .collection('ai_courses')
            .doc(courseId)
            .collection('chapters')
            .orderBy('index')
            .get();

        final chapterList = <AIChapter>[];

        // ⚠️ Yeh code duration ki calculation ko theek karta hai
        int totalDurationMinutes = 0;
        final durationLower = courseData.duration.toLowerCase();

        if (durationLower.contains('hour') || durationLower.contains('hr')) {
          final matches = RegExp(r'\d+').allMatches(durationLower).map((m) => int.tryParse(m.group(0)!)).whereType<int>().toList();
          if (matches.isNotEmpty) {
            final hours = matches[0];
            totalDurationMinutes = hours * 60;
          }
        } else if (durationLower.contains('min') || durationLower.contains('minute')) {
          final matches = RegExp(r'\d+').allMatches(durationLower).map((m) => int.tryParse(m.group(0)!)).whereType<int>().toList();
          if (matches.length == 1) {
            totalDurationMinutes = matches[0];
          } else if (matches.length > 1) {
            final start = matches[0];
            final end = matches[1];
            totalDurationMinutes = ((start + end) / 2).round();
          }
        }

        final chapterDuration = totalDurationMinutes > 0
            ? (totalDurationMinutes / courseData.numberOfChapters).round()
            : 0;

        await Future.wait(
          List.generate(chapterRefs.docs.length, (i) async {
            final doc = chapterRefs.docs[i];
            final chapterContent =
            aiResponse['chapters'][i] as Map<String, dynamic>;

            String? videoUrl;
            if (courseData.includesVideo) {
              final searchQuery = "${chapterContent['title']} tutorial for ${courseData.topic} ${courseData.skillLevel}";
              videoUrl = await searchYoutubeVideo(searchQuery);
            }

            await doc.reference.update({
              'content': chapterContent['content'] ?? '',
              'durationMinutes': chapterDuration,
              'videoUrl': videoUrl,
            });

            chapterList.add(
              AIChapter.fromMap({
                ...doc.data(),
                'content': chapterContent['content'] ?? '',
                'durationMinutes': chapterDuration,
                'videoUrl': videoUrl,
              }, doc.id),
            );
          }),
        );
        return chapterList;
      } catch (e) {
        print("Attempt #$attempt failed: $e");
        if (attempt == maxRetries) {
          rethrow;
        }
      }
    }
    throw Exception(
      "Failed to generate course content after $maxRetries attempts.",
    );
  }
  Future<List<Map<String, dynamic>>> _getChapterLayouts(String courseId) async {
    final snapshot = await _firestore
        .collection('ai_courses')
        .doc(courseId)
        .collection('chapters')
        .orderBy('index')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> deleteCourse(String courseId) async {
    final courseRef = _firestore.collection('ai_courses').doc(courseId);
    final chapters = await courseRef.collection('chapters').get();
    for (final doc in chapters.docs) {
      await doc.reference.delete();
    }
    await courseRef.delete();
  }

  Stream<List<AIChapter>> getChaptersForCourse(String courseId) {
    return _firestore
        .collection('ai_courses')
        .doc(courseId)
        .collection('chapters')
        .orderBy('index')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AIChapter.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

