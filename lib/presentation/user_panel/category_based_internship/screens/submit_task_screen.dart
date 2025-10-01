import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../../controllers/internship/user_internship_controller.dart';

/// Screen where user submits their completed task
/// by providing LinkedIn post, GitHub repo, and optional deployment URL.
class SubmitTaskScreen extends StatefulWidget {
  const SubmitTaskScreen({super.key});

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  /// Global key to validate the form
  final _formKey = GlobalKey<FormState>();

  /// Controller to handle internship and task logic
  final controller = Get.find<UserInternshipController>();

  /// Task ID and Internship ID received from previous screen
  final taskId = Get.arguments["taskId"];
  final internshipId = Get.arguments["internshipId"];

  /// Text editing controllers for input fields
  TextEditingController linkedInController = TextEditingController();
  TextEditingController gitHubController = TextEditingController();
  TextEditingController liveDeploymentController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when screen is closed to free memory
    linkedInController.dispose();
    gitHubController.dispose();
    liveDeploymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Detect if keyboard is open → to adjust UI spacing
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      /// Custom app bar (reusable component)
      appBar: AppBarWidget(
        title: "Submit Your Task",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),

      /// Scrollable view in case form overflows when keyboard is open
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Attach form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Extra top spacing if keyboard is closed
              keyboardOpen ? const SizedBox.shrink() : const SizedBox(height: 110),

              // ========================
              // LinkedIn URL Input Field
              // ========================
              Text(
                "LinkedIn Post URL *",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                width: double.infinity,
                child: TextFieldWidget(
                  hintText: "Enter LinkedIn post URL",
                  controller: linkedInController,
                  textInputType: TextInputType.url,
                  validator: (value) {
                    /// Validation: required + must be valid URL
                    if (value == null || value.trim().isEmpty) {
                      return "LinkedIn post URL is required";
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return "Enter a valid URL";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ========================
              // GitHub Repo URL Input Field
              // ========================
              Text(
                "GitHub Repository URL *",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                width: double.infinity,
                child: TextFieldWidget(
                  hintText: "Enter GitHub repo URL",
                  controller: gitHubController,
                  textInputType: TextInputType.url,
                  validator: (value) {
                    /// Validation: required + must be valid URL
                    if (value == null || value.trim().isEmpty) {
                      return "GitHub repo URL is required";
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return "Enter a valid URL";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ==============================
              // Live Deployment URL (Optional)
              // ==============================
              Text(
                "Live Deployment URL (Optional)",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                width: double.infinity,
                child: TextFieldWidget(
                  hintText: "Enter Live Deployment URL",
                  controller: liveDeploymentController,
                  textInputType: TextInputType.url,
                  validator: (value) {
                    /// Validation: only if user enters something
                    if (value != null && value.trim().isNotEmpty) {
                      if (!Uri.tryParse(value)!.isAbsolute) {
                        return "Enter a valid URL";
                      }
                    }
                    return null; // optional field → no error if empty
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ========================
              // Submit Task Button
              // ========================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    /// Step 1: Validate all fields
                    if (_formKey.currentState!.validate()) {
                      /// Step 2: Mark task as completed in controller
                      controller.toggleTaskCompletion(
                        internshipId,
                        taskId,
                        linkedInController.text,
                        gitHubController.text,
                        liveDeploymentController.text,
                      );

                      /// Step 3: Clear input fields after submission
                      linkedInController.clear();
                      gitHubController.clear();
                      liveDeploymentController.clear();



                    }
                  },
                  child: const Text("Submit Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
