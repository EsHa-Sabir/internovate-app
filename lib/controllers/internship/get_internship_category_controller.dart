import 'package:get/get.dart';
import 'package:intern_management_app/services/database/internship/category_service.dart';

import '../../models/internship/internship_category_model.dart';

class GetInternshipCategoryController extends GetxController{


  var categories = <InternshipCategoryModel>[].obs;


  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }
void fetchCategories()async{
    categories.value=await InternshipCategoryService().fetchAllInternshipCategory();
}
}