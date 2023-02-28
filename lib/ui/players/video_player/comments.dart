import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:newpipeextractor_dart/extractors/comments.dart';
import 'package:newpipeextractor_dart/models/comment.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerComments extends StatefulWidget {
  const VideoPlayerComments({
    required this.url,
    super.key});
  final String? url;
  @override
  State<VideoPlayerComments> createState() => _VideoPlayerCommentsState();
}

class _VideoPlayerCommentsState extends State<VideoPlayerComments> {

  // Our current list of comments
  List<YoutubeComment> comments = [];

  // Indicate if this videos has comments available
  bool commentsAvailable = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadComments();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerComments oldWidget) {
    if (oldWidget.url != widget.url) {
      loadComments();
    }
    super.didUpdateWidget(oldWidget);
  }

  void loadComments() {
    if (widget.url == null) {
      return;
    }
    setState(() {
      comments.clear();
    });
    CommentsExtractor.getComments(widget.url!).then((value) {
      setState(() {
        comments = value;
        if (value.isEmpty) {
          commentsAvailable = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.all(8).copyWith(left: 16, right: 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: commentsAvailable ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              CustomInkWell(
                onTap: () {
                  
                },
                child: Row(
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
                            child: comments.isNotEmpty
                              ? _commentPreview()
                              : _commentShimmer(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ) : const SizedBox(),
        ),
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
              image: NetworkImage(comments.first.uploaderAvatarUrl!),
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
                  text: '${comments.first.author} • ',
                  style: smallTextStyle(context).copyWith()
                ),
                // Author message
                TextSpan(
                  text: comments.first.commentText,
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
        ShimmerContainer(width: 34, height: 34, borderRadius: BorderRadius.circular(100)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerContainer(width: MediaQuery.of(context).size.width*0.5, height: 15, borderRadius: BorderRadius.circular(100)),
            const SizedBox(height: 5),
            ShimmerContainer(width: MediaQuery.of(context).size.width*0.3, height: 10, borderRadius: BorderRadius.circular(100)),
          ],
        ),
      ],
    );
  }

}