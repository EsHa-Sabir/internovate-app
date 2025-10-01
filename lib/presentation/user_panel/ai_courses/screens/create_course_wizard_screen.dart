import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import '../../../../controllers/ai_courses/ai_course_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class CreateCourseWizard extends StatefulWidget {
  const CreateCourseWizard({Key? key}) : super(key: key);

  @override
  State<CreateCourseWizard> createState() => _CreateCourseWizardState();
}

class _CreateCourseWizardState extends State<CreateCourseWizard> {
  final AICourseController _controller = Get.isRegistered<AICourseController>()
      ? Get.find<AICourseController>()
      : Get.put(AICourseController());

  int _currentStep = 0;
  String? _selectedCategory;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _difficultyLevel;
  String? _courseDuration;
  bool? _includesVideo;
  int? _chapterCount; // Badlav #1: Naya variable

  bool get _isCurrentStepValid {
    if (_currentStep == 0) {
      return _selectedCategory != null;
    } else if (_currentStep == 1) {
      return _topicController.text.trim().isNotEmpty;
    } else if (_currentStep == 2) {
      return _difficultyLevel != null &&
          _courseDuration != null &&
          _includesVideo != null &&
          _chapterCount != null; // Badlav #3: Naya variable check karein
    }
    return false;
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Category'),
      content: _buildCategoryStep(),
      isActive: _currentStep >= 0,
      state: _stepState(0),
    ),
    Step(
      title: const Text('Topic'),
      content: _buildTopicStep(),
      isActive: _currentStep >= 1,
      state: _stepState(1),
    ),
    Step(
      title: const Text('Options'),
      content: _buildOptionsStep(),
      isActive: _currentStep >= 2,
      state: _stepState(2),
    ),
  ];

  StepState _stepState(int step) {
    if (_currentStep == step) return StepState.editing;
    if (_currentStep > step) return StepState.complete;
    return StepState.indexed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: "Create Course",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: AppColors.textColor,
            onSurface: AppColors.textColor,
          ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          steps: _steps,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_isCurrentStepValid) {
              if (_currentStep == 2) {
                _generateCourseLayout();
              } else {
                setState(() => _currentStep++);
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: AppColors.textColor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: details.onStepCancel,
                      label: const Text(
                        'Previous',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  const Spacer(),
                  Obx(
                        () => ElevatedButton.icon(
                      icon: Icon(
                        _currentStep == 2
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_ios,
                        size: 18,
                        color: AppColors.textColor,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCurrentStepValid
                            ? AppColors.primaryColor
                            : AppColors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                      onPressed: !_isCurrentStepValid ||
                          _controller.isLoading.value
                          ? null
                          : details.onStepContinue,
                      label: _controller.isLoading.value
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.textColor),
                      )
                          : Text(
                        _currentStep == 2
                            ? 'Generate Layout'
                            : 'Next',
                        style:
                        const TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the course category',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CategoryCard(
              title: 'Programming',
              icon: Icons.code,
              isSelected: _selectedCategory == 'Programming',
              onTap: () => setState(() => _selectedCategory = 'Programming'),
            ),
            CategoryCard(
              title: 'Health',
              icon: Icons.favorite,
              isSelected: _selectedCategory == 'Health',
              onTap: () => setState(() => _selectedCategory = 'Health'),
            ),
            CategoryCard(
              title: 'Creative',
              icon: Icons.lightbulb,
              isSelected: _selectedCategory == 'Creative',
              onTap: () => setState(() => _selectedCategory = 'Creative'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter a topic for your course',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _topicController,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('Topic (required)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tell us more about your course (optional)',
          style: TextStyle(color: AppColors.textColor),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('Description'),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildOptionsStep() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _difficultyLevel,
          dropdownColor: AppColors.cardColor,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('Difficulty level (required)'),
          items: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
            return DropdownMenuItem(value: level, child: Text(level));
          }).toList(),
          onChanged: (value) => setState(() => _difficultyLevel = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _courseDuration,
          dropdownColor: AppColors.cardColor,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('Course duration (required)'),
          items: ['1 hour', '2 hours', 'More than 3 hours'].map((duration) {
            return DropdownMenuItem(value: duration, child: Text(duration));
          }).toList(),
          onChanged: (value) => setState(() => _courseDuration = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<bool>(
          value: _includesVideo,
          dropdownColor: AppColors.cardColor,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('Include videos? (required)'),
          items: const [
            DropdownMenuItem(value: true, child: Text('Yes')),
            DropdownMenuItem(value: false, child: Text('No')),
          ],
          onChanged: (value) => setState(() => _includesVideo = value),
        ),
        const SizedBox(height: 16),
        // Badlav #2: TextField ki jagah DropdownButtonFormField
        DropdownButtonFormField<int>(
          value: _chapterCount,
          dropdownColor: AppColors.cardColor,
          style: const TextStyle(color: AppColors.textColor),
          decoration: _inputDecoration('No of Chapters (required)'),
          items: List.generate(5, (index) => index + 1).map((count) {
            return DropdownMenuItem(value: count, child: Text(count.toString()));
          }).toList(),
          onChanged: (value) => setState(() => _chapterCount = value),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.hintColor),
      filled: true,
      fillColor: AppColors.cardColor,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _generateCourseLayout() {
    _controller.createCourseLayout(
      category: _selectedCategory!,
      topic: _topicController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      skillLevel: _difficultyLevel!,
      duration: _courseDuration!,
      numberOfChapters: _chapterCount!, // Badlav #4: Seedha variable use karein
      includesVideo: _includesVideo!,
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [AppColors.cardColor, AppColors.cardColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.grey,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 38,
                color: isSelected ? Colors.white : AppColors.textColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}