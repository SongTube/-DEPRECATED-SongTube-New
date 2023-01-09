import 'package:flutter/material.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';
import 'package:songtube/ui/players/video_player/video_content.dart';

class VideoPlayerPlaylistContent extends StatefulWidget {
  const VideoPlayerPlaylistContent({
    required this.content,
    super.key});
  final ContentWrapper content;

  @override
  State<VideoPlayerPlaylistContent> createState() => _VideoPlayerPlaylistContentState();
}

class _VideoPlayerPlaylistContentState extends State<VideoPlayerPlaylistContent> {

  // Video Suggestions Controller
  VideoSuggestionsController videoSuggestionsController = VideoSuggestionsController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.bottomCenter,
      children: [
        // Video Content
        VideoPlayerContent(content: widget.content),
        // Playlist Content
        _playlistContent()
      ],
    );
  }

  Widget _playlistContent() {
    return Column(
      children: [

      ],
    );
  }
}