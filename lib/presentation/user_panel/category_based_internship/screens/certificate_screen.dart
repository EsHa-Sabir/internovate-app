import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/widgets/app_bar_widget.dart';
import '../../../../common/widgets/snackbar_widget.dart';
import '../../../../utils/constants/app_colors.dart';

class CertificateScreen extends StatefulWidget {
  final String internshipName;
  final String interneeName;

  const CertificateScreen({
    super.key,
    required this.internshipName,
    required this.interneeName,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBarWidget(
        title: "Your Certificate",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          scrollDirection: Axis.horizontal,
          child: RepaintBoundary(
            key: _certificateKey,
            child: AspectRatio(
              aspectRatio: 11 / 8.5, // standard certificate ratio
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(4, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 0),
                  child: Stack(
                    children: [
                      /// Watermark
                      Positioned.fill(
                        child: Center(
                          child: Opacity(
                            opacity: 0.07,
                            child: Icon(
                              Icons.school,
                              size: 260,
                              color: Colors.blueGrey.shade200,
                            ),
                          ),
                        ),
                      ),

                      /// Certificate Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Top Icon + Serial
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/logo/certificate_logo.png",width: 150,height: 150,),
                              Text(
                                "Certificate No: CERT-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          /// Title + Body
                          Column(
                            children: [

                              Text(
                                "CERTIFICATE OF COMPLETION",
                                style: GoogleFonts.cinzelDecorative(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                thickness: 2,
                                color: Colors.green.shade700,
                                indent: 50,
                                endIndent: 50,
                              ),
                              const SizedBox(height: 20),

                              Text(
                                "This is to certify that",
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                widget.interneeName,
                                style: GoogleFonts.greatVibes(
                                  fontSize: 42,
                                  color: Colors.blueGrey.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              Text(
                                "has successfully completed the internship program in",
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              Text(
                                widget.internshipName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10,)
                            ],
                          ),

                          /// Footer
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Signature
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Esha Sabir",
                                      style: GoogleFonts.greatVibes(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Container(
                                      width: 140,
                                      height: 1.5,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Authorized Signature",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),

                                /// Date + Seal
                                /// Date + Seal
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Official Seal Widget
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.amber, width: 2),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 30,
                                              color: Color(0xFFFFD700), // Sahi gold color
                                            ),
                                            Text(
                                              "Approved",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      /// Bottom Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _styledButton(
              icon: Icons.download,
              label: "Download",
              onPressed: _downloadCertificate,
            ),
            _styledButton(
              icon: Icons.share,
              label: "Share",
              onPressed: _shareCertificate,
            ),
          ],
        ),
      ),
    );
  }

  /// Button
  Widget _styledButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  /// --- DOWNLOAD CERTIFICATE ---
  Future<void> _downloadCertificate() async {
    final image = await _captureCertificate();
    if (image != null) {
      try {
        final directory = Directory("/storage/emulated/0/Download");
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final filePath =
            "${directory.path}/certificate_${DateTime.now().millisecondsSinceEpoch}.png";
        final file = File(filePath);
        await file.writeAsBytes(image);
        showSnackBar(
          "Success",
          "Certificate Download Successfully",
          Colors.green,
        );
      } catch (e) {
        showSnackBar("Error", "Download failed: $e", Colors.red);
      }
    }
  }

  /// --- SHARE CERTIFICATE ---
  Future<void> _shareCertificate() async {
    final image = await _captureCertificate();
    if (image != null) {
      final directory = (await getTemporaryDirectory()).path;
      final file = File('$directory/certificate.png');
      await file.writeAsBytes(image);
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
        "I completed the ${widget.internshipName} internship! Check out my certificate.",
      );
    } else {
      showSnackBar(
        "Error",
        "Failed to generate certificate for sharing.",
        Colors.red,
      );
    }
  }

  /// --- CAPTURE CERTIFICATE AS IMAGE ---
  Future<Uint8List?> _captureCertificate() async {
    try {
      RenderRepaintBoundary boundary =
      _certificateKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing certificate: $e");
      return null;
    }
  }
}
