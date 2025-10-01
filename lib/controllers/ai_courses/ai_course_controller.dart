// lib/controllers/ai_courses/ai_course_controller.dart

import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import '../../models/ai_courses/chapter_model.dart';
import '../../models/ai_courses/course_model.dart';
import '../../services/ai_courses/ai_course_services.dart';
import 'package:flutter/material.dart';

class AICourseController extends GetxController {
  final AICourseService _service = AICourseService();
  final RxList<AICourse> myCourses = <AICourse>[].obs;
  final Rx<AICourse?> currentCourse = Rx<AICourse?>(null);
  final RxList<AIChapter> currentCourseChapters = <AIChapter>[].obs;

  final RxBool isLoading = false.obs;
  final RxSet<String> deletingCourses = <String>{}.obs;
  final RxInt currentChapterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _service.getMyAICourses().listen((courses) {
      myCourses.value = courses;
    });
  }

  void loadCourse(AICourse course) async {
    currentCourse.value = course;
    final chapters = await _service.getChaptersForCourse(course.id).first;
    currentCourseChapters.value = chapters;

    if (chapters.any((chapter) => chapter.hasContent)) {
      // ✅ CourseLayoutView par jane se pehle agar content hai to FinalCourseView par navigate karein
      // Get.toNamed() yahan sahi hai kyunki yeh pehli navigation hai is flow ki.
      Get.offNamedUntil('/ai_final_course', (route) => route.settings.name == '/aiCourse');

    } else {
      // ✅ Agar content nahi hai to CourseLayoutView par navigate karein.
      Get.offNamedUntil('/ai_course_layout', (route) => route.settings.name == '/aiCourse');

    }
  }

  Future<void> createCourseLayout({
    required String category,
    required String topic,
    String? description,
    required String skillLevel,
    required String duration,
    required int numberOfChapters,
    required bool includesVideo,
  }) async {
    try {
      isLoading.value = true;
      final newCourse = await _service.generateCourseLayout(
        category: category,
        topic: topic,
        description: description,
        skillLevel: skillLevel,
        duration: duration,
        numberOfChapters: numberOfChapters,
        includesVideo: includesVideo,
      );
      loadCourse(newCourse);
    } catch (e) {
      print(e);
      showSnackBar("Error", "Failed to generate course layout. Please try again.", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateCourseContent() async {
    if (currentCourse.value == null) {
      showSnackBar("Error", "No course selected.", Colors.red);
      return;
    }
    try {
      isLoading.value = true;
      final updatedChapters = await _service.generateCourseContent(currentCourse.value!.id);
      currentCourseChapters.value = updatedChapters;
      showSnackBar("Success", "Course content generated successfully!", Colors.green);

      Get.offNamedUntil('/ai_final_course', (route) => route.settings.name == '/aiCourse');

    } catch (e) {
      print("Error generating course content: $e");
      showSnackBar("Error", "Failed to generate course content. Please try again. ", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      deletingCourses.add(courseId);
      await _service.deleteCourse(courseId);
      myCourses.removeWhere((course) => course.id == courseId);
      showSnackBar("Success", "Course deleted successfully!", Colors.green);
    } catch (e) {
      showSnackBar("Error", "Failed to delete course. $e", Colors.red);
    } finally {
      deletingCourses.remove(courseId);
    }
  }

  void selectChapter(int index) {
    if (index >= 0 && index < currentCourseChapters.length) {
      currentChapterIndex.value = index;
    }
  }
}