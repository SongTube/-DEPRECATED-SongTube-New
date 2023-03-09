import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_fade/image_fade.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/components/text_icon_button.dart';
import 'package:songtube/ui/players/video_player/comments.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';
import 'package:songtube/ui/menus/download_content_menu.dart';
import 'package:songtube/ui/sheets/add_to_stream_playlist.dart';
import 'package:songtube/ui/sheets/snack_bar.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoPlayerContent extends StatelessWidget {
  const VideoPlayerContent({
    required this.content,
    super.key});
  final ContentWrapper content;
  @override
  Widget build(BuildContext context) {
    DownloadProvider downloadProvider = Provider.of(context);
    VideoInfo? videoInfo = content.videoDetails?.videoInfo;
    ContentProvider contentProvider = Provider.of(context);
    final views = videoInfo != null ? "${NumberFormat.compact().format(videoInfo.viewCount)} views" : '-1';
    final date = content.videoDetails?.videoInfo.uploadDate ?? "";
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        // Video Title and Show More Button
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(videoInfo?.name ?? '', style: bigTextStyle(context).copyWith(fontSize: 26), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text((views.contains('-1') ? "" : ("$views  •  ${timeago.format(DateTime.parse(date), locale: 'en')}")), style: smallTextStyle(context, opacity: 0.7), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    // Channel Details
                    CustomInkWell(
                      onTap: () {
                      
                      },
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: videoInfo != null
                              ? SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: ImageFade(
                                      fadeDuration: const Duration(milliseconds: 300),
                                      placeholder: ShimmerContainer(height: 40, width: 40, borderRadius: BorderRadius.circular(100)),
                                      image: NetworkImage(videoInfo.uploaderAvatarUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : ShimmerContainer(height: 40, width: 40, borderRadius: BorderRadius.circular(100)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  videoInfo?.uploaderName ?? '',
                                  style: subtitleTextStyle(context).copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text('SUBSCRIBE',
                                  style: smallTextStyle(context).copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO SHOW VIDEO DETAILS
                },
                icon: Icon(Icons.expand_more, color: Theme.of(context).primaryColor)
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 6)),
        // Action Buttons (Like, dislike, download, etc...)
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Like Button
              Builder(
                builder: (context) {
                  final hasVideo = contentProvider.favoriteVideos.any((element) => element.id == videoInfo?.id);
                  return TextIconButton(
                    icon: Icon(LineIcons.thumbsUp, color: hasVideo ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color),
                    text: hasVideo ? 'Liked' : 'Like',
                    onTap: () {
                      showSnackbar(customSnackBar: CustomSnackBar(icon: hasVideo ? LineIcons.trash : LineIcons.star, title: hasVideo ? 'Video removed from favorites' : 'Video added to favorites'));
                      if (hasVideo) {
                        contentProvider.removeVideoFromFavorites(videoInfo!.id!);
                      } else {
                        contentProvider.saveVideoToFavorites(content.videoDetails!.toStreamInfoItem());
                      }
                    },
                  );
                }
              ),
              // Dislike Button
              TextIconButton(
                icon: const Icon(LineIcons.thumbsDown),
                text: videoInfo != null && videoInfo.dislikeCount != -1
                  ? NumberFormat.compact().format(videoInfo.dislikeCount) : 'Dislike',
                onTap: () {
            
                },
              ),
              // Like Button
              TextIconButton(
                icon: const Icon(LineIcons.share),
                text: 'Share',
                onTap: () {
                  Share.share(videoInfo!.url!);
                },
              ),
              // Like Button
              TextIconButton(
                icon: const Icon(Ionicons.add_outline),
                text: 'Playlist',
                onTap: () {
                  showModalBottomSheet(context: internalNavigatorKey.currentContext!, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) {
                    return AddToStreamPlaylist(stream: content.videoDetails!.toStreamInfoItem());
                  });
                },
              ),
              // Like Button
              Builder(
                builder: (context) {
                  final downloading = downloadProvider.queue.any((element) => element.downloadInfo.url == videoInfo?.url);
                  return TextIconButton(
                    icon: Icon(LineIcons.download, color: downloading ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color),
                    text: downloading ? 'Downloading...' : 'Download',
                    onTap: () {
                      showModalBottomSheet(
                        context: internalNavigatorKey.currentContext!,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DownloadContentMenu(content: content));
                    },
                  );
                }
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
            child: VideoPlayerComments(url: videoInfo?.url),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        // Video Suggestions
        VideoPlayerSuggestions(url: videoInfo?.url)
      ],
    );
  }
}