import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';

class VideoPlayerSuggestions extends StatefulWidget {
  const VideoPlayerSuggestions({
    required this.url,
    super.key});
  final String? url;
  @override
  State<VideoPlayerSuggestions> createState() => VideoPlayerSuggestionsState();
}

class VideoPlayerSuggestionsState extends State<VideoPlayerSuggestions> {

  List<dynamic> relatedStreams = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSuggestions();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerSuggestions oldWidget) {
    if (oldWidget.url != widget.url) {
      loadSuggestions();
    }
    super.didUpdateWidget(oldWidget);
  }

  void loadSuggestions() {
    if (widget.url == null) {
      return;
    }
    setState(() {
      relatedStreams.clear();
    });
    VideoExtractor.getRelatedStreams(widget.url!).then((value) {
      relatedStreams = value;
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      // Remove first item if it's the one currently playing
      if (contentProvider.playingContent!.infoItem == relatedStreams.first) {
        relatedStreams.removeAt(0);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    contentProvider.playingContent!.videoSuggestionsController._addState(this);
    return relatedStreams.isNotEmpty
      ? _suggestionsList()
      : _suggestionsShimmer();
  }

  Widget _suggestionsList() {
    final list = relatedStreams;
    return SliverList(
      delegate: SliverChildBuilderDelegate(((context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          child: InfoItemRenderer(infoItem: relatedStreams[index], expandItem: false),
        );
      }), childCount: relatedStreams.length),
    );
  }

  Widget _suggestionsShimmer() {
    return const SliverToBoxAdapter(child: SizedBox());
  }

}

class VideoSuggestionsController {

  VideoPlayerSuggestionsState? _suggestionsState;

  void _addState(VideoPlayerSuggestionsState state) {
    _suggestionsState = state;
  }

  List<dynamic>? get relatedStreams => _suggestionsState?.relatedStreams;

}