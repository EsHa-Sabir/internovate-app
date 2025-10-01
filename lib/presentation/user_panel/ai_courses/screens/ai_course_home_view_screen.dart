import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import '../../../../controllers/ai_courses/ai_course_controller.dart';
import '../../../../models/ai_courses/course_model.dart';
import '../../../../utils/constants/app_colors.dart';
import 'create_course_wizard_screen.dart';

class AICoursesHomeView extends StatelessWidget {
  final AICourseController _controller = Get.put(AICourseController());


  AICoursesHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('AI Courses'),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Professional 'Create' Floating Container
            GestureDetector(
              onTap: () => Get.to(() => const CreateCourseWizard()),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.cardColor,
                  border: Border.all(color: AppColors.primary),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 25),
                    SizedBox(width: 12),
                    Text(
                      'Create New AI Course',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Text(
              'My AI Courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor.withOpacity(0.95),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Expanded GridView
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 3,
                    ),
                  );
                }
                if (_controller.myCourses.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 120),
                        Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Create Your First AI Course',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "It looks like you haven't created any courses yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.hintColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _controller.myCourses.length,
                  itemBuilder: (context, index) {
                    final course = _controller.myCourses[index];
                    return Hero(
                      tag: course.id,
                      child: CourseCard(course: course),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
class CourseCard extends StatefulWidget {
  final AICourse course;
  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isTapped = false;
  final AICourseController _controller = Get.find();

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Delete Course?",
      titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
          fontSize: 18),
      middleText:
      "Are you sure you want to delete this course? This action cannot be undone.",
      middleTextStyle: const TextStyle(color: AppColors.hintColor),
      backgroundColor: AppColors.cardColor,
      radius: 12,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.hintColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _controller.deleteCourse(widget.course.id);
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) {
          setState(() => _isTapped = false);
          _controller.loadCourse(widget.course);
        },
        onTapCancel: () => setState(() => _isTapped = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Correctly handle both hover and tap for scale effect
          transform: Matrix4.identity()..scale(
              _isTapped ? 0.95 : (_isHovered ? 1.04 : 1.0)
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.cardColor,
            boxShadow: [
              BoxShadow(
                // Correctly handle both hover and tap for shadow effect
                color: _isTapped
                    ? AppColors.primary.withOpacity(0.8) // Jab tap ho toh zyada dark shadow
                    : _isHovered
                    ? AppColors.primary.withOpacity(0.35)
                    : Colors.black.withOpacity(0.2),
                blurRadius: _isTapped ? 10 : (_isHovered ? 18 : 10),
                offset: _isTapped ? const Offset(1, 2) : const Offset(3, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner
              Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.auto_awesome,
                            size: 30, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Obx(() {
                        bool isDeleting = _controller.deletingCourses
                            .contains(widget.course.id);
                        return GestureDetector(
                          onTap: isDeleting ? null : _confirmDelete,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            child: isDeleting
                                ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.delete,
                                size: 16, color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Flexible content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.course.category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.menu_book,
                              size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.course.numberOfChapters} Chapters',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
