// lib/screens/ai_courses/final_course_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intern_management_app/common/widgets/app_bar_widget.dart';
import 'package:intern_management_app/controllers/ai_courses/ai_course_controller.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';
import 'full_video_screen.dart'; // 👈 new screen import

class FinalCourseView extends StatefulWidget {
  const FinalCourseView({Key? key}) : super(key: key);

  @override
  State<FinalCourseView> createState() => _FinalCourseViewState();
}

class _FinalCourseViewState extends State<FinalCourseView> {
  final AICourseController _controller = Get.find();

  // No need for YoutubePlayerController here
  // String? _currentVideoId; // No need for this state variable here
  // bool _isVideoEnded = false; // No need for this state variable here

  @override
  void dispose() {
    _controller.currentChapterIndex.value = 0; // cleanup
    super.dispose();
  }

  // No need for _ensureVideoController and _cleanUp functions here

  // -------- content rendering helpers (same as before) --------
  List<Widget> _buildContentWidgets(String content) {
    final lines = content.trim().split('\n');
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    String codeBuffer = '';
    int orderedListNumber = 1;

    for (var line in lines) {
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(_buildCodeBlock(codeBuffer.trim()));
          codeBuffer = '';
        }
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        codeBuffer += '$line\n';
        continue;
      }
      if (line.startsWith('###')) {
        widgets.add(_buildHeading(line.substring(3).trim(), 3));
        orderedListNumber = 1;
      } else if (line.startsWith('##')) {
        widgets.add(_buildHeading(line.substring(2).trim(), 2));
        orderedListNumber = 1;
      } else if (line.startsWith('#')) {
        widgets.add(_buildHeading(line.substring(1).trim(), 1));
        orderedListNumber = 1;
      } else if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        widgets.add(_buildListItem(line.substring(2).trim()));
        orderedListNumber = 1;
      } else if (RegExp(r'^\d+\. ').hasMatch(line.trim())) {
        widgets.add(_buildListItem(
          line.substring(line.indexOf('.') + 1).trim(),
          isBulleted: false,
          number: orderedListNumber,
        ));
        orderedListNumber++;
      } else if (line.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SelectableText.rich(
              TextSpan(
                children: _parseInlineText(line),
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: AppColors.textColor),
              ),
            ),
          ),
        );
        orderedListNumber = 1;
      }
    }
    return widgets;
  }

  Widget _buildHeading(String text, int level) {
    TextStyle style;
    switch (level) {
      case 1:
        style = const TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary);
        break;
      case 2:
        style = const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textColor);
        break;
      case 3:
        style = const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textColor);
        break;
      default:
        style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SelectableText(text, style: style),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hintColor.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code.trim(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: AppColors.accentColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String text, {bool isBulleted = true, int? number}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBulleted ? '• ' : '$number. ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isBulleted ? AppColors.primary : AppColors.textColor,
            ),
          ),
          Expanded(
            child: SelectableText.rich(
              TextSpan(
                children: _parseInlineText(text),
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: AppColors.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseInlineText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*[^\*]+\*\*|`[^`]+`)');
    int lastMatchEnd = 0;
    for (var match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: AppColors.textColor)));
      }
      String matched = match.group(0)!;
      TextStyle style = const TextStyle();
      if (matched.startsWith('**') && matched.endsWith('**')) {
        style = const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.textColor);
        matched = matched.substring(2, matched.length - 2);
      } else if (matched.startsWith('`') && matched.endsWith('`')) {
        style =
        const TextStyle(fontFamily: 'monospace', color: AppColors.accentColor);
        matched = matched.substring(1, matched.length - 1);
      }
      spans.add(TextSpan(text: matched, style: style));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastMatchEnd),
          style: const TextStyle(color: AppColors.textColor)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: "Course Content",
        isLeading: true,
        backgroundColor: AppColors.primary,
        onLeadingPressed: () {
          Get.back(); // no cleanup needed here
        },
      ),
      body: Obx(() {
        final course = _controller.currentCourse.value;
        final chapters = _controller.currentCourseChapters;

        if (course == null) {
          return const Center(child: Text("No course selected"));
        }
        if (chapters.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryLight),
          );
        }

        final index = _controller.currentChapterIndex.value;
        if (index < 0 || index >= chapters.length) {
          return const Center(child: Text("Invalid chapter index"));
        }

        final chapter = chapters[index];
        final videoId = YoutubePlayer.convertUrlToId(chapter.videoUrl ?? '');

        return Column(
          children: [
            // 🔹 Chapters List
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: chapters.length,
                itemBuilder: (context, i) {
                  final selected = i == index;
                  return GestureDetector(
                    onTap: () => _controller.selectChapter(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.hintColor.withOpacity(0.3),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              chapters[i].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight:
                                selected ? FontWeight.bold : FontWeight.w600,
                                color: selected
                                    ? AppColors.textColor
                                    : AppColors.hintColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chapters[i].durationMinutes > 0
                                ? "${chapters[i].durationMinutes} min"
                                : "⏱",
                            style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? AppColors.textColor
                                  : AppColors.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          

            // 🔹 Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // 🔹 Video Thumbnail with Play Button
            if (course.includesVideo &&
                chapter.videoUrl != null &&
                chapter.videoUrl!.isNotEmpty &&
                videoId != null)
              GestureDetector(
                onTap: () {
                  Get.to(() => FullVideoScreen(
                    videoId: videoId,
                    // Yeh property pass karna zaroori hai
                  ));
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20, top: 20,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.hintColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        YoutubePlayer.getThumbnail(
                          videoId: videoId,
                          quality: ThumbnailQuality.high,
                        ),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          height: 220,
                          child: Center(
                            child: Text("Thumbnail not available"),
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (course.includesVideo)
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text("Video not available or invalid URL."),
                  ),
                ),
              ),
                    Text(
                      chapter.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "⏱ ${chapter.durationMinutes} minutes",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: AppColors.hintColor.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: chapter.hasContent
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildContentWidgets(chapter.content),
                        )
                            : const Text("No content available for this chapter"),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
