// lib/services/database/resume/pdf_generator.dart

import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/resume/certification.dart';
import '../../../models/resume/education.dart';
import '../../../models/resume/project.dart';
import '../../../models/resume/resume_model.dart';
import '../../../models/resume/work_experience.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  // Fonts ko ek baar load kar ke cache karein
  static Future<pw.Font> get _robotoRegular async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> get _robotoBold async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<void> generateAndSavePdf(Resume resumeData) async {
    final pdf = await generatePdf(resumeData);
    final bytes = await pdf.save();
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/my_resume.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }

  static Future<void> generateAndSharePdf(Resume resumeData) async {
    final pdf = await generatePdf(resumeData);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'my_resume.pdf');
  }

  static Future<pw.Document> generatePdf(Resume resumeData) async {
    final pdf = pw.Document();

    // Fonts ko load karna
    final robotoRegular = await _robotoRegular;
    final robotoBold = await _robotoBold;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return [
            _buildHeaderSection(resumeData, robotoBold, robotoRegular),
            pw.Divider(color: PdfColors.black),
            _buildMainContent(resumeData, robotoBold, robotoRegular),
          ];
        },
      ),
    );
    return pdf;
  }

  static pw.Widget _buildHeaderSection(
      Resume resumeData,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          resumeData.name.toUpperCase(),
          style: pw.TextStyle(font: boldFont, fontSize: 20),
        ),
        pw.SizedBox(height: 7),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (resumeData.email.isNotEmpty)
              _buildContactLink('Email: ', resumeData.email, regularFont),
            if (resumeData.linkedin.isNotEmpty)
              _buildContactLink('LinkedIn: ', resumeData.linkedin, regularFont),
            if (resumeData.twitter.isNotEmpty)
              _buildContactLink('Portfolio: ', resumeData.twitter, regularFont),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMainContent(
      Resume resumeData,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (resumeData.summary.isNotEmpty) ...[
          _buildSectionTitle('PROFESSIONAL SUMMARY', boldFont),
          pw.SizedBox(height: 6),
          _buildProfessionalSummarySection(resumeData.summary, regularFont),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.education.isNotEmpty) ...[
          _buildSectionTitle('EDUCATION', boldFont),
          pw.SizedBox(height: 6),
          _buildEducationSection(resumeData.education, boldFont, regularFont),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.skills.isNotEmpty) ...[
          _buildSectionTitle('SKILLS SUMMARY', boldFont),
          pw.SizedBox(height: 6),
          _buildSkillsSection(resumeData.skills, boldFont, regularFont),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.workExperience.isNotEmpty) ...[
          _buildSectionTitle('WORK EXPERIENCE', boldFont),
          pw.SizedBox(height: 6),
          _buildWorkExperienceSection(
            resumeData.workExperience,
            boldFont,
            regularFont,
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.projects.isNotEmpty) ...[
          _buildSectionTitle('PROJECTS', boldFont),
          pw.SizedBox(height: 6),
          _buildProjectsSection(resumeData.projects, boldFont, regularFont),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.certifications.isNotEmpty) ...[
          _buildSectionTitle('CERTIFICATES', boldFont),
          pw.SizedBox(height: 6),
          _buildCertificationsSection(
            resumeData.certifications,
            boldFont,
            regularFont,
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.black),
        ],
        if (resumeData.languagesSpoken.isNotEmpty) ...[
          _buildSectionTitle('LANGUAGES SPOKEN', boldFont),
          pw.SizedBox(height: 6),
          pw.Text(
            resumeData.languagesSpoken,
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
          pw.SizedBox(height: 4),
        ],
      ],
    );
  }

  static pw.Widget _buildContactLink(String text, String url, pw.Font font) {
    return pw.Row(
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.black),
        ),
        pw.UrlLink(
          destination: url,
          child: pw.Text(
            url,
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.blue900,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font boldFont) {
    return pw.Center(
      child: pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 11)),
    );
  }

  static pw.Widget _buildEducationSection(
      List<Education> education,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: education.map((edu) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    edu.university,
                    style: pw.TextStyle(font: boldFont, fontSize: 10),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    edu.title,
                    style: pw.TextStyle(font: regularFont, fontSize: 10),
                  ),
                ],
              ),
              pw.Text(
                '${edu.startDate} - ${edu.endDate}',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildSkillsSection(
      String skills,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    final skillLines = skills
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skillLines.map((line) {
        final parts = line.split(':');
        return pw.Row(
          children: [
            pw.Text(
              '•  ${parts[0].trim()}: ',
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
            pw.Expanded(
              child: pw.Text(
                parts.length > 1 ? parts.sublist(1).join(':').trim() : '',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildProfessionalSummarySection(
      String summary,
      pw.Font regularFont,
      ) {
    return pw.Text(
      summary,
      textAlign: pw.TextAlign.justify,
      style: pw.TextStyle(font: regularFont, fontSize: 10),
    );
  }

  static pw.Widget _buildWorkExperienceSection(
      List<Experience> workExperience,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: workExperience.map((exp) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  exp.title.toUpperCase(),
                  style: pw.TextStyle(font: boldFont, fontSize: 10),
                ),
                pw.Text(
                  "${exp.startDate} - ${exp.endDate}",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            _buildBulletPoints(exp.description, regularFont),
            pw.SizedBox(height: 6),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildProjectsSection(
      List<Project> projects,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: projects.map((proj) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  proj.title.toUpperCase(),
                  style: pw.TextStyle(font: boldFont, fontSize: 10),
                ),
                if ((proj.projectLink ?? '').isNotEmpty) ...[
                  pw.Text(
                    ' | ',
                    style: pw.TextStyle(font: boldFont, fontSize: 10),
                  ),
                  pw.UrlLink(
                    destination: proj.projectLink!,
                    child: pw.Text(
                      'LINK',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                        color: PdfColors.blue900,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            pw.SizedBox(height: 5),
            _buildBulletPoints(proj.summary, regularFont),
            pw.SizedBox(height: 6),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildCertificationsSection(
      List<Certification> certifications,
      pw.Font boldFont,
      pw.Font regularFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: certifications.map((cert) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  cert.title,
                  style: pw.TextStyle(font: boldFont, fontSize: 10),
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      cert.organization,
                      style: pw.TextStyle(font: regularFont, fontSize: 10),
                    ),
                    pw.SizedBox(width: 12),
                    pw.UrlLink(
                      destination: cert.link,
                      child: pw.Text(
                        'LINK',
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                          color: PdfColors.blue900,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 6),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildBulletPoints(String text, pw.Font font) {
    final lines = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => pw.Row(
          children: [
            pw.Text(
              '• ',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Text(
                line.trim(),
                style: pw.TextStyle(font: font, fontSize: 10),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          ],
        ),
      )
          .toList(),
    );
  }
}