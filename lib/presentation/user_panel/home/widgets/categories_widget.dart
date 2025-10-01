import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/controllers/internship/get_internship_category_controller.dart';

import '../../../../utils/constants/app_colors.dart';

class CategoriesWidget extends StatefulWidget {
  CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  // 🔹 Controller banaya jo internship categories list fetch karega (Firestore se)
  final GetInternshipCategoryController internshipCategoryController = Get.put(
    GetInternshipCategoryController(),
  );

  @override
  void initState() {
    super.initState();
    // ⚡ Initialization ke waqt data fetch ho jayega controller ke through
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360, // Parent container ki height fix
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xff262626), // Dark background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // 🔹 Title text
          Text(
            "Explore Internship Category",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // 🔹 Subtitle text
          const Text(
            "Kickstart your career with top internships",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 🔹 Obx se categories list observe karna
          Obx(() {
            // ✅ Agar list abhi empty hai to loading text show karo
            if (internshipCategoryController.categories.isEmpty) {
              return const Center(
                child: Text(
                  "Loading Internship Categories... ",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            // 🔹 Middle index nikalna taake center card se start ho
            final middleIndex =
            (internshipCategoryController.categories.length / 2).floor();

            // 🔹 PageController banaya with middleIndex
            final pageController = PageController(
              viewportFraction: 0.65, // Chhoda card visible dikhane ke liye
              initialPage: middleIndex,
              // Center se start karna
            );

            return SizedBox(
              height: 250, // Cards container height
              child: PageView.builder(
                controller: pageController,
                itemCount: internshipCategoryController.categories.length,
                itemBuilder: (context, index) {
                  final category =
                  internshipCategoryController.categories[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔹 Category Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            // Placeholder jab tak image load ho
                            placeholder: (context, url) => Container(
                              height: 100,
                              color: Colors.grey.shade700,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            // Agar image fail ho jaye to error widget
                            errorWidget: (context, url, error) => Container(
                              height: 100,
                              color: Colors.grey.shade700,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.white, size: 40),
                            ),
                            imageUrl: category.categoryImage,
                            fit: BoxFit.cover,
                            height: 100,
                            width: double.infinity,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔹 Category Name
                        Center(
                          child: Text(
                            category.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Divider line
                        const Divider(color: Colors.grey),

                        const SizedBox(height: 15),

                        // 🔹 Apply Now button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: ElevatedButton(
                            onPressed: () {
                              // ✅ Navigate to internships list screen with category ID & Name
                              Get.toNamed(
                                "/categoryInternship",
                                arguments: {
                                  "id": category.categoryId,
                                  "name": category.categoryName,
                                },
                              );
                            },
                            child: const Text("Apply Now"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
