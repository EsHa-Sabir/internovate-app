import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/services/database/internship/internship_application_service.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

import '../../../../models/contact/payment_info_model.dart';
import '../../../../services/database/contact/payment_info_service.dart';
import '../../../../services/notification/notification_service.dart';

class InternshipApplicationScreen extends StatefulWidget {
  const InternshipApplicationScreen({super.key});

  @override
  State<InternshipApplicationScreen> createState() =>
      _InternshipApplicationScreenState();
}

class _InternshipApplicationScreenState
    extends State<InternshipApplicationScreen> {
  // STEP 1️⃣: Create controllers for all text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController instituteController = TextEditingController();

  // STEP 2️⃣: Optional fields
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController expectationController = TextEditingController();

  // STEP 3️⃣: File variables for Resume & Payment Receipt
  File? resumeFile;
  File? paymentReceiptFile;
  PaymentInfoModel? _paymentInfo;

  // STEP 4️⃣: Loading state variable
  bool isLoading = false;

  // STEP 5️⃣: Internship details (from arguments)
  late String internshipId;
  late String internshipName;
  late String categoryId;

  // STEP 6️⃣: Form key for validation
  final _formKey = GlobalKey<FormState>();




  @override
  void initState() {
    super.initState();
    // STEP 7️⃣: Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>;
    internshipId = args["internshipId"];
    internshipName = args["internshipName"];
    categoryId = args["categoryId"];
    loadPaymentInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    fatherNameController.dispose();
    phoneController.dispose();
    idCardController.dispose();
    instituteController.dispose();
    experienceController.dispose();
    linkedInController.dispose();
    expectationController.dispose();
  }

  void loadPaymentInfo() async {
    final info = await PaymentInfoService().getPaymentInfo();
    setState(() {
      _paymentInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // STEP 8️⃣: Custom AppBar
      appBar: AppBarWidget(
        title: "Apply for $internshipName",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Attach form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STEP 9️⃣: Mandatory Fields (with validation)
              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Full Name *",
                  controller: nameController,
                  textInputType: TextInputType.text,
                  validator: (value) => value == null || value.isEmpty
                      ? "Full Name is required"
                      : null,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Father's Name *",
                  controller: fatherNameController,
                  textInputType: TextInputType.text,
                  validator: (value) => value == null || value.isEmpty
                      ? "Father's Name is required"
                      : null,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Phone Number * (0304-1234567)",
                  controller: phoneController,
                  textInputType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone Number is required";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "CNIC * (XXXXX-XXXXXXX-X)",
                  controller: idCardController,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "CNIC is required";
                    } else if (!RegExp(
                      r'^[0-9]{5}-[0-9]{7}-[0-9]$',
                    ).hasMatch(value)) {
                      return "Enter valid CNIC format: 12345-1234567-1";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Institute Name *",
                  controller: instituteController,
                  textInputType: TextInputType.text,
                  validator: (value) => value == null || value.isEmpty
                      ? "Institute is required"
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // STEP 🔟: Optional Fields (No validation)
              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Experience (Optional)",
                  controller: experienceController,
                  textInputType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "LinkedIn / Portfolio URL (Optional)",
                  controller: linkedInController,
                  textInputType: TextInputType.url,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: Get.width * 0.9,
                child: TextFieldWidget(
                  hintText: "Expectation (Optional)",
                  controller: expectationController,
                  textInputType: TextInputType.text,
                ),
              ),

              const SizedBox(height: 5),

              // STEP 1️⃣1️⃣: Resume Upload
              uploadField(
                title: "Resume *",
                hintText: "Upload your Resume (PDF / Image)",
                isResume: true,
              ),

              // STEP 1️⃣2️⃣: Payment Receipt Upload
              uploadField(
                title: "Payment Receipt *",
                hintText: "Upload payment screenshot",
                isResume: false,
              ),

              const SizedBox(height: 20),

              // STEP 1️⃣3️⃣: Payment Information Section
              if (_paymentInfo == null)
                ...[
                  const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ]
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black87,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "💳 Payment Section | ${_paymentInfo!.amount}",
                        style: const TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text("Account Title: ${_paymentInfo!.accountTitle}"),
                      Text("${_paymentInfo!.bankName} Bank: ${_paymentInfo!.accountNumber}"),
                      const SizedBox(height: 5),
                      Text("EasyPaisa: ${_paymentInfo!.easyPaisaNumber}"),
                      const SizedBox(height: 5),
                      Text("JazzCash: ${_paymentInfo!.jazzCashNumber} (${_paymentInfo!.jazzCashHolderName})"),
                      const SizedBox(height: 10),
                      const Text(
                        "⚠️ Note: You can apply only one internship at a time.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),


              const SizedBox(height: 20),

              // STEP 1️⃣4️⃣: Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Application"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 1️⃣5️⃣: Handle form submission
  void _submitApplication() async {
    // 1️⃣ Validate form
    if (!_formKey.currentState!.validate()) return;

    // 2️⃣ Check files
    if (resumeFile == null || paymentReceiptFile == null) {
      showSnackBar("Error", "Resume and payment receipt are required.",Colors.red);
      return;
    }

    // 3️⃣ Set loading state
    setState(() => isLoading = true);

    try {
      // 4️⃣ Call service and await
      await InternshipApplicationService().applyInternship(
        internshipId: internshipId,
        internshipName: internshipName,
        categoryId: categoryId,
        name: nameController.text,
        fatherName: fatherNameController.text,
        phone: phoneController.text,
        cnic: idCardController.text,
        institute: instituteController.text,
        experience: experienceController.text,
        linkedIn: linkedInController.text,
        expectation: expectationController.text,
        resumeFile: resumeFile!,
        receiptFile: paymentReceiptFile!,
      );

      // 5️⃣ Success message
      showSnackBar(
        'Success',
        "Your application has been submitted successfully.\nPayment will be verified within 48 hours.",AppColors.primary
      );
      // ✅ Notify all admins
      final admins = await FirebaseFirestore.instance
          .collection("users")
          .where("isAdmin", isEqualTo: true)
          .get();

      if (admins.docs.isEmpty) {
        print("⚠️ No admins found. Skipping notification...");
      } else {
        for (var adminDoc in admins.docs) {
          final adminUid = adminDoc.id;
          final playerId = adminDoc['token'];

          if (playerId != null && playerId.isNotEmpty) {
            await NotificationService.sendPushNotification(
              uid: adminUid,
              title: "New Internship Application",
              body: "${nameController.text} applied for $internshipName",
              playerId: playerId,
            );
          }
        }
      }
      // 6️⃣ Optionally, clear form or navigate back
      nameController.clear();
      fatherNameController.clear();
      phoneController.clear();
      idCardController.clear();
      instituteController.clear();
      experienceController.clear();
      linkedInController.clear();
      expectationController.clear();

      setState(() {
        resumeFile = null;
        paymentReceiptFile = null;
      });
    } catch (e) {
      // 7️⃣ Error handling
      print(e.toString());
    } finally {
      // 8️⃣ Stop loading
      setState(() => isLoading = false);
    }
  }

  // STEP 1️⃣6️⃣: Custom Upload Widget
  Widget uploadField({
    required String title,
    required String hintText,
    required bool isResume,
  }) {
    final file = isResume ? resumeFile : paymentReceiptFile;

    return Container(
      width: Get.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // STEP 1️⃣7️⃣: File name / hint
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file == null ? hintText : file.path.split('/').last,
                        style: TextStyle(
                          color: file == null ? Colors.grey : Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STEP 1️⃣8️⃣: Upload Button
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'png'],
              );

              if (result != null) {
                File pickedFile = File(result.files.single.path!);

                // STEP 1️⃣9️⃣: File size validation (Max 2 MB)
                final fileSize = await pickedFile.length();
                if (fileSize > 2 * 1024 * 1024) {
                  showSnackBar("Error", "File size must be 2 MB or less.",Colors.red);
                  return;
                }

                // Save file in state
                setState(() {
                  if (isResume) {
                    resumeFile = pickedFile;
                  } else {
                    paymentReceiptFile = pickedFile;
                  }
                });
              }
            },
            icon: const Icon(Icons.cloud_upload, color: Colors.green, size: 28),
            tooltip: "Upload",
          ),
        ],
      ),
    );
  }
}
