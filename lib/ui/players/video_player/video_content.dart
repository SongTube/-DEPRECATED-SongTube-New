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
import 'package:songtube/ui/players/video_player/description.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';
import 'package:songtube/ui/menus/download_content_menu.dart';
import 'package:songtube/ui/sheets/add_to_stream_playlist.dart';
import 'package:songtube/ui/sheets/snack_bar.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:collection/collection.dart';
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

  // Load video comments
  void loadComments(String url) {
    setState(() {
      comments.clear();
    });
    CommentsExtractor.getComments(url).then((value) {
      setState(() {
        comments = value;
        if (value.isEmpty) {
          commentsAvailable = false;
        } else {
          commentsAvailable = true;
        }
      });
    });
  }

  // Load video suggestions
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

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child:  _body()
    );
  }

  Widget _body() {
    if (showComments && widget.content.videoDetails != null) {
      return VideoPlayerCommentsExpanded(
        comments: comments..sort((a, b) => b.likeCount!.compareTo(a.likeCount!)),
        onBack: () => showComments = false,
        onSeek: (position) {
          widget.content.videoPlayerController.videoPlayerController?.seekTo(position);
        });
    } else if (showDescription && widget.content.videoDetails != null) {
      return VideoPlayerDescription(
        info: widget.content.videoDetails!.videoInfo,
        onBack: () => showDescription = false,
        onSeek: (position) {
          widget.content.videoPlayerController.videoPlayerController?.seekTo(position);
        });
    } else {
      return _playerBody();
    }
  }

  Widget _playerBody() {
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
        GestureDetector(
          onTap: () {
            showComments = true;
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
            child: VideoPlayerCommentsCollapsed(
              comments: comments..sort((a, b) => b.likeCount!.compareTo(a.likeCount!)),
              commentsAvailable: commentsAvailable,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Video Suggestions
        VideoPlayerSuggestions(suggestions: relatedStreams, bottomPadding: widget.content.infoItem is PlaylistInfoItem)
      ],
    );
  }

  Widget _playerTitle() {
    StreamInfoItem? infoItem = widget.content.infoItem is StreamInfoItem ? widget.content.infoItem : null;
    VideoInfo? videoInfo = widget.content.videoDetails?.videoInfo;
    final views = (infoItem?.viewCount != null || videoInfo != null) ? "${NumberFormat.compact().format(infoItem?.viewCount ?? videoInfo?.viewCount)} views" : '-1';
    final date = infoItem?.date ?? widget.content.videoDetails?.videoInfo.uploadDate ?? "";
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
              Text(infoItem?.name ?? videoInfo?.name ?? '', style: bigTextStyle(context).copyWith(fontSize: 26), maxLines: 2, overflow: TextOverflow.ellipsis),
              Text((views.contains('-1') ? "" : ("$views  •  ${timeago.format(DateTime.parse(date), locale: 'en')}")), style: smallTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.1, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                            infoItem?.uploaderName ?? videoInfo?.uploaderName ?? '',
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
            showDescription = true;
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
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 12, right: 12),
        children: [
          // Like Button
          Builder(
            builder: (context) {
              final hasVideo = contentProvider.favoriteVideos.any((element) => element.id == videoInfo?.id);
              return TextIconSlimButton(
                icon: Icon(LineIcons.thumbsUp, color: hasVideo ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color, size: 20),
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
          const SizedBox(width: 12),
          // Like Button
          TextIconSlimButton(
            icon: const Icon(LineIcons.share),
            text: 'Share',
            onTap: () {
              Share.share(videoInfo!.url!);
            },
          ),
          const SizedBox(width: 12),
          // Like Button
          TextIconSlimButton(
            icon: const Icon(Ionicons.add_outline),
            text: 'Playlist',
            onTap: () {
              showModalBottomSheet(context: internalNavigatorKey.currentContext!, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) {
                return AddToStreamPlaylist(stream: widget.content.videoDetails!.toStreamInfoItem());
              });
            },
          ),
          const SizedBox(width: 12),
          // Like Button
          Builder(
            builder: (context) {
              final downloading = downloadProvider.queue.any((element) => element.downloadInfo.url == videoInfo?.url);
              final downloadItem = downloadProvider.queue.firstWhereOrNull((element) => element.downloadInfo.url == videoInfo?.url);
              final downloaded = downloadProvider.downloadedSongs.any((element) => element.videoId == videoInfo?.url);
              return StreamBuilder<double?>(
                stream: downloadItem?.downloadProgress,
                builder: (context, snapshot) {
                  final progress = snapshot.data;
                  final currentProgress = progress != null ? (progress*100).round().toString() : '';
                  return TextIconSlimButton(
                    icon: Icon(LineIcons.alternateCloudDownload, color: Theme.of(context).iconTheme.color),
                    text: downloading ? 'Downloading... ${currentProgress.isNotEmpty ? '$currentProgress%' : ''}' : downloaded ? 'Downloaded' : 'Download',
                    onTap: () {
                      showModalBottomSheet(
                        context: internalNavigatorKey.currentContext!,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DownloadContentMenu(content: widget.content));
                    },
                    backgroundColor: (downloading || downloaded) ? Theme.of(context).primaryColor.withOpacity(downloaded ? 1.0 : 0.5) : null,
                  );
                }
              );
            }
          ),
        ],
      ),
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