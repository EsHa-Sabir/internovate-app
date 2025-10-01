import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/services/auth/auth_services.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1️⃣ To toggle password visibility
  bool isObscure = true;

  // 2️⃣ Form key for validation
  final _formKey = GlobalKey<FormState>();

  // 3️⃣ Controllers for input fields
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _username.dispose();
    _phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4️⃣ Detect if keyboard is open
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 5️⃣ Custom AppBar with back button
              AppBarWidget(title: "", isLeading: true),
              SizedBox(height: 20),
              keyboardOpen ? SizedBox.shrink() : SizedBox(height: 40),

              // 6️⃣ Page title
              _registerText(),
              const SizedBox(height: 30),

              // 7️⃣ Username input field with validation
              TextFieldWidget(
                hintText: "Username",
                controller: _username,
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 8️⃣ Email input field with regex validation
              TextFieldWidget(
                hintText: "Email",
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

              // 9️⃣ Password input with toggle visibility and validation
              TextFieldWidget(
                hintText: "Password",
                controller: _password,
                isPasswordField: true,
                isObscure: isObscure,
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                textInputType: TextInputType.text,
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
              SizedBox(height: 20),

              // 10️⃣ Phone number input (optional, no validation error)
              TextFieldWidget(
                hintText: "Phone",
                controller: _phone,
                textInputType: TextInputType.phone,
                validator: (value) {
                  return null; // Phone optional
                },
              ),
              const SizedBox(height: 25),

              // 11️⃣ Sign Up button with form validation and signup logic
              SizedBox(
                height: Get.height * 0.06,
                width: Get.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signUp(
                        _email.text,
                        _password.text,
                        _username.text,
                        _phone.text,
                      );
                      print("Form valid, proceed!");
                    }
                  },
                  child: Text("Sign In"),
                ),
              ),

              const SizedBox(height: 30),

              // 12️⃣ Prompt to navigate to Sign In screen if user already has an account
              _sigInText(context),
            ],
          ),
        ),
      ),
    );
  }

  // 13️⃣ Title Widget
  Widget _registerText() {
    return const Text(
      'Register',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  // 14️⃣ Navigation prompt to Sign In screen
  Widget _sigInText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do you have an account? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          InkWell(
            onTap: () {
              Get.toNamed("/signIn");
            },
            child: Text(
              'Sign In',
              style: TextStyle(color: Colors.blueAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 15️⃣ SignUp method calling AuthService and handling success/error
  void signUp(
      String email,
      String password,
      String username,
      String phone,
      ) async {
    final result = await AuthService().signUpWithEmail(email, password, username, phone);

    if (result == null) {
      showSnackBar(
        "Account created successfully! Verification email sent.",
        "Please verify your email before login.",AppColors.primary
      );
      Get.offNamed("/signIn");
    } else {
      showSnackBar("Account Creation Failed", result,Colors.red);
    }
  }
}
