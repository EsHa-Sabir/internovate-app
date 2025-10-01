import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import '../../../../controllers/ai_courses/ai_course_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class CourseLayoutView extends StatelessWidget {
  final AICourseController _controller = Get.put(AICourseController());

  CourseLayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can also define a professional theme at the MaterialApp level for global consistency.
    // For this example, we'll keep the changes local.

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: "Course Layout",
        isLeading: true,
        backgroundColor: AppColors.primary,
        onLeadingPressed: (){
          Get.back();
        },

      ),
      body: Obx(() {
        if (_controller.currentCourse.value == null || _controller.currentCourseChapters.isEmpty) {
          return const Center(
            child: Text(
              'Error: Course data not found.',
              style: TextStyle(color: AppColors.hintColor, fontSize: 16),
            ),
          );
        }

        final course = _controller.currentCourse.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header Card
              Card(
                color: AppColors.cardColor,
                elevation: 6, // Increased elevation for a floating effect
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1), // Softened the background
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu_book, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: AppColors.hintColor),
                            ),
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(
                                course.category,
                                style: const TextStyle(color: AppColors.textColor, fontSize: 13),
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side:BorderSide(
                                  color: AppColors.primary.withOpacity(0.2)
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Course Details Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DetailIcon(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: course.skillLevel,
                  ),
                  DetailIcon(
                    icon: Icons.timer_sharp,
                    label: course.duration,
                  ),
                  DetailIcon(
                    icon: Icons.format_list_numbered_rounded,
                    label: '${course.numberOfChapters} Chapters',
                  ),
                  DetailIcon(
                    icon: Icons.videocam_outlined,
                    label: course.includesVideo ? 'Videos' : 'No Videos',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Generate Content Button
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _controller.generateCourseContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      elevation: 5,
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                      height: 28, // Slightly larger spinner
                      width: 28,
                      child: CircularProgressIndicator(
                        color: AppColors.textColor,

                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_fix_high, size: 24, color: AppColors.textColor),
                        SizedBox(width: 12),
                        Text(
                          'Generate Course Content',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Chapters Heading
              const Text(
                'Course Chapters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 15),

              // Chapters List with numbering
              ..._controller.currentCourseChapters.asMap().entries.map(
                    (entry) {
                  final index = entry.key + 1;
                  final chapter = entry.value;

                  return Card(
                    color: AppColors.cardColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          '$index', // Use the number as the avatar text
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        chapter.durationMinutes > 0 ? "${chapter.durationMinutes} min" : "Duration not set",
                        style: const TextStyle(color: AppColors.hintColor, fontSize: 13),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: AppColors.hintColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

class DetailIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailIcon({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hintColor.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}