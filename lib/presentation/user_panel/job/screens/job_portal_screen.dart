import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controllers/job/job_controller.dart';
import '../../../../models/job_portal/job_model.dart';
import '../../../../utils/constants/app_colors.dart';

class JobPortalScreen extends StatelessWidget {
  final JobController jobController = Get.put(JobController());

  String _formatPostedDate(String? postedDate) {
    if (postedDate == null || postedDate.isEmpty) return 'N/A';
    return postedDate.length >= 10 ? postedDate.substring(0, 10) : postedDate;
  }

  Widget _buildJobCard(Job job) {
    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.business_center, color: AppColors.textColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(job.applyLink))) {
                      await launchUrl(Uri.parse(job.applyLink), mode: LaunchMode.externalApplication);
                    } else {
                      showSnackBar("Error", "Could not open link", Colors.red);
                    }
                  },
                  icon: const Icon(Icons.link, size: 18, color: AppColors.textColor),
                  label: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.location_on, job.location),
                _buildInfoChip(Icons.work, job.jobType),
                _buildInfoChip(Icons.access_time, 'Posted: ${_formatPostedDate(job.postedDate)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.hintColor),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.hintColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Job Portal', style: TextStyle(color: AppColors.textColor)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: 'Search for jobs...',
                  hintStyle: const TextStyle(color: AppColors.hintColor),
                  prefixIcon: const Icon(Icons.search, color: AppColors.hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                onChanged: (value) => jobController.searchJobs(value),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown(
                    'Category',
                    jobController.selectedCategory,
                    const [
                      'All',
                      'Programming',
                      'Electrical Engineering',
                      'Management Sciences',
                      'Artificial Intelligence',
                      'Data Science',
                      'Machine Learning',
                      'General'
                    ],
                        (newValue) {
                      jobController.selectedCategory.value = newValue!;
                      jobController.applyFilters();
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildFilterDropdown(
                    'Job Type',
                    jobController.selectedJobType,
                    const ['All', 'Full-time', 'Part-time', 'Internship'],
                        (newValue) {
                      jobController.selectedJobType.value = newValue!;
                      jobController.applyFilters();
                    },
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (jobController.isLoading.value) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: CupertinoActivityIndicator()),
                      SizedBox(height: 20),
                      Text("Please wait...", style: TextStyle(color: AppColors.hintColor)),
                    ],
                  );
                } else if (jobController.filteredJobs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No jobs match your search/filters.',
                      style: TextStyle(color: AppColors.hintColor, fontSize: 15),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: jobController.filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = jobController.filteredJobs[index];
                      return _buildJobCard(job);
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, RxString selectedValue, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue.value,
          style: const TextStyle(color: AppColors.textColor),
          dropdownColor: AppColors.darkGrey,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.hintColor),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: AppColors.textColor)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
