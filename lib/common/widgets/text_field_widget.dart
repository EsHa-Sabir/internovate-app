import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_colors.dart';

// Step 1: Create a reusable text field widget
class TextFieldWidget extends StatelessWidget {
  // Step 2: Declare the properties needed for the text field
  final String hintText;                      // Placeholder text inside the field
  final String? Function(String?)? validator; // Validator function for form validation
  final TextEditingController controller;    // Controller to manage input text
  final bool isObscure;                       // To hide/show text (for passwords)
  final bool isPasswordField;                 // To show/hide the visibility toggle icon
  final VoidCallback? onPressed;              // Function called when visibility icon is pressed
  final TextInputType textInputType;// Keyboard type (email, number, text, etc.)
  final int? maxLines;
  final int? maxLength;

  // Step 3: Constructor to initialize properties
  const TextFieldWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.onPressed,
    this.isObscure = false,
    this.isPasswordField = false,
    this.validator,
    required this.textInputType,
    this.maxLines=1,
    this.maxLength
  });

  @override
  Widget build(BuildContext context) {
    // Step 4: Set the width relative to screen width (80%)
    return SizedBox(
      width: Get.width * 0.8,

      // Step 5: Actual text input field
      child: TextFormField(
        keyboardType: textInputType, // Step 6: Set keyboard type
        validator: validator,         // Step 7: Attach validator function if any
        obscureText: isObscure,      // Step 8: Hide text if isObscure is true
        controller: controller,      // Step 9: Assign controller to manage text input
        maxLines: maxLines,
        maxLength: maxLength,
        // Step 10: Input decoration for styling
        decoration: InputDecoration(

          hintText: hintText,// Step 11: Show hint text

          // Step 12: Show visibility toggle icon only if it is a password field
          suffixIcon: isPasswordField
              ? IconButton(
            icon: Icon(
              // Step 13: Show visibility_off or visibility icon depending on obscure state
              isObscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey, // Step 14: Icon color
            ),
            onPressed: onPressed, // Step 15: Toggle obscureText when icon is pressed
          )
              : null, // Step 16: No suffix icon if not password field
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
      ),
    );
  }
}
