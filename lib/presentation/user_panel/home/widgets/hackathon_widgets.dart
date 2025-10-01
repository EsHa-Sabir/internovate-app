// File: lib/views/hackathon/latest_hackathons_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../common/widgets/snackbar_widget.dart';
import '../../../../controllers/hackathons/hackathon_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class LatestHackathonsWidget extends StatelessWidget {
  final HackathonController hackathonController = Get.put(
    HackathonController(),
  );

  LatestHackathonsWidget({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  Color _getStatusColor(String status) {
    if (status == 'Finished') {
      return Colors.grey.shade500;
    } else if (status == 'Live') {
      return Colors.red.shade600;
    } else {
      return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Latest Hackathons 🚀",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (hackathonController.isLoading.value) {
            return const Column(
              children: [
                SizedBox(height: 100,),
                Center(child: CupertinoActivityIndicator()),
                SizedBox(height: 20),
                Text(
                  "Loading...",
                  style: TextStyle(color: AppColors.hintColor, fontSize: 14),
                ),
              ],
            );
          } else if (hackathonController.hackathons.isEmpty) {
            return const Center(
              child: Text(
                'No hackathons available at the moment.',
                style: TextStyle(color: AppColors.hintColor),
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: hackathonController.hackathons.map((hackathon) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Image aur status banner ko Stack mein rakha gaya hai
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: hackathon.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: AppColors.hintColor.withOpacity(0.1),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: AppColors.hintColor.withOpacity(0.1),
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            // ✅ Updated Positioning for the Ribbon Banner
                            Positioned(
                              top: 18,
                              left: -35,
                              child: Transform.rotate(
                                angle: -0.785398, // -45 degrees in radians
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(hackathon.status),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    hackathon.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // ✅ Hackathon Chip ko top-right par place kiya gaya hai
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Chip(
                                label: Text(
                                  "HACKATHON",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hackathon.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hackathon.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.hintColor,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatDate(hackathon.startDate.toDate())} - ${_formatDate(hackathon.endDate.toDate())}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (hackathon.status != 'Finished')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (await canLaunchUrl(
                                        Uri.parse(hackathon.registrationLink),
                                      )) {
                                        await launchUrl(
                                          Uri.parse(hackathon.registrationLink),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        showSnackBar(
                                          "Error",
                                          'Could not launch URL',
                                          Colors.red,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.link,
                                      size: 18,
                                      color: AppColors.cardColor,
                                    ),
                                    label: Text(
                                      // ✅ Registration text ko "Register" kar diya gaya hai
                                      hackathon.status == 'Register'
                                          ? 'Register'
                                          : 'View',
                                      style: const TextStyle(
                                        color: AppColors.cardColor,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }
        }),
      ],
    );
  }
}