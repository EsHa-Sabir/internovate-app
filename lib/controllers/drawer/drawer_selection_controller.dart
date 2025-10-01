import 'package:get/get.dart';

class DrawerSelectionController extends GetxController {
  var selectedParent = "Home".obs;

  void selectParent(String parent) {
    selectedParent.value = parent;
  }

  void updateSelectionFromRoute(String route) {
    switch (route) {
      case "/home":
        selectParent("Home");
        break;
      case "/profile":
        selectParent("Profile");
        break;
      case "/userInternshipScreen":
        selectParent("Internship");
        break;

      case "/jobPortal":
        selectParent("Job Portal");
        break;
      case "/aiResumeScreen":
        selectParent("AI Resume");
        break;
      case "/aiCourse":
        selectParent("AI Courses");
        break;
      case "/contact":
        selectParent("Contact Us");
        break;
      default:
        selectParent("Home");
    }
  }
}
