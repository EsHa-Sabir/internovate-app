import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/common/widgets/snackbar_widget.dart';
import 'package:intern_management_app/models/resume/resume_model.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../../controllers/resume/resume_builder_controller.dart';
import '../../../../services/database/resume/pdf_generator.dart';

class PdfViewScreen extends StatefulWidget {
  final Resume resumeData;

  // Constructor me resume data pass kiya jata hai
  const PdfViewScreen({super.key, required this.resumeData});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final ResumeBuilderController _controller = ResumeBuilderController();
  bool _isSaving = false; // Button disable/loader state control ke liye

  String? _publicId;
  Future<File>? _pdfFile; // Locally generated PDF file ka future

  @override
  void initState() {
    super.initState();
    // Screen load hote hi PDF generate hoti hai
    _pdfFile = _generateLocalPdfFile();
  }

  /// Locally temporary directory me PDF file generate karne ka function
  Future<File> _generateLocalPdfFile() async {
    final pdf = await PdfGenerator.generatePdf(widget.resumeData); // PDF banani
    final bytes = await pdf.save(); // PDF ko bytes me save karna
    final output = await getTemporaryDirectory(); // Temporary folder path
    final file = File('${output.path}/my_resume.pdf');
    await file.writeAsBytes(bytes); // File create
    return file;
  }

  /// Save to Cloudinary button function
  void _saveToCloudinary() async {
    setState(() => _isSaving = true);
    try {
      final pdfFile = await _pdfFile!;
      await _controller.savePdfToCloudinary(pdfFile.path); // Cloudinary upload
      showSnackBar("Success", "Resume saved successfully!", AppColors.primary);
    } catch (e) {
      showSnackBar("Failed", "Failed to save resume", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Download PDF locally button function
  void _downloadPdf() async {
    setState(() => _isSaving = true);
    try {
      await PdfGenerator.generateAndSavePdf(widget.resumeData);
      showSnackBar("Success", "PDF downloaded successfully", AppColors.primary);
    } catch (e) {
      showSnackBar("Failed", "Failed to download pdf", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Share PDF button function
  void _sharePdf() async {
    setState(() => _isSaving = true);
    try {
      await PdfGenerator.generateAndSharePdf(widget.resumeData);
    } catch (e) {
      showSnackBar("Failed", "Failed to share pdf", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBarWidget(
        title: "Generated Resume",
        isLeading: true,
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<File>(
        future: _pdfFile, // Future jo PDF generate karta hai
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Jab tak PDF generate ho rahi ho → loader show karo
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "Generating your resume...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Please wait, this might take a moment.",
                    style: TextStyle(
                      color: AppColors.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Agar PDF generation me error aaye
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            // Agar PDF successfully generate ho gayi
            return Column(
              children: [
                // Resume preview widget
                Expanded(
                  child: PdfPreview(
                    build: (format) => snapshot.data!.readAsBytes(),
                    pdfFileName: 'my_resume.pdf',
                    canChangePageFormat: false,
                    canDebug: false,
                    loadingWidget: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(color: AppColors.primary,),
                          SizedBox(height: 10),
                          Text(
                            "Rendering PDF...",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                    ),

                  ),
                ),
                // Bottom action buttons (Save, Download, Share)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.save,
                        label: 'Save',
                        onPressed: _saveToCloudinary,
                      ),
                      _buildActionButton(
                        icon: Icons.download,
                        label: 'Download',
                        onPressed: _downloadPdf,
                      ),
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: _sharePdf,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Agar snapshot empty aaye
            return const Center(
              child: Text(
                'No PDF data available.',
                style: TextStyle(color: AppColors.textColor),
              ),
            );
          }
        },
      ),
    );
  }

  /// Reusable widget jo ek button create karta hai with icon + label
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: _isSaving ? null : onPressed, // Jab save ho raha ho to disable
          icon: Icon(icon, color: AppColors.primary, size: 30),
        ),
        Text(label, style: const TextStyle(color: AppColors.textColor)),
      ],
    );
  }
}
