import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:newpipeextractor_dart/extractors/comments.dart';
import 'package:newpipeextractor_dart/models/comment.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';
import 'package:songtube/ui/animations/show_up.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerComments extends StatefulWidget {
  const VideoPlayerComments({
    required this.comments,
    required this.commentsAvailable,
    super.key});
  final List<YoutubeComment> comments;
  final bool commentsAvailable;
  @override
  State<VideoPlayerComments> createState() => _VideoPlayerCommentsState();
}

class _VideoPlayerCommentsState extends State<VideoPlayerComments> {

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.only(top: widget.commentsAvailable ? 6 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.commentsAvailable ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
        ),
        padding: const EdgeInsets.all(8).copyWith(left: 16, right: 16, top: widget.commentsAvailable ? 8 : 0, bottom: widget.commentsAvailable ? 8 : 0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.commentsAvailable ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Comments",
                                style: smallTextStyle(context).copyWith(fontWeight: FontWeight.w900)
                              ),
                              Text(
                                "  •  See more",
                                style: smallTextStyle(context).copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontSize: 11)
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: widget.comments.isNotEmpty
                              ? _commentPreview()
                              : _commentShimmer(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ) : const SizedBox(),
          ),
        )
      ),
    );
  }

  Widget _commentPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 34,
          width: 34,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: ImageFade(
              fadeDuration: const Duration(milliseconds: 300),
              placeholder: const ShimmerContainer(width: 34, height: 34),
              image: NetworkImage(widget.comments.first.uploaderAvatarUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.7)
              ),
              children: [
                // Author name
                TextSpan(
                  text: '${widget.comments.first.author} • ',
                  style: smallTextStyle(context).copyWith()
                ),
                // Author message
                TextSpan(
                  text: widget.comments.first.commentText,
                )
              ]
            )
          ),
        ),
      ],
    );
  }

  Widget _commentShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ShimmerContainer(width: 34, height: 34, borderRadius: BorderRadius.circular(100), color: Theme.of(context).cardColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerContainer(width: MediaQuery.of(context).size.width*0.5, height: 15, borderRadius: BorderRadius.circular(100), color: Theme.of(context).cardColor),
            const SizedBox(height: 5),
            ShimmerContainer(width: MediaQuery.of(context).size.width*0.3, height: 10, borderRadius: BorderRadius.circular(100), color: Theme.of(context).cardColor),
          ],
        ),
      ],
    );
  }

}