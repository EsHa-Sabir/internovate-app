// lib/screens/ai_resume/ai_resume_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import 'package:intern_management_app/presentation/user_panel/resume/screens/resume_builder_screen.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controllers/resume/resume_builder_controller.dart';

/// Screen for showing AI Resume (if already generated) and option to build new one
class AiResumeScreen extends StatefulWidget {
  const AiResumeScreen({super.key});

  @override
  State<AiResumeScreen> createState() => _AiResumeScreenState();
}

class _AiResumeScreenState extends State<AiResumeScreen> {
  final ResumeBuilderController _controller = ResumeBuilderController();
  final RxBool _isDeleting = false.obs; // GetX ka RxBool istemal karein

  void _navigateToBuilder() {
    Get.to(() => const ResumeBuilderScreen());
  }

  void _deleteResume(String publicId) async {
    _isDeleting.value = true; // Deletion start hone par true karein
    try {
      await _controller.deletePdf(publicId);
      showSnackBar(
        "Deleted",
        "Your resume has been deleted successfully.",
        AppColors.primary,
      );
    } catch (e) {
      showSnackBar("Error", "Failed to delete resume. Please try again.", Colors.red);
    } finally {
      _isDeleting.value = false; // Process complete hone par false karein
    }
  }

  void _openFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Error opening file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text('AI Resume'),
      ),
      drawer: DrawerWidget(),

      body: StreamBuilder<Map<String, String>?>(
        stream: _controller.streamSavedPdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final resume = snapshot.data;

          if (resume == null || resume['url'] == null || resume['url']!.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 30),
                  _buildNoResumeFound(),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 30),
                _buildResumeCard(resume),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_fix_high, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            "Build Your Professional Resume",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "Use AI-powered tools to create a polished resume in minutes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToBuilder,
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            label: const Text("Create New Resume"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResumeFound() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 60, color: AppColors.textColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            "No resume found",
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Create your AI-generated resume to get started.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(Map<String, String> resume) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: const Icon(Icons.picture_as_pdf,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your AI-Generated Resume",
                      style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Last Created: ${DateTime.now().toString().substring(0, 10)}",
                      style: const TextStyle(
                          color: AppColors.hintColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Delete button: Ab sirf yahan loader show hoga
              Obx(() {
                return _isDeleting.value
                    ? const SizedBox(
                  width: 30, // Icon button jitni width den
                  height: 30,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                )
                    : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Delete Resume",
                  onPressed: () => _deleteResume(resume['publicId']!),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.download, "Download", () {
                _openFile(resume['url']!);
              }),
              _buildActionButton(Icons.share, "Share", () {
                _openFile(resume['url']!);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textColor)),
      ],
    );
  }
}