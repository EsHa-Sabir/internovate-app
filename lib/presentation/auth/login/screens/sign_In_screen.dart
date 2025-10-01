import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/services/auth/auth_services.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import '../../../../utils/constants/app_images.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Step 1: Variable to track password visibility toggle
  bool isObscure = true;

  // Step 2: Form key to manage form validation
  final _formKey = GlobalKey<FormState>();

  // Step 3: Controllers for email and password input fields
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    // Step 4: Dispose controllers to free up resources
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step 5: Check if keyboard is open to adjust UI spacing
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,  // Step 6: Assign form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step 7: Custom AppBar with back button
              AppBarWidget(
                title: "",
                isLeading: true,
              ),

              SizedBox(height: Get.height * 0.07),

              // Step 8: Adjust spacing if keyboard is open or not
              keyboardOpen ? SizedBox.shrink() : SizedBox(height: Get.height * 0.07),

              // Step 9: Screen title
              _registerText(),

              const SizedBox(height: 50),

              // Step 10: Email input with validation
              TextFieldWidget(
                hintText: "Enter Email",
                controller: _email,
                textInputType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter an email";
                  }
                  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Step 11: Password input with visibility toggle and validation
              TextFieldWidget(
                hintText: "Password",
                controller: _password,
                textInputType: TextInputType.text,
                isPasswordField: true,
                isObscure: isObscure,
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;  // Toggle password visibility
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              // Step 12: "Reset Password?" link aligned to right
              Padding(
                padding: EdgeInsets.only(right: Get.width * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.toNamed("/forget");  // Navigate to forget password screen
                      },
                      child: Text(
                        'Reset Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Step 13: Sign In button to validate and submit form
              SizedBox(
                height: Get.height * 0.06,
                width: Get.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form valid, proceed with sign-in
                      signIn(_email.text, _password.text);
                      print("Form valid, proceed!");
                    }
                  },
                  child: Text("Sign In"),
                ),
              ),

              const SizedBox(height: 40),

              // Step 14: Register prompt for new users
              _sigInText(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the "Sign In" title
  Widget _registerText() {
    return const Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  // Widget for the "Not a member? Register Now" prompt
  Widget _sigInText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not A Member? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          InkWell(
            onTap: () {
              Get.toNamed("/register");  // Navigate to registration screen
            },
            child: Text(
              'Register Now',
              style: TextStyle(color: Colors.blueAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Step 15: signIn function to call AuthService and handle login response
  void signIn(String email, String password) async {
    final result = await AuthService().signInWithEmail(email, password);

    if (result == "/home") {
      showSnackBar("Login Success", "Login Successfully",AppColors.primary);
      Get.offAllNamed(result!);
    } else if (result == "Please verify your email before login.") {
      showSnackBar("Verify your email", "Please Verify your Email Before Login.",Colors.red);
    } else {
      showSnackBar("Login Failed", "$result",Colors.red);
    }
  }

}
