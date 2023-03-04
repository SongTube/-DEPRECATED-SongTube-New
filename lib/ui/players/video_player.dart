import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/players/video_player/collapsed.dart';
import 'package:songtube/ui/players/video_player/expanded.dart';
import 'package:songtube/ui/players/video_player/player_widget.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with TickerProviderStateMixin {
  
  // Content Provider
  ContentProvider get contentProvider => Provider.of(context);

  // UiProvider
  UiProvider get uiProvider => Provider.of(context);

  // Current Content
  ContentWrapper get content => contentProvider.playingContent!;

  // Aspect Ratio of video
  double get aspectRatio => (contentProvider.playingContent?.videoPlayerController.videoPlayerController?.value.aspectRatio != null
    ? contentProvider.playingContent?.videoPlayerController.videoPlayerController?.value.aspectRatio ?? 16/9
    : 16/9).clamp(1, 16/9);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: uiProvider.fwController.animationController,
        builder: (context, child) {
          return SizedBox(
            height: Tween<double>(begin: kToolbarHeight * 1.6, end: MediaQuery.of(context).size.height-38-kToolbarHeight-(kToolbarHeight*0.7)).animate(uiProvider.fwController.animationController).value,
            child: Stack(
              children: [
                child!,
              ],
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30)
            ),
            boxShadow: uiProvider.fwController.lockNotificationListener
              ? [BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.2)
                )]
              : null,
          ),
          child: GestureDetector(
            onTap: () {
              if (uiProvider.fwController.animationController.value == 0) {
                uiProvider.fwController.animationController
                  .animateTo(1, curve: Curves.fastLinearToSlowEaseIn, duration: const Duration(seconds: 1));
              }
            },
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Artwork Carousel
                        AnimatedBuilder( 
                          animation: uiProvider.fwController.animationController,
                          builder: (context, child) {
                            return Builder(
                              builder: (context) {
                                const initialHeight = kToolbarHeight * 1.18;
                                final initialWidth = initialHeight*aspectRatio;
                                final finalWidth = MediaQuery.of(context).size.width-24;
                                final finalHeight = finalWidth/aspectRatio;
                                return Container(
                                  margin: const EdgeInsets.only(left: 12, right: 12).copyWith(
                                    top: Tween<double>(begin: 11.5, end: MediaQuery.of(context).padding.top).animate(uiProvider.fwController.animationController).value,
                                    bottom: Tween<double>(begin: 11.5, end: 0).animate(uiProvider.fwController.animationController).value
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  constraints: BoxConstraintsTween(
                                    begin: BoxConstraints.tightFor(width: initialWidth, height: initialHeight),
                                    end: BoxConstraints.tightFor(width: finalWidth, height: finalHeight))
                                      .evaluate(uiProvider.fwController.animationController),
                                  child: child
                                );
                              }
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: VideoPlayerWidget(
                              content: content,
                              onAspectRatioUpdate: (aspectRatio) {
                                setState(() {

                                });
                              },
                            ),
                          )
                        ),
                        // Song Title and Artist
                        Expanded(
                          child: AnimatedBuilder(
                            animation: uiProvider.fwController.animationController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: (1 - (2 * uiProvider.fwController.animationController.value)) > 0
                                  ? (1 - (2 * uiProvider.fwController.animationController.value)) : 0,
                                child: child
                              );
                            },
                            child: VideoPlayerCollapsed(content: content)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Flexible(
                  child: AnimatedBuilder(
                    animation: uiProvider.fwController.animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) > 0
                          ? (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) : 0,
                        child: Transform.translate(
                          offset: Offset(0, Tween<double>(begin: 180, end: 0).animate(uiProvider.fwController.animationController).value),
                          child: child)
                      );
                    },
                    child: VideoPlayerExpanded(content: content)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



}