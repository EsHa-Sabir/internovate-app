import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/controllers/internship/internship_controller.dart';
import 'package:intern_management_app/models/internship/internship_model.dart';
import '../../../../utils/constants/app_colors.dart';

class CategoryBasedInternship extends StatefulWidget {
  const CategoryBasedInternship({super.key});

  @override
  State<CategoryBasedInternship> createState() =>
      _CategoryBasedInternshipState();
}

class _CategoryBasedInternshipState extends State<CategoryBasedInternship> {
  // 1️⃣ Category ID aur name store karne ke liye variables
  late String categoryId;
  late String categoryName;

  // 2️⃣ Internship controller GetX se inject karna
  final InternshipController internshipController =
  Get.put(InternshipController());

  @override
  void initState() {
    super.initState();
    // 3️⃣ Screen arguments se category details lena
    final args = Get.arguments as Map<String, dynamic>;
    categoryId = args["id"];
    categoryName = args["name"];

    // 4️⃣ Controller se internships load karna specific category ki
    internshipController.loadInternships(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 5️⃣ Custom AppBar with category name
      appBar: AppBarWidget(
        title: categoryName,
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),

      // 6️⃣ Body me reactive UI (Obx) lagaya hai jo internships observe karega
      body: Obx(() {
        // 6.1 Agar data loading ho raha hai to loader show karo
        if (internshipController.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        // 6.2 Agar internships list empty hai to "No internships found" show karo
        if (internshipController.internships.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_off_outlined,
                  size: 60,
                  color: Colors.green,
                ),
                SizedBox(height: 15),
                Text(
                  "No internships found",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // 6.3 Agar internships available hain to GridView show karo
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: internshipController.internships.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.63, // card height control
          ),
          itemBuilder: (context, index) {
            // 7️⃣ Ek internship model get karo
            final InternshipModel internship =
            internshipController.internships[index];

            // 8️⃣ Har internship ka card banao
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  // 9️⃣ Internship Image show with CachedNetworkImage
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: internship.internshipImage ?? "",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      // Placeholder jab tak image load ho
                      placeholder: (context, url) => Container(
                        height: 100,
                        color: Colors.grey.shade700,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      // Agar image load na ho to error widget show karo
                      errorWidget: (context, url, error) => Container(
                        height: 100,
                        color: Colors.grey.shade700,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ),

                  // 🔟 Internship Details section
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 10.1 Internship Name
                        Text(
                          internship.internshipName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // 10.2 Internship Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                internship.location,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // 10.3 Internship Duration
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                internship.duration,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),

                        // 10.4 Apply Now Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(
                                "/internshipApplication",
                                arguments: {
                                  "categoryId": categoryId, // Current category ka id
                                  "internshipId": internship.internshipId, // Internship ka id
                                  "internshipName": internship.internshipName, // Internship ka name
                                },
                              );
                            },
                            child: const Text("Apply Now"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
