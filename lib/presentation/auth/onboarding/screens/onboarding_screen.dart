import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intern_management_app/utils/constants/app_images.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  // 1️⃣ List of onboarding pages with image, title, description
  final List<Map<String, String>> pages = [
    {
      "image": onboard1,
      "title": "Welcome to Internee",
      "desc": "Track your tasks and monitor your progress with ease. Stay on top of your goals and never miss a deadline again.",
    },
    {
      "image": onboard2,
      "title": "Stay Organized",
      "desc": "Keep all your tasks, notes, and deadlines in one place. Organize your day efficiently and manage your time like a pro.",
    },
    {
      "image": onboard3,
      "title": "Achieve More",
      "desc": "Boost your productivity with smart tools that help you prioritize tasks, focus better, and achieve your goals faster.",
    },
  ];

  // 2️⃣ Current index of the carousel slider
  int currentIndex = 0;

  // 3️⃣ Controller for CarouselSlider (to control slides programmatically if needed)
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: Get.height * 0.05),

              // 4️⃣ CarouselSlider widget showing onboarding pages
              CarouselSlider(
                carouselController: _controller,
                items: pages.map((page) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page["image"]!, height: Get.height * 0.27), // Image
                      const SizedBox(height: 20),
                      Text(
                        page["title"]!, // Title text
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          page["desc"]!, // Description text
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                // 5️⃣ Carousel options
                options: CarouselOptions(
                  height: Get.height * 0.67,
                  autoPlay: true,                 // Auto slide every 2 seconds
                  viewportFraction: 1,            // Show one slide at a time
                  enlargeCenterPage: false,
                  autoPlayInterval: const Duration(seconds: 2),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;       // Update current index for dots indicator
                    });
                  },
                ),
              ),

              // 6️⃣ Dots indicator to show current slide position
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex == index ? 20 : 8, // Wider dot for active slide
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? AppColors.primary             // Active dot color
                          : Colors.grey.shade400,         // Inactive dot color
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 7️⃣ Floating action button to navigate to sign-in options screen
      floatingActionButton: SizedBox(
        height: Get.height * 0.06,
        width: Get.width * 0.8,
        child: ElevatedButton(
          onPressed: () {
            Get.offNamed("/signInOptions"); // Navigate to Sign In Options
          },
          child: const Text("Get Started"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
