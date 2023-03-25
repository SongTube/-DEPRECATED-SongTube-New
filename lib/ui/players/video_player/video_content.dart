import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_fade/image_fade.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newpipeextractor_dart/extractors/comments.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
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

class VideoPlayerContent extends StatefulWidget {
  const VideoPlayerContent({
    required this.content,
    required this.videoDetails,
    super.key});
  final ContentWrapper content;
  final YoutubeVideo? videoDetails;

  @override
  State<VideoPlayerContent> createState() => _VideoPlayerContentState();
}

class _VideoPlayerContentState extends State<VideoPlayerContent> with TickerProviderStateMixin {

  // Our current list of comments
  List<YoutubeComment> comments = [];

  // Our current list of video or playlist suggestions
  List<dynamic> relatedStreams = [];

  // Indicate if this videos has comments available
  bool commentsAvailable = true;

  // Show comments
  bool _showComments = false;
  bool get showComments => _showComments;
  set showComments(bool value) {
    if (value) {
      _showDescription = false;
    }
    _showComments = value;
    setState(() {});
  }

  // Show description
  bool _showDescription = false;
  bool get showDescription => _showDescription;
  set showDescription(bool value) {
    if (value) {
      _showComments = false;
    }
    _showDescription = value;
    setState(() {});
  }

  // Determine if we need to hide the player's UI for the comments or description
  bool get hidePlayerBody => showComments;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _playerBody(constraints);
      }
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final url = widget.videoDetails?.videoInfo.url;
      if (url != null) {
        loadComments(url);
        loadSuggestions(url);
      }
    });
    super.initState();
  }

  @override 
  void didUpdateWidget(covariant VideoPlayerContent oldWidget) {
    if (oldWidget.videoDetails?.videoInfo.url != widget.videoDetails?.videoInfo.url) {
      if (widget.videoDetails?.videoInfo.url != null) {
        loadComments(widget.videoDetails!.videoInfo.url!);
        loadSuggestions(widget.videoDetails!.videoInfo.url!);
      } else {
        setState(() {
          comments.clear();
          relatedStreams.clear();
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void loadComments(String url) {
    setState(() {
      comments.clear();
    });
    CommentsExtractor.getComments(url).then((value) {
      setState(() {
        comments = value;
        if (value.isEmpty) {
          commentsAvailable = false;
        }
      });
    });
  }

  void loadSuggestions(String url) {
    setState(() {
      relatedStreams.clear();
    });
    VideoExtractor.getRelatedStreams(url).then((value) {
      relatedStreams = value;
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      // Remove first item if it's the one currently playing
      if (contentProvider.playingContent!.infoItem == relatedStreams.first) {
        relatedStreams.removeAt(0);
      }
      setState(() {});
    });
  }

  Widget _playerBody(BoxConstraints constraints) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 12),
        // Video Title and Show More Button
        _playerTitle(),
        const SizedBox(height: 6),
        // Action Buttons (Like, dislike, download, etc...)
        _playerActions(),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
          child: VideoPlayerComments(
            comments: comments,
            commentsAvailable: commentsAvailable,
          ),
        ),
        const SizedBox(height: 12),
        // Video Suggestions
        VideoPlayerSuggestions(suggestions: relatedStreams)
      ],
    );
  }

  Widget _playerTitle() {
    VideoInfo? videoInfo = widget.content.videoDetails?.videoInfo;
    final views = videoInfo != null ? "${NumberFormat.compact().format(videoInfo.viewCount)} views" : '-1';
    final date = widget.content.videoDetails?.videoInfo.uploadDate ?? "";
    return Row(
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
    );
  }

  Widget _playerActions() {
    DownloadProvider downloadProvider = Provider.of(context);
    VideoInfo? videoInfo = widget.content.videoDetails?.videoInfo;
    ContentProvider contentProvider = Provider.of(context);
    return Row(
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
                  contentProvider.saveVideoToFavorites(widget.content.videoDetails!.toStreamInfoItem());
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
              return AddToStreamPlaylist(stream: widget.content.videoDetails!.toStreamInfoItem());
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
                  builder: (context) => DownloadContentMenu(content: widget.content));
              },
            );
          }
        ),
      ],
    );
  }

  Widget _animatedBox({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: hidePlayerBody ? 0 : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: hidePlayerBody ? 0 : 1,
        child: child,
      ),
    );
  }

}