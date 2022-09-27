import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:ionicons/ionicons.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:transparent_image/transparent_image.dart';

class PlaylistTileCollapsed extends StatelessWidget {
  const PlaylistTileCollapsed({
    required this.playlist,
    super.key});
  final PlaylistInfoItem playlist;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PlaylistTileExpanded extends StatelessWidget {
  const PlaylistTileExpanded({
    required this.playlist,
    super.key});
  final PlaylistInfoItem playlist;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return CustomInkWell(
      onTap: () {
        uiProvider.currentPlayer = CurrentPlayer.video;
        contentProvider.loadVideoPlayer(playlist);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: _thumbnail(context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: _details(context),
          )
        ],
      ),
    );
  }

  Widget _thumbnail(context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ImageFade(
          fadeDuration: const Duration(milliseconds: 300),
          placeholder: Container(color: Theme.of(context).cardColor),
          image: NetworkImage(playlist.thumbnailUrl!),
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)
            )
          ),
          height: 25,
          child: const Center(
            child: Icon(Ionicons.musical_notes_outline,
              color: Colors.white, size: 20),
          ),
        )
      ],
    );
  }

  Widget _details(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(100)
          ),
          child: Icon(
            Icons.playlist_play_outlined,
            color: Theme.of(context).iconTheme.color,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${playlist.name}",
                  maxLines: 2,
                  style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "",
                  style: tinyTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

}