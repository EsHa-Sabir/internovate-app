// lib/screens/ai_courses/full_video_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intern_management_app/utils/constants/app_colors.dart';

class FullVideoScreen extends StatefulWidget {
  final String videoId;

  const FullVideoScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<FullVideoScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<FullVideoScreen> {
  late YoutubePlayerController _controller;
  bool _isVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: false,
        loop: false,
      ),
    )..addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller.value.playerState == PlayerState.ended) {
      setState(() {
        _isVideoEnded = true;
      });
    } else {
      if (_isVideoEnded) {
        setState(() {
          _isVideoEnded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _seekTo(int seconds) {
    final newPosition = _controller.value.position + Duration(seconds: seconds);
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.hintColor,
        ),
        bottomActions: [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          Expanded(
            child: ProgressBar(

              colors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.primary,
                backgroundColor: AppColors.hintColor,
              ),
            ),
          ),
          RemainingDuration(),
          const SizedBox(width: 14.0),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: player,
              ),
              // Cross button ko video ke uper nahi, balkay screen ke top left me rakha gaya hai
              Positioned(
                top: 40, // Top margin barhaya
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Get.back(),
                ),
              ),
              if (_isVideoEnded)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        style: ButtonStyle(
                          backgroundColor:
                          WidgetStateProperty.all(AppColors.primary),
                          shape:
                          WidgetStateProperty.all(const CircleBorder()),
                        ),
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                        },
                      ),
                    ),
                  ),
                ),
              // 10 sec forward aur backward buttons ko video ke neechay show kiya gaya hai
              if (!_isVideoEnded)
                Positioned(
                  bottom: 200,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 32),
                        onPressed: () => _seekTo(-10),
                      ),
                      const SizedBox(width: 48),
                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 32),
                        onPressed: () => _seekTo(10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}