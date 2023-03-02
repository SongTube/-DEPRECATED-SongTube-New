import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:ionicons/ionicons.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/sheets/info_item_options.dart';
import 'package:songtube/ui/text_styles.dart';

class PlaylistTileCollapsed extends StatelessWidget {
  const PlaylistTileCollapsed({
    required this.playlist,
    this.isEditable = true,
    super.key});
  final PlaylistInfoItem playlist;
  final bool isEditable;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return CustomInkWell(
      onTap: isEditable ? () {
        uiProvider.currentPlayer = CurrentPlayer.video;
        contentProvider.loadVideoPlayer(playlist);
        uiProvider.fwController.open();
      } : () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AspectRatio(
                    aspectRatio: 16/9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: playlist.thumbnailUrl != null ? ImageFade(
                        fadeDuration: const Duration(milliseconds: 300),
                        placeholder: const ShimmerContainer(height: null, width: null),
                        image: NetworkImage(playlist.thumbnailUrl!),
                        fit: BoxFit.fitWidth,
                      ) : Container(color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 25,
                      width: double.infinity,
                      padding: const EdgeInsets.all(3).copyWith(left: 8, right: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)
                        )
                      ),
                      child: Center(child: Icon(Ionicons.list, color: Theme.of(context).iconTheme.color, size: 16))
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 8, right: 8,
                    top: 4, bottom: 4),
                  child: Text(
                    playlist.name ?? '',
                    style: smallTextStyle(context),
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "${playlist.uploaderName}",
                    style: tinyTextStyle(context, opacity: 0.7),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "${playlist.streamCount} videos",
                    style: tinyTextStyle(context, opacity: 0.7),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: internalNavigatorKey.currentContext!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => InfoItemOptions(infoItem: playlist));
            },
            icon: Icon(Icons.more_vert, size: 18, color: Theme.of(context).iconTheme.color)
          )
        ],
      ),
    );
  }
}

class PlaylistTileExpanded extends StatelessWidget {
  const PlaylistTileExpanded({
    required this.playlist,
    this.onTapOverride,
    super.key});
  final PlaylistInfoItem playlist;
  /// Use this override in case you want to execute another
  /// action when tapping this tile on the parent elements
  final Function()? onTapOverride;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return CustomInkWell(
      onTap: onTapOverride ?? () {
        uiProvider.currentPlayer = CurrentPlayer.video;
        contentProvider.loadVideoPlayer(playlist);
        uiProvider.fwController.open();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
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
      fit: StackFit.expand,
      alignment: Alignment.bottomCenter,
      children: [
        CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (context, _) {
            return Container(color: Theme.of(context).cardColor.withOpacity(0.6));
          },
          imageUrl: playlist.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          errorWidget: (context, error, stackTrace) =>
            Container(color: Theme.of(context).cardColor),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 25,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.7),
            ),
            child: const Center(child: Icon(Ionicons.list, size: 20, color: Colors.white)),
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
          height: 50, width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(100)
          ),
          child: Icon(Ionicons.list, size: 20, color: Theme.of(context).iconTheme.color),
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
                  "Contains ${playlist.streamCount} videos",
                  style: tinyTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: internalNavigatorKey.currentContext!,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => InfoItemOptions(infoItem: playlist));
          },
          icon: Icon(Icons.more_vert, size: 18, color: Theme.of(context).iconTheme.color)
        )
      ],
    );
  }

}