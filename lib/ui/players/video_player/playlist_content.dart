import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/components/slideable_panel.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';
import 'package:songtube/ui/players/video_player/video_content.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';

class VideoPlayerPlaylistContent extends StatefulWidget {
  const VideoPlayerPlaylistContent({
    required this.content,
    super.key});
  final ContentWrapper content;
  @override
  State<VideoPlayerPlaylistContent> createState() => _VideoPlayerPlaylistContentState();
}

class _VideoPlayerPlaylistContentState extends State<VideoPlayerPlaylistContent> {

  SlidablePanelController? panelController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.bottomCenter,
      children: [
        // Video Content
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: VideoPlayerContent(content: widget.content),
        ),
        // Playlist Content
        LayoutBuilder(
          builder: (context, constraints) => SlidablePanel(
            onControllerCreate: (controller) {
              panelController = controller;
            },
            enableBackdrop: true,
            collapsedColor: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
            backdropColor: Theme.of(context).cardColor,
            backdropOpacity: 1,
            color: Theme.of(context).scaffoldBackgroundColor,
            maxHeight: constraints.maxHeight,
            child: panelController == null ? const SizedBox() : _currentPlaylist(),

          ),
        ),
      ],
    );
  }
  
  Widget _currentPlaylist() {
    ContentProvider contentProvider = Provider.of<ContentProvider>(context);
    final nextVideo = contentProvider.nextPlaylistVideo;
    bool hasNextVideo = nextVideo != null;
    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 0, right: 0),
      child: Column(
        children: [
          // Playlist Details
          SizedBox(
            height: kToolbarHeight*1.5-32,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: panelController!.animationController,
                  builder: (context, snapshot) {
                    return BottomSheetPhill(
                      color: ColorTween(begin: Colors.white.withOpacity(0.6), end: Colors.grey.withOpacity(0.2)).animate(panelController!.animationController).value,
                    );
                  }
                ),
                const SizedBox(height: 8),
                // Next to play
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Ionicons.list, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: panelController!.animationController,
                        builder: (context, child) {
                          final textColor = ColorTween(begin: Colors.white, end: Theme.of(context).textTheme.bodyText1!.color).animate(panelController!.animationController).value;
                          final subTextColor = ColorTween(begin: Colors.white.withOpacity(0.6), end: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.7)).animate(panelController!.animationController).value;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.content.playlistDetails == null ? 'Loading playlist...' : hasNextVideo ? 'Next: ${nextVideo.name}' : 'Playlist reached the end', maxLines: 1, style: smallTextStyle(context, bold: true).copyWith(color: textColor), overflow: TextOverflow.ellipsis),
                              Text('${(widget.content.infoItem as PlaylistInfoItem).name}', maxLines: 1, style: tinyTextStyle(context, opacity: 0.7).copyWith(color: subTextColor), overflow: TextOverflow.ellipsis),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: kToolbarHeight*1.5-46,
                      child: IconButton(
                        onPressed: () {
                          final containsPlaylist = contentProvider.streamPlaylists.any((element) => element.name == widget.content.playlistDetails?.name);
                          if (containsPlaylist) {
                            contentProvider.streamPlaylistRemove(widget.content.playlistDetails!.name!);
                          } else {
                            contentProvider.streamPlaylistCreate(widget.content.playlistDetails!.name!, widget.content.playlistDetails!.uploaderName!, widget.content.playlistDetails!.streams!);
                          }
                        },
                        icon: AnimatedBuilder(
                          animation: panelController!.animationController,
                          builder: (context, snapshot) {
                            final containsPlaylist = contentProvider.streamPlaylists.any((element) => element.name == widget.content.playlistDetails?.name);
                            final color = containsPlaylist
                              ? ColorTween(begin: Colors.white, end: Colors.red).animate(panelController!.animationController).value
                              : ColorTween(begin: Colors.white.withOpacity(0.6), end: Theme.of(context).iconTheme.color).animate(panelController!.animationController).value;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(containsPlaylist ? Ionicons.heart : Ionicons.heart_outline, key: ValueKey(containsPlaylist), size: 20, color: color));
                          }
                        )
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          // Playlist Videos
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.content.playlistDetails != null ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 16, right: 16),
                itemCount: widget.content.playlistDetails!.streams!.length,
                itemBuilder: (context, index) {
                  final stream = widget.content.playlistDetails!.streams![index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: widget.content.selectedPlaylistIndex == index ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.all(8),
                    child: StreamTileCollapsed(
                      onTap: () {
                        contentProvider.loadNextPlaylistVideo(override: stream);
                      },
                      stream: stream));
                },
              ) : const SizedBox(),
            ),
          )
        ],
      ),
    );
  }

}