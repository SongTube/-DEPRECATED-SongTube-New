import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:intl/intl.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/components/channel_image.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/sheets/add_to_stream_playlist.dart';
import 'package:songtube/ui/sheets/info_item_options.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:transparent_image/transparent_image.dart';

class StreamTileCollapsed extends StatelessWidget {
  const StreamTileCollapsed({
    required this.stream,
    this.onTap,
    this.isEditable = true,
    super.key});
  final StreamInfoItem stream;
  /// By default, onTap loads this video on the content provider, but
  /// if onTap is set, you can run override that default behavior
  final Function()? onTap;
  final bool isEditable;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return CustomInkWell(
      onTap: isEditable ? onTap ?? () {
        uiProvider.currentPlayer = CurrentPlayer.video;
        contentProvider.loadVideoPlayer(stream);
        uiProvider.fwController.open();
      } :() {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.1)
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: ImageFade(
                      fadeDuration: const Duration(milliseconds: 300),
                      placeholder: const ShimmerContainer(height: null, width: null),
                      image: NetworkImage(stream.thumbnails!.hqdefault),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6, right: 6),
                    padding: const EdgeInsets.all(3).copyWith(left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Text(
                      "${Duration(seconds: stream.duration!).inMinutes}:${Duration(seconds: stream.duration!).inSeconds.remainder(60).toString().padRight(2, "0")}",
                      style: tinyTextStyle(context).copyWith(color: Colors.white)
                    ),
                  ),
                )
              ],
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
                    stream.name ?? '',
                    style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "${stream.uploaderName}  ${NumberFormat.compact().format(stream.viewCount) != '-1' ? '•  ${NumberFormat.compact().format(stream.viewCount)} views' : ''}",
                    style: tinyTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w500),
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
                builder: (context) => InfoItemOptions(infoItem: stream));
            },
            icon: Icon(Icons.more_vert, size: 18, color: Theme.of(context).iconTheme.color)
          )
        ],
      ),
    );
  }
}

class StreamTileExpanded extends StatelessWidget {
  const StreamTileExpanded({
    required this.stream,
    super.key});
  final StreamInfoItem stream;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return CustomInkWell(
      onTap: () {
        uiProvider.currentPlayer = CurrentPlayer.video;
        contentProvider.loadVideoPlayer(stream);
        uiProvider.fwController.open();
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.1)
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: _thumbnail(context),
              ),
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
          imageUrl: stream.thumbnails?.maxresdefault ?? '',
          fit: BoxFit.cover,
          errorWidget: (context, error, stackTrace) =>
            Image.network(stream.thumbnails!.hqdefault, fit: BoxFit.cover),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.only(right: 12, bottom: 12),
            padding: const EdgeInsets.all(3).copyWith(left: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100)
            ),
            child: Text(
              "${Duration(seconds: stream.duration!).inMinutes}:${Duration(seconds: stream.duration!).inSeconds.remainder(60).toString().padRight(2, "0")}",
              style: tinyTextStyle(context).copyWith(color: Colors.white)
            )
          ),
        ),
      ],
    );
  }

  Widget _details(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChannelImage(channelUrl: stream.uploaderUrl, heroId: stream.id!),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${stream.name}",
                  maxLines: 2,
                  style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${stream.uploaderName} ${stream.viewCount != -1 ? " • ${NumberFormat.compact().format(stream.viewCount)} views" : ""}"
                      " ${stream.uploadDate == null ? "" : " • ${stream.uploadDate!}"}",
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
              builder: (context) => InfoItemOptions(infoItem: stream));
          },
          icon: Icon(Icons.more_vert, size: 18, color: Theme.of(context).iconTheme.color)
        )
      ],
    );
  }

}