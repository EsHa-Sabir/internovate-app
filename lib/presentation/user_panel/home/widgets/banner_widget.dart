import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../controllers/banner/banner_controller.dart';

class BannerWidget extends StatelessWidget {
  BannerWidget({super.key});

  // 🔹 BannerController for managing banners fetched from Firestore
  final BannerController bannerController = Get.put(BannerController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ UI automatically updates when banners list changes
      return CarouselSlider(
        options: CarouselOptions(
          height: 200, // Banner height
          autoPlay: true, // Auto-slide banners
          enlargeCenterPage: true, // Focus effect on center banner
          viewportFraction: 0.94, // Slight margin between banners
        ),

        // 🔹 Map banners into carousel items
        items: bannerController.banners.map((banner) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            elevation: 10, // Card shadow
            clipBehavior: Clip.antiAlias, // Ensures image respects rounded corners
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 🔹 CachedNetworkImage (loads directly without loader placeholder)
                CachedNetworkImage(
                  imageUrl: banner.bannerImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,

                  // ✅ Placeholder jab tak image load ho rahi hai
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: CupertinoActivityIndicator()
                    ),
                  ),

                  // ✅ Error Widget agar image load na ho
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade700,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                // 🔹 Gradient overlay for text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6), // Dark bottom
                        Colors.transparent, // Fade to transparent top
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                // 🔹 Banner Title & Description
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Text
                      Text(
                        banner.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Description Text
                      Text(
                        banner.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
