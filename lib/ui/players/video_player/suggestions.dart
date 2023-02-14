import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';

class VideoPlayerSuggestions extends StatefulWidget {
  const VideoPlayerSuggestions({
    required this.url,
    super.key});
  final String url;
  @override
  State<VideoPlayerSuggestions> createState() => VideoPlayerSuggestionsState();
}

class VideoPlayerSuggestionsState extends State<VideoPlayerSuggestions> {

  List<StreamInfoItem> relatedStreams = [];

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
    setState(() {
      relatedStreams.clear();
    });
    VideoExtractor.getRelatedStreams(widget.url).then((value) {
      setState(() {
        relatedStreams = value;
      });
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(((context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          child: StreamTileCollapsed(stream: relatedStreams[index]),
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

  List<StreamInfoItem>? get relatedStreams => _suggestionsState?.relatedStreams;

}