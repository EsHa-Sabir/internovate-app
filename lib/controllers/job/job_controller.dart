// lib/controllers/job/job_controller.dart
import 'package:get/get.dart';
import '../../models/job_portal/job_model.dart';
import '../../services/job/job_api_service.dart';

class JobController extends GetxController {
  final JobApiService _jobApiService = JobApiService();

  var allJobs = <Job>[].obs;
  var recommendedJobs = <Job>[].obs;
  var filteredJobs = <Job>[].obs;
  var isLoading = true.obs;

  var selectedCategory = 'All'.obs;
  var selectedJobType = 'All'.obs;

  @override
  void onInit() {
    fetchJobs();
    super.onInit();
  }

  void fetchJobs() async {
    try {
      isLoading.value = true;
      allJobs.value = await _jobApiService.fetchJobs();
      recommendedJobs.value = allJobs.take(5).toList();
      applyFilters();
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Filters properly combined (category + type)
  void applyFilters() {
    List<Job> tempJobs = List<Job>.from(allJobs);

    if (selectedCategory.value != 'All') {
      tempJobs = tempJobs.where((job) => job.category == selectedCategory.value).toList();
    }

    if (selectedJobType.value != 'All') {
      tempJobs = tempJobs.where((job) =>
      job.jobType.toLowerCase() == selectedJobType.value.toLowerCase()).toList();
    }

    filteredJobs.value = tempJobs;
  }

  /// ✅ Search + Filters combined
  void searchJobs(String query) {
    List<Job> tempJobs = List<Job>.from(allJobs);

    if (selectedCategory.value != 'All') {
      tempJobs = tempJobs.where((job) => job.category == selectedCategory.value).toList();
    }

    if (selectedJobType.value != 'All') {
      tempJobs = tempJobs.where((job) =>
      job.jobType.toLowerCase() == selectedJobType.value.toLowerCase()).toList();
    }

    if (query.isNotEmpty) {
      tempJobs = tempJobs.where((job) =>
      job.title.toLowerCase().contains(query.toLowerCase()) ||
          job.companyName.toLowerCase().contains(query.toLowerCase())).toList();
    }

    filteredJobs.value = tempJobs;
  }
}
