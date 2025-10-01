import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/app_bar_widget.dart';
import '../../../../common/widgets/text_field_widget.dart';
import '../../../../services/auth/auth_services.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  // Step 1: Controller to manage email input
  final TextEditingController _email = TextEditingController();

  // Step 2: Form key to validate the form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Step 3: Dispose controller when widget is removed to free resources
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Step 4: Use SingleChildScrollView to avoid overflow on smaller screens
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Step 5: Assign form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // Step 6: Custom AppBar with back button
              AppBarWidget(title:"", isLeading: true),

              SizedBox(height: 120),

              // Step 7: Screen title text
              _registerText(),

              // Step 8: Instruction description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  "Please enter your registered email address. We’ll send you a link to reset your password.",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 30),

              // Step 9: Email input field with validation
              TextFieldWidget(
                hintText: "Email",
                controller: _email,
                textInputType: TextInputType.emailAddress,
                validator: (value) {
                  // Step 10: Check if email is empty
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter an email";
                  }
                  // Step 11: Simple regex for email validation
                  final emailRegex = RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Please enter a valid email";
                  }
                  return null; // Valid input
                },
              ),

              const SizedBox(height: 25),

              // Step 12: Button to send password reset email
              SizedBox(
                height: Get.height * 0.06,
                width: Get.width * 0.8,
                child: ElevatedButton(
                  onPressed: () async {
                    // Step 13: Validate form before sending reset email
                    if (_formKey.currentState!.validate()) {
                      await AuthService().sendPasswordResetEmail(_email.text);
                    }
                  },
                  child: Text("Send Reset email"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 14: Widget for the title text
  Widget _registerText() {
    return const Text(
      'Forget Password',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }
}
