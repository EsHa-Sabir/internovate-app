import 'package:get/get.dart';
import 'package:intern_management_app/models/internship/internship_model.dart';
import '../../services/database/internship/internship_service.dart';

class InternshipController extends GetxController {
  final InternshipService _internshipService = InternshipService();

  var internships = <InternshipModel>[].obs;
  var isLoading = false.obs;

  Future<void> loadInternships(String categoryId) async {
    try {
      isLoading.value = true;
      internships.value =
      await _internshipService.fetchInternshipsByCategory(categoryId);
    } finally {
      isLoading.value = false;
    }
  }
}
