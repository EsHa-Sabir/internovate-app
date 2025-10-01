import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/api_key.dart';

// 🔹 Auth & Screens
import 'package:intern_management_app/presentation/auth/forget/screens/forget_password_screen.dart';
import 'package:intern_management_app/presentation/auth/login/screens/sign_in_options_screen.dart';
import 'package:intern_management_app/presentation/auth/login/screens/sign_In_screen.dart';
import 'package:intern_management_app/presentation/auth/onboarding/screens/onboarding_screen.dart';
import 'package:intern_management_app/presentation/auth/sign_up/screens/register_screen.dart';
import 'package:intern_management_app/presentation/user_panel/ai_courses/screens/ai_course_home_view_screen.dart';
import 'package:intern_management_app/presentation/user_panel/ai_courses/screens/final_course_view.dart';
import 'package:intern_management_app/presentation/user_panel/ai_courses/screens/generate_course_layout.dart';

// 🔹 User Panel Screens
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/category_based_internship.dart';
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/internship_application_screen.dart';
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/internship_task_screen.dart';
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/submit_task_screen.dart';
import 'package:intern_management_app/presentation/user_panel/category_based_internship/screens/user_internship_screen.dart';
import 'package:intern_management_app/presentation/user_panel/contact_us/screens/contact_us_screen.dart';
import 'package:intern_management_app/presentation/user_panel/home/screens/home_screen.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/my_route_observer widget.dart';
import 'package:intern_management_app/presentation/user_panel/job/screens/job_portal_screen.dart';
import 'package:intern_management_app/presentation/user_panel/notification/notification_screen.dart';
import 'package:intern_management_app/presentation/user_panel/profile/screens/edit_profile_screen.dart';
import 'package:intern_management_app/presentation/user_panel/profile/screens/profile_screen.dart';
import 'package:intern_management_app/presentation/user_panel/resume/screens/ai_resume_screen.dart';

// 🔹 Services & Config
import 'package:intern_management_app/services/auth/auth_services.dart';
import 'package:intern_management_app/utils/theme/app_theme.dart';
import 'package:intern_management_app/firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'controllers/drawer/drawer_selection_controller.dart';
import 'controllers/internship/user_internship_controller.dart';

void main() async {

  // ✅ Step 1: Flutter binding initialize karo (Firebase/Plugins se pehle required hota hai)
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Step 2: Firebase initialize karo (Platform-specific options ke sath)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Step 3: Status bar & navigation bar icons ka color configure karo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ Step 4: EasyLoading ko globally configure karo
  configLoading();

  // ✅ Step 5: DrawerSelectionController ko GetX dependency injection se register karo
  Get.put(DrawerSelectionController());

  Get.put(UserInternshipController(), permanent: true);

  // for notification
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);




  // ✅ Step 6: Main App run karo
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // ✅ Step 7: GetMaterialApp ka use karo taake routing, theme & state management easy ho
    return GetMaterialApp(
      title: 'Intern Management App',
      debugShowCheckedModeBanner: false,

      // ✅ Step 8: EasyLoading ko builder ke through app me inject karo
      builder: EasyLoading.init(),

      // ✅ Step 9: App ka theme set karo (Dark Theme use kiya gaya hai)
      theme: AppTheme.darkTheme,

      // ✅ Step 10: Initial Route decide karo -> user login hai to Home otherwise Onboarding
      initialRoute: AuthService().isLogin() ? "/home" : "/onBoarding",

      // ✅ Step 11: Route observer attach karo taake back navigation ke sath drawer selection sync ho
      navigatorObservers: [MyRouteObserver()],

      // ✅ Step 12: Saare routes GetX pages me define karo
      getPages: [
        GetPage(name: "/onBoarding", page: () => OnboardingScreen()),
        GetPage(name: "/signInOptions", page: () => SignInOptionsScreen()),
        GetPage(name: "/signIn", page: () => SignInScreen()),
        GetPage(name: "/register", page: () => RegisterScreen()),
        GetPage(name: "/forget", page: () => ForgetPasswordScreen()),
        GetPage(name: "/home", page: () => HomeScreen()),
        GetPage(name: '/contact', page: () => ContactUsScreen()),
        GetPage(name: "/categoryInternship", page: () => CategoryBasedInternship()),
        GetPage(name:"/internshipApplication",page: ()=>InternshipApplicationScreen() ),
        GetPage(name: "/editProfile", page: () => EditProfileScreen()),
        GetPage(name: "/profile", page: () =>ProfileScreen()),
        GetPage(name: "/internshipTask", page: ()=>InternshipTaskScreen()),
        GetPage(name:"/userInternshipScreen",page: ()=>UserInternshipScreen()),
        GetPage(name: "/submitTask", page: ()=>SubmitTaskScreen()),
        GetPage(name: "/aiResumeScreen", page: ()=>AiResumeScreen()),
        GetPage(name: "/aiCourse", page: ()=>AICoursesHomeView()),
        GetPage(name: "/ai_course_layout", page: ()=>CourseLayoutView()), // ✅ New Route
        GetPage(name: "/ai_final_course", page: ()=>FinalCourseView()),
        GetPage(name: "/notification",page: ()=>NotificationScreen()),
        GetPage(name: "/jobPortal", page: ()=>JobPortalScreen())

      ],
    );
  }
}

// ✅ Step 13: EasyLoading ko customize karna (colors, spinner type, overlay, etc.)
void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle // Spinner ka style
    ..loadingStyle = EasyLoadingStyle.custom                // Custom style use karo
    ..backgroundColor = Colors.white                        // Box ka background color
    ..indicatorColor = Colors.black                         // Spinner ka color
    ..textColor = Colors.black                              // Text color
    ..maskColor = const Color(0x88000000)                   // Screen overlay color (dark transparent)
    ..userInteractions = false                              // Loading ke waqt user interaction block
    ..boxShadow = [
      const BoxShadow(
        color: Color(0x33000000),
        blurRadius: 10.0,
        offset: Offset(0, 5),
      ),
    ];
}
