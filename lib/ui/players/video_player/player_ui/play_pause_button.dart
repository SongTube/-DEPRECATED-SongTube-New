import 'package:flutter/material.dart';

class VideoPlayerPlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function() onPlayPause;
  const VideoPlayerPlayPauseButton({
    required this.isPlaying,
    required this.onPlayPause,
    Key? key
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPlayPause,
      borderRadius: BorderRadius.circular(100),
      child: Ink(
        padding: const EdgeInsets.all(16.0),
        child: isPlaying
          ? const Icon(
              Icons.pause,
              size: 32,
              color: Colors.white,
            )
          : const Icon(
              Icons.play_arrow,
              size: 32,
              color: Colors.white,
            ),
      ),
    );
  }
}