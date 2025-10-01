import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/services/database/contact/contact_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../../models/contact/our_info_model.dart';
import '../../../../services/database/contact/our_info_service.dart';


class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  // Step 1: Define TextEditingControllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Step 2: Contact details (dynamic data)
  OurInfoModel? _ourInfo;




  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  void loadInfo() async {
    final info = await OurInfoService().getOurInfo();
    setState(() {
      _ourInfo = info;
    });
  }




  // Step 3: Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Step 4: Function to launch Email app
  void _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _ourInfo!.email,
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Hello, I need help with...',
      },
    );
    print(uri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch email client");
    }
  }

  /// Step 5: Function to launch Phone dialer
  void _launchPhone() async {
    final Uri uri = Uri(scheme: "tel", path: _ourInfo!.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch phone dialer");
    }
  }

  /// Step 6: Function to launch WhatsApp
  void _launchWhatsApp() async {
    final String message = Uri.encodeComponent("Hello, I need help");
    final String phoneNumber = _ourInfo!.whatsapp.replaceAll('+', '');
    final Uri uri = Uri.parse("https://wa.me/$phoneNumber?text=$message");
    print(uri);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  @override
  void dispose() {
    // Step 7: Dispose controllers to avoid memory leaks
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step 8: Scaffold with AppBar + Drawer
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: AppColors.primary,
      ),
      drawer: DrawerWidget(),

      // Step 9: Page Body
      body: _ourInfo == null
          ? const Center(
        child: CupertinoActivityIndicator(),
      ): Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Step 10: Introduction Text
            const Text(
              "We're here to help!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "If you have any questions, feedback, or need support, "
                  "you can reach us through the following channels:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Step 11: Email contact
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(_ourInfo!.email),
              onTap: _launchEmail,
            ),

            // Step 12: Phone contact
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(_ourInfo!.phone),
              onTap: _launchPhone,
            ),

            // Step 13: WhatsApp contact
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.teal),
              title: const Text("Chat on WhatsApp"),
              onTap: _launchWhatsApp,
            ),

            const SizedBox(height: 20),

            // Step 14: Feedback form heading
            const Text(
              "Send us a message",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Step 15: Feedback Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  SizedBox(
                    width: Get.width * 0.9,
                    child: TextFieldWidget(
                      hintText: 'Your Name',
                      controller: _nameController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email field
                  SizedBox(
                    width: Get.width * 0.9,
                    child: TextFieldWidget(
                      hintText: 'Your Email',
                      controller: _emailController,
                      textInputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Message field
                  SizedBox(
                    width: Get.width * 0.9,
                    child: TextFieldWidget(
                      hintText: 'Message',
                      controller: _messageController,
                      textInputType: TextInputType.text,
                      maxLines: 3,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Submit button
                  SizedBox(
                    width: Get.width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Step 16: Save message to Firestore using ContactService
                          ContactService().addContactMessage(
                            FirebaseAuth.instance.currentUser!.uid,
                            _nameController.text,
                            _emailController.text,
                            _messageController.text,
                          );

                          // Step 17: Clear fields after sending
                          _nameController.clear();
                          _messageController.clear();
                          _emailController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text("Send Message"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
