import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';

import 'package:intern_management_app/presentation/user_panel/resume/screens/pdf_preview_screen.dart';

import 'package:intl/intl.dart';

import 'package:intern_management_app/utils/constants/app_colors.dart';

import 'package:intern_management_app/models/resume/project.dart';

import 'package:intern_management_app/models/resume/work_experience.dart';

import 'package:intern_management_app/models/resume/education.dart';

import 'package:intern_management_app/models/resume/certification.dart';

import 'package:intern_management_app/controllers/resume/resume_builder_controller.dart';

import 'package:intern_management_app/models/resume/resume_model.dart';


class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  _ResumeBuilderScreenState createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
// 🔹 Step 1: Form key for validation
  final _formKey = GlobalKey<FormState>();

  // 🔹 Step 2: Controller jo AI resume build aur save karne ka kaam karega
  final _controller = ResumeBuilderController();

  // 🔹 Step 3: Text controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  // 🔹 Step 4: Skills ko store karne ke liye controller + list
  final _skillsController = TextEditingController();
  final List<dynamic> _skills = [];

  // 🔹 Step 5: Languages ko store karne ke liye controller + list
  final TextEditingController _languagesController = TextEditingController();
  final List<dynamic> _languages = [];

  // 🔹 Step 6: Resume ke alag-alag sections ke liye empty lists
  List<Experience> _workExperience = [];
  List<Education> _education = [];
  List<Project> _projects = [];
  List<Certification> _certifications = [];

  // 🔹 Step 7: Loading state aur scroll controller
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _workExperience.clear();
    _education.clear();
    _projects.clear();
    _certifications.clear();
    _skills.clear();
    _languages.clear();

  }

  // 🔹 Step 8: Existing user data ko load karne ke liye method
  void _fetchUserData() async {
    final resumeData = await _controller.fetchUserData();

    if (resumeData != null) {
      setState(() {
        // Text fields ko fill karna
        _nameController.text = resumeData.name;
        _emailController.text = resumeData.email;
        _mobileController.text = resumeData.mobile;
        _linkedinController.text = resumeData.linkedin;
        _twitterController.text = resumeData.twitter;
        _summaryController.text = resumeData.summary;

        // Skills list set karna (string → list)
        _skills.clear();
        if ((resumeData.skills ?? '').isNotEmpty) {
          _skills.addAll(resumeData.skills.split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty));
        }

        // Languages list set karna (string → list)
        _languages.clear();
        if ((resumeData.languagesSpoken ?? '').isNotEmpty) {
          _languages.addAll(
              resumeData.languagesSpoken.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
        }

        // Baaki lists ko update karna
        _workExperience = resumeData.workExperience;
        _education = resumeData.education;
        _projects = resumeData.projects;
        _certifications = resumeData.certifications;
      });
    }
  }


  void _buildResume() async {
    if (!_formKey.currentState!.validate()) {
     showSnackBar("Error", "Please fill required fields",Colors.red);

      return;
    }
    // Skills and Languages ko mandatory karne ke liye check
    if (_skills.isEmpty) {
      showSnackBar("Error", "Please add at least one skill.",Colors.red);
      return;
    }

    if (_languages.isEmpty) {
      showSnackBar("Error", "Please add at least one language.",Colors.red);
      return;
    }
    // ✨ Manual check for required date fields
    for (var exp in _workExperience) {
      if (exp.startDate.isEmpty || exp.endDate.isEmpty) {
        showSnackBar("Error", "Work experience dates are required.",Colors.red);
        return;
      }
    }

    for (var edu in _education) {
      if (edu.startDate.isEmpty || edu.endDate.isEmpty) {
        showSnackBar("Error", "Education dates are required.",Colors.red);
        return;
      }
    }

    setState(() => _isLoading = true);

    final resumeData = _collectResumeData();

    try {
      await _controller.saveUserData(resumeData);

      final generatedText = await _controller.generateResume(resumeData);
      print('Raw AI generated text: \n$generatedText');

      final aiResumeData = _parseGeneratedText(generatedText);
      _mobileController.clear();
      _linkedinController.clear();
      _twitterController.clear();
      _summaryController.clear();
      _skillsController.clear();
      _languagesController.clear();
      _workExperience.clear();
      _education.clear();
      _projects.clear();
      _certifications.clear();
      _skills.clear();
      _languages.clear();
      _nameController.clear();
      _emailController.clear();

      if (mounted) {
        Get.to(()=>PdfViewScreen(resumeData: aiResumeData));
        Get.offUntil(
          MaterialPageRoute(builder: (context)=>PdfViewScreen(resumeData: aiResumeData)),
              (route) => route.settings.name == '/aiResumeScreen',
        );


      }
    } catch (e) {
      showSnackBar("Error ", "Failed to generate resume",Colors.red);

      print(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // resume_builder_controller.dart
// ... (existing imports)

  Resume _parseGeneratedText(String generatedText) {


    try {
      // Trim extra spaces and try to find the JSON object.
      final jsonString = generatedText.trim();
      final Map<String, dynamic> data = json.decode(jsonString);

      // Create a new Resume object from the JSON data.
      final resume = Resume.fromMap(data);
      print('Successfully parsed resume data: ${resume.toMap()}');
      return resume;
    } catch (e) {
      print('Error parsing AI generated text: $e');
      // In case of an error, return an empty or default resume model
      return Resume.empty();
    }
  }




// ... (other methods in ResumeBuilderController class)
  Resume _collectResumeData() {
    return Resume(
      name: _nameController.text,

      email: _emailController.text,

      mobile: _mobileController.text,

      linkedin: _linkedinController.text,

      twitter: _twitterController.text,

      summary: _summaryController.text,

      skills: _skills.join(', '),
      languagesSpoken: _languages.join(', '),

      workExperience: _workExperience,

      education: _education,

      projects: _projects,

      certifications: _certifications,
    );
  }

  // =============================
  // STEP 13: UI Build
  // =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Resume Builder",
        isLeading: true,
        backgroundColor: AppColors.primary,),

    body:
    SingleChildScrollView(
      controller: _scrollController,

      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

      // Reduced vertical padding
      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: <Widget>[

            _buildSectionTitle('Contact Information', Icons.person_outline),

            _buildTextField(
              _nameController,

              'Full Name',

              'Enter your full name...',

              validator: (value) =>
              value!.isEmpty ? 'Name is required' : null,
            ),

            _buildTextField(
              _emailController,

              'Email',

              'your@email.com',

              validator: (value) =>
              value!.isEmpty ? 'Email is required' : null,
            ),

            _buildTextField(
              _mobileController,

              'Mobile Number',

              '+1 234 567 8900',
              validator: (value) =>
              value!.isEmpty ? 'Phone is required' : null,
            ),

            _buildTextField(
              _linkedinController,

              'LinkedIn URL',

              'https://linkedin.com/in/your-profile',
              validator: (value) =>
              value!.isEmpty ? 'LinkedIn URL is required' : null,
            ),

            _buildTextField(
              _twitterController,

              'Twitter/X Profile',

              'https://twitter.com/your-handle',
            ),

            _buildSectionDivider(),

            _buildSectionTitle(
              'Professional Summary',
              Icons.description_outlined,
            ),

            _buildTextField(
              _summaryController,

              'Professional Summary',

              'Write a compelling professional summary...',


              isMultiLine: true,
            ),

            _buildSectionDivider(),

            _buildSectionTitle('Skills', Icons.psychology_outlined),


            _buildSkillsInput(),

            _buildSectionDivider(),


            // ADDED NEW SECTION FOR LANGUAGES
            _buildSectionTitle('Languages', Icons.language_outlined),
            _buildLanguagesInput(),
            _buildSectionDivider(),
            _buildSectionTitle('Work Experience', Icons.work_outline),


            ..._workExperience
                .asMap()
                .entries
                .map(
                  (entry) => _buildExperienceEntry(entry.value, entry.key),
            ),

            _buildAddButton(
              'Add Experience',

                  () => setState(() => _workExperience.add(Experience.empty())),
            ),

            _buildSectionDivider(),

            _buildSectionTitle('Education', Icons.school_outlined),

            ..._education
                .asMap()
                .entries
                .map(
                  (entry) => _buildEducationEntry(entry.value, entry.key),
            ),

            _buildAddButton(
              'Add Education',

                  () => setState(() => _education.add(Education.empty())),
            ),

            _buildSectionDivider(),

            _buildSectionTitle('Projects', Icons.rocket_launch_outlined),

            ..._projects
                .asMap()
                .entries
                .map(
                  (entry) => _buildProjectEntry(entry.value, entry.key),
            ),

            _buildAddButton(
              'Add Project',

                  () => setState(() => _projects.add(Project.empty())),
            ),

            _buildSectionDivider(),

            _buildSectionTitle(
              'Certifications',
              Icons.verified_user_outlined,
            ),

            ..._certifications
                .asMap()
                .entries
                .map(
                  (entry) => _buildCertificationEntry(entry.value, entry.key),
            ),

            _buildAddButton(
              'Add Certification',

                  () =>
                  setState(() => _certifications.add(Certification.empty())),
            ),

            const SizedBox(height: 24),

            _buildActionButton('Build AI Resume', _buildResume),

            const SizedBox(height: 16),
          ],
        ),
      ),
    )
    ,
    );
  }


  // =============================
  // STEP 14: Helper Widgets
  // =============================

  // Section Title Widget
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),

      // Reduced vertical padding
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24), // Smaller icon

          const SizedBox(width: 12),

          Text(
            title,

            style: const TextStyle(
              color: AppColors.textColor,

              fontSize: 22, // Slightly smaller font size

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  // Divider Widget
  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0), // Reduced padding

      child: Divider(color: AppColors.hintColor, height: 1),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(TextEditingController controller,

      String label,

      String hint, {

        bool isMultiLine = false,

        String? Function(String?)? validator,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Reduced margin

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: const TextStyle(
              color: AppColors.textColor,

              fontWeight: FontWeight.bold,

              fontSize: 14, // Smaller label font size
            ),
          ),

          const SizedBox(height: 6.0), // Reduced spacing

          TextFormField(
            controller: controller,

            style: const TextStyle(color: AppColors.textColor),

            maxLines: isMultiLine ? null : 1,

            validator: validator ?? (value) => null,

            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),

              // Reduced padding for smaller height
              hintText: hint,

              hintStyle: const TextStyle(color: AppColors.hintColor),

              filled: true,

              fillColor: AppColors.cardColor,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),

                // Slightly smaller border radius
                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),

                borderSide: const BorderSide(
                  color: Colors.white,
                ), // Added border width
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Action Button (Build Resume)
  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,

        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ), // Reduced padding
      ),

      child: _isLoading
          ? const CircularProgressIndicator(color:Colors.white)
          : Text(
        text,

        style: const TextStyle(
          fontSize: 16, // Slightly smaller font size

          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  // Add Button (+ Experience/Edu/Project/Cert)
  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Reduced margin

      child: OutlinedButton.icon(
        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),

          // Reduced border width
          padding: const EdgeInsets.symmetric(vertical: 14),

          // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ), // Smaller radius
        ),

        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primary,
          size: 20,
        ),

        // Smaller icon
        label: Text(
          text,

          style: const TextStyle(
            color: AppColors.primary,

            fontSize: 14, // Smaller font size

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Work Experience Entry Form
  Widget _buildExperienceEntry(Experience exp, int index) {
    return _buildDynamicFormEntry(
      title: 'Work Experience ${index + 1}',

      onDelete: () => setState(() => _workExperience.removeAt(index)),

      children: [
        _buildFormTextField(
          'Title/Position',

          'Job Title',

              (value) => exp.title = value,
          validator: (value) => value!.isEmpty ? 'Title is required' : null,

          initialValue: exp.title,
        ),

        _buildFormTextField(
          'Organization/Company',

          'Company Name',

              (value) => exp.company = value,

          initialValue: exp.company,
          validator: (value) => value!.isEmpty ? 'Company is required' : null,

        ),

        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,

                'Start Date',

                exp.startDate,

                    (selectedDate) =>
                exp.startDate = DateFormat('MMM yyyy').format(selectedDate),
              ),
            ),

            const SizedBox(width: 12), // Reduced spacing

            Expanded(
              child: _buildDatePicker(
                context,

                'End Date',

                exp.endDate,

                    (selectedDate) =>
                exp.endDate = DateFormat('MMM yyyy').format(selectedDate),
              ),
            ),
          ],
        ),

        _buildFormTextField(
          'Description',

          'Describe your responsibilities...',

              (value) => exp.description = value,

          isMultiLine: true,

          initialValue: exp.description,
        ),
      ],
    );
  }

  // Education Entry Form
  Widget _buildEducationEntry(Education edu, int index) {
    return _buildDynamicFormEntry(
      title: 'Education ${index + 1}',

      onDelete: () => setState(() => _education.removeAt(index)),

      children: [
        _buildFormTextField(
          'Title/Degree',

          'Degree/Certificate Title',


              (value) => edu.title = value,
          validator: (value) => value!.isEmpty ? 'Title is required' : null,

          initialValue: edu.title,
        ),

        _buildFormTextField(
          'University/Institution',

          'University Name',


              (value) => edu.university = value,
          validator: (value) => value!.isEmpty ? 'University is required' : null,

          initialValue: edu.university,
        ),

        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,

                'Start Date',

                edu.startDate,

                    (selectedDate) =>
                edu.startDate = DateFormat('MMM yyyy').format(selectedDate),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildDatePicker(
                context,

                'End Date',

                edu.endDate,

                    (selectedDate) =>
                edu.endDate = DateFormat('MMM yyyy').format(selectedDate),
              ),
            ),
          ],
        ),

        _buildFormTextField(
          'Description',

          'Describe your coursework and achievements...',

              (value) => edu.description = value,

          isMultiLine: true,

          initialValue: edu.description,
        ),
      ],
    );
  }

  // Project Entry Form
  Widget _buildProjectEntry(Project proj, int index) {
    return _buildDynamicFormEntry(
      title: 'Project ${index + 1}',

      onDelete: () => setState(() => _projects.removeAt(index)),

      children: [
        _buildFormTextField(
          'Project Title',

          'Enter project title',

              (value) => proj.title = value,
          validator: (value) => value!.isEmpty ? 'Title is required' : null,

          initialValue: proj.title,
        ),

        _buildFormTextField(
          'Summary',

          'Describe what the project does...',

              (value) => proj.summary = value,

          isMultiLine: true,
          validator: (value) => value!.isEmpty ? 'Summary is required' : null,

          initialValue: proj.summary,
        ),

        _buildFormTextField(
          'Project Link (Optional)',

          'https://github.com/...',

              (value) => proj.projectLink = value,

          initialValue: proj.projectLink,
        ),
      ],
    );
  }


  // Certification Entry Form
  Widget _buildCertificationEntry(Certification cert, int index) {
    return _buildDynamicFormEntry(
      title: 'Certification ${index + 1}',

      onDelete: () => setState(() => _certifications.removeAt(index)),

      children: [
        _buildFormTextField(
          'Certificate Title',

          'Enter certificate title',

              (value) => cert.title = value,

          initialValue: cert.title,
          validator: (value) => value!.isEmpty ? 'Title is required' : null,
        ),

        _buildFormTextField(
          'Organization',

          'Issuing Organization',

              (value) => cert.organization = value,
          validator: (value) => value!.isEmpty ? 'Organization is required' : null,

          initialValue: cert.organization,
        ),

        _buildFormTextField(
          'Link',

          'Link to certificate',

              (value) => cert.link = value,
          validator: (value) =>
          value!.isEmpty ? 'Link is required' : null,

          initialValue: cert.link,
        ),

        _buildDatePicker(
          context,

          'Date Acquired',

          cert.date,

              (selectedDate) =>
          cert.date = DateFormat('MMM yyyy').format(selectedDate),
        ),
      ],
    );
  }

// Dynamic Form Wrapper
  Widget _buildDynamicFormEntry({
    required String title,

    required VoidCallback onDelete,

    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced margin

      padding: const EdgeInsets.all(12), // Reduced padding

      decoration: BoxDecoration(
        color: AppColors.cardColor,

        borderRadius: BorderRadius.circular(12), // Smaller border radius

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),

            blurRadius: 8, // Reduced blur

            offset: const Offset(0, 4), // Reduced offset
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: AppColors.textColor,

                    fontSize: 18, // Smaller font size

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                  size: 20,
                ),

                // Smaller icon
                onPressed: onDelete,
              ),
            ],
          ),

          const SizedBox(height: 8), // Reduced spacing

          ...children,
        ],
      ),
    );
  }

  // Custom Form TextField (used in dynamic entries)
  Widget _buildFormTextField(String label,

      String hint,

      Function(String) onChanged, {

        bool isMultiLine = false,

        String? initialValue,

        String? Function(String?)? validator,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Reduced margin

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: const TextStyle(
              color: AppColors.hintColor,

              fontWeight: FontWeight.w600, // Medium-bold

              fontSize: 12, // Smaller font size
            ),
          ),

          const SizedBox(height: 6.0), // Reduced spacing

          TextFormField(
            initialValue: initialValue,

            style: const TextStyle(color: AppColors.textColor),

            onChanged: onChanged,

            maxLines: isMultiLine ? null : 1,

            validator: validator ?? (value) => null,

            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 12.0,
              ),

              // Reduced padding for smaller height
              hintText: hint,

              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 14,
              ),

              // Smaller hint font size
              filled: true,

              fillColor: AppColors.darkBackground,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),

                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),

                borderSide: const BorderSide(
                  color: Colors.white,
                ), // Reduced width
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Date Picker Widget
  Widget _buildDatePicker(BuildContext context,

      String label,

      String initialDate,

      Function(DateTime) onDateSelected,) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Reduced margin

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: const TextStyle(
              color: AppColors.hintColor,

              fontWeight: FontWeight.w600,

              fontSize: 12, // Smaller font size
            ),
          ),

          const SizedBox(height: 6.0), // Reduced spacing

          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,

                initialDate: initialDate.isNotEmpty
                    ? DateFormat('MMM yyyy').parse(initialDate)
                    : DateTime.now(),

                firstDate: DateTime(1900),

                lastDate: DateTime(2101),

                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      dialogTheme: DialogThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.primary,

                        onPrimary: AppColors.darkBackground,

                        surface: AppColors.cardColor,

                        onSurface: AppColors.textColor,
                      ),

                      dialogBackgroundColor: AppColors.cardColor,
                    ),

                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  onDateSelected(picked);
                });
              }
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0, // Reduced padding

                vertical: 10.0, // Reduced padding
              ),

              decoration: BoxDecoration(
                color: AppColors.darkBackground,

                borderRadius: BorderRadius.circular(8.0),

                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),

                  width: 1.5, // Reduced border width
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      initialDate.isNotEmpty ? initialDate : 'Select Date',

                      style: TextStyle(
                        color: initialDate.isNotEmpty
                            ? AppColors.textColor
                            : AppColors.hintColor,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.calendar_month,
                    color: AppColors.primaryLight,
                    size: 20,
                  ), // Smaller icon
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Skills Input + Chips
  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Skills",
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: AppColors.cardColor,
              labelStyle: const TextStyle(color: AppColors.textColor),
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.red),
              onDeleted: () {
                setState(() {
                  _skills.remove(skill);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _skillsController,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _skills.add(value.trim());
                _skillsController.clear();
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Type a skill and press enter...",
            hintStyle: const TextStyle(color: AppColors.hintColor),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Languages Input + Chips
  Widget _buildLanguagesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Languages",
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languages.map((language) {
            return Chip(
              label: Text(language),
              backgroundColor: AppColors.cardColor,
              labelStyle: const TextStyle(color: AppColors.textColor),
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.red),
              onDeleted: () {
                setState(() {
                  _languages.remove(language);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _languagesController,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _languages.add(value.trim());
                _languagesController.clear();
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Type a language and press enter...",
            hintStyle: const TextStyle(color: AppColors.hintColor),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

}
