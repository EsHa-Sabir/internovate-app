import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/common/widgets/text_field_widget.dart';
import 'package:intern_management_app/presentation/user_panel/profile/widgets/image_picker.dart';
import 'package:intern_management_app/services/cloudinary/cloudinary_service.dart';

import '../../../../controllers/user/get_user_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller for handling user data (GetX controller)
  final GetUserController getUserController = Get.put(GetUserController());

  // Text controllers for form input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _instituteNameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // File variable for selected image
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields with current user data from controller
    _usernameController.text = getUserController.user.value!.username;
    _phoneController.text = getUserController.user.value!.phone;
    _aboutController.text = getUserController.user.value!.about ?? "";
    _instituteNameController.text = getUserController.user.value!.instituteName ?? "";
    _experienceController.text = getUserController.user.value!.experience ?? "";
  }

  @override
  void dispose() {
    // Dispose controllers to free memory (important in stateful widgets)
    _usernameController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    _instituteNameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom reusable App Bar widget
      appBar: AppBarWidget(
        title: "Edit Profile",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Attach form validation key
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Profile image avatar
              Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.primary,

                      // Agar new image select hui hai to show karein
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (getUserController.user.value?.imageUrl != null &&
                          getUserController.user.value!.imageUrl!.isNotEmpty
                      // Warna backend wali image show karein
                          ? CachedNetworkImageProvider(
                        getUserController.user.value!.imageUrl!,
                      )
                          : null),

                      // Agar dono missing hain (no new image & no backend image)
                      // to username ka pehla letter show karein
                      child: (_selectedImage == null &&
                          (getUserController.user.value?.imageUrl == null ||
                              getUserController.user.value!.imageUrl!.isEmpty))
                          ? Text(
                        "${getUserController.user.value?.username[0]}",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          : null,
                    ),
                  ),

                  // Camera icon for picking or changing image
                  Positioned(
                    top: 60,
                    left: 200,
                    child: GestureDetector(
                      onTap: () => showImageOptions(context),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.darkBackground,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Username input field (required)
              TextFieldWidget(
                hintText: "Username",
                controller: _usernameController,
                textInputType: TextInputType.text,
                validator: (value) =>
                value!.isEmpty ? 'Please enter your username' : null,
              ),
              const SizedBox(height: 10),

              // Phone input field (optional → validator removed)
              TextFieldWidget(
                hintText: "Phone",
                controller: _phoneController,
                textInputType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                hintText: "instituteName",
                controller: _instituteNameController,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                hintText: "Experience",
                controller: _experienceController,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              // Bio input field (optional but limited to 500 chars)
              TextFieldWidget(
                hintText: 'Bio',
                controller: _aboutController,
                textInputType: TextInputType.text,
                maxLength: 500,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Bio must be less than 500 characters';
                  }
                  return null; // Empty bio is allowed
                },
              ),

              const SizedBox(height: 20),

              // Save changes button
              SizedBox(
                width: Get.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    // Form validate hoga phir hi update chalega
                    if (_formKey.currentState!.validate()) {
                      updateProfile();
                    }
                  },
                  child: const Text('Edit Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet to show options for profile image
  void showImageOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xff262626),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pick from gallery option
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text("Pick from Gallery", style: TextStyle(fontSize: 15)),
                onTap: () async {
                  Get.back(); // Close bottom sheet
                  _selectedImage = await pickImage(); // Pick new image
                  setState(() {}); // Refresh UI
                },
              ),

              // Delete current photo option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Photo", style: TextStyle(fontSize: 15)),
                onTap: () async {
                  Get.back(); // Close bottom sheet
                  final currentUser = getUserController.user.value;
                  if (currentUser == null) return;

                  // Agar user ke paas image hai tab delete karein
                  if (currentUser.imagePublicId?.isNotEmpty ?? false) {
                    try {
                      EasyLoading.show(status: "Please wait...");

                      // 1. Delete from Cloudinary
                      await CloudinaryService().deleteImageFromCloudinary(
                        currentUser.imagePublicId!,"image"
                      );

                      // 2. Update Firestore (clear image fields)
                      await getUserController.updateUser(
                        currentUser.userId,
                        _usernameController.text,
                        _phoneController.text,
                        "", // Clear publicId
                        "", // Clear URL
                        _aboutController.text,
                        _instituteNameController.text,
                        _experienceController.text,
                      );

                      // 3. Update UI
                      setState(() => _selectedImage = null);
                      showSnackBar("Success", "Image deleted",AppColors.primary);
                      EasyLoading.dismiss();
                    } catch (e) {
                      EasyLoading.dismiss();
                      print("Error deleting image: $e");
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Update profile details (Firestore + Cloudinary integration)
  Future<void> updateProfile() async {
    final currentUser = getUserController.user.value;
    if (currentUser == null) return;

    try {
      EasyLoading.show(status: "Please wait...");

      String imagePublicId = currentUser.imagePublicId ?? "";
      String imageUrl = currentUser.imageUrl ?? "";

      // Agar user ne new image select ki hai
      if (_selectedImage != null) {
        // Delete old image from Cloudinary if exists
        if (imagePublicId.isNotEmpty) {
          try {
            await CloudinaryService().deleteImageFromCloudinary(imagePublicId,"image");
          } catch (e) {
            print("Failed to delete old image: $e");
          }
        }

        // Upload new image to Cloudinary
        final map = await CloudinaryService().uploadImage(_selectedImage!,"image");
        if (map != null) {
          imagePublicId = map["public_id"] ?? "";
          imageUrl = map["url"] ?? "";
        }
      }

      // Update Firestore with latest data
      await getUserController.updateUser(
        currentUser.userId,
        _usernameController.text,
        _phoneController.text,
        imagePublicId,
        imageUrl,
        _aboutController.text,
        _instituteNameController.text,
        _experienceController.text,
      );

      showSnackBar("Success", "Update Successfully",AppColors.primary);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      print("Error updating profile: $e");
    }
  }
}
