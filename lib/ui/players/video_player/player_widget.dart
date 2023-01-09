import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_fade/image_fade.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/players/video_player/player_ui/play_pause_button.dart';
import 'package:songtube/ui/players/video_player/player_ui/player_app_bar.dart';
import 'package:songtube/ui/players/video_player/player_ui/player_progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.content,
    required this.onAspectRatioUpdate,
    super.key});
  final ContentWrapper content;
  final Function(double) onAspectRatioUpdate;
  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  VideoPlayerController? controller;
  // Player Variables (width is set automatically)
  bool isPlaying = false;
  bool hideControls = false;
  bool videoEnded = false;
  bool buffering = true;
  bool isSeeking = false;
  String? currentQuality;
  bool showVolumeUI     = false;
  bool showBrightnessUI = false;
  String? currentVolumePercentage;
  String? currentBrightnessPercentage;
  int tapId = 0;

  // Reverse and Forward Animation
  bool showReverse = false;
  bool showForward = false;

  YoutubeVideo? _youtubeVideo;
  YoutubeVideo? get youtubeVideo => _youtubeVideo;
  set youtubeVideo(YoutubeVideo? video) {
    if (video == null) {
      _youtubeVideo = null;
      controller?.removeListener(() { });
      controller?.dispose().then((value) {
        setState(() {
          controller = null;
        });
      });
    } else {
      if (youtubeVideo != video) {
        _youtubeVideo = video;
        loadVideo();
      }
    }
  }

  Duration? get currentPosition => controller?.value.position;

  void handleSeek(Duration position) {
    controller?.seekTo(position);
  }

  // ignore: close_sinks
  final BehaviorSubject<double> _dragPositionSubject =
    BehaviorSubject.seeded(0);

  // UI
  bool _showControls   = true;
  bool get showControls {
    return _showControls;
  }
  set showControls(bool value) {
    setState(() {
      _showControls = value;
    });
  }
  bool _showBackdrop   = true;
  bool get showBackdrop {
    return _showBackdrop;
  }
  set showBackdrop(bool value) {
    setState(() {
      _showBackdrop = value;
    });
  }

  void showControlsHandler() {
    if (!showControls) {
      tapId = Random().nextInt(10);
      int currentId = tapId;
      setState(() {
        showControls = true;
        showBackdrop = true;
      });
      if (controller?.value.isPlaying ?? false) {
        Future.delayed(const Duration(seconds: 5), () {
          if (currentId == tapId && mounted && showControls == true && !isSeeking) {
            setState(() {
              showControls = false;
              showBackdrop = false;
            });
          }
        });
      }
    } else {
      setState(() {
        showControls = false;
        showBackdrop = false;
      });
    }
  }

  Future<void> handleVolumeGesture(double primaryDelta) async {
    tapId = Random().nextInt(10);
    int currentId = tapId;
    double maxVolume = 1;
    double currentVolume = await VolumeController().getVolume();
    double newVolume = (currentVolume +
      primaryDelta * 0.2 *
      (-1));
    currentVolumePercentage = newVolume > maxVolume
      ? "100" : newVolume < 0 ? "0" : "${((newVolume/maxVolume) * 100).round()}";
    setState(() {});
    VolumeController().setVolume(newVolume > maxVolume ? maxVolume : newVolume,
      showSystemUI: false);
    if (!showVolumeUI) {
      setState(() {
        showControls     = false;
        showVolumeUI     = true;
        showBackdrop     = true;
        showBrightnessUI = false;
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (currentId == tapId && mounted) {
        setState(() {
          showControls     = false;
          showVolumeUI     = false;
          showBackdrop     = false;
          showBrightnessUI = false;
        });
      }
    });
  }

  void handleBrightnessGesture(double primaryDelta) async {
    tapId = Random().nextInt(10);
    int currentId = tapId;
    double currentBrightness = await ScreenBrightness().current;
    double newBrightness =
      currentBrightness + ((primaryDelta*-1)*0.01);
    currentBrightnessPercentage = newBrightness > 1 ? "100" :
      newBrightness < 0 ? "0" : "${((newBrightness/1)*100).round()}";
    setState(() {});
    ScreenBrightness().setScreenBrightness(
      newBrightness > 1 ? 1 : newBrightness < 0 ? 0 : newBrightness
    );
    if (!showVolumeUI) {
      setState(() {
        showControls     = false;
        showVolumeUI     = false;
        showBackdrop     = true;
        showBrightnessUI = true;
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (currentId == tapId && mounted) {
        setState(() {
          showControls     = false;
          showVolumeUI     = false;
          showBackdrop     = false;
          showBrightnessUI = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    youtubeVideo = widget.content.videoDetails;
    super.didUpdateWidget(oldWidget);
  }

  void loadVideo() async {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => hideControls = true);
    });
    controller = VideoPlayerController.network(
      videoDataSource: widget.content.videoDetails!.videoStreams!.last.url
    );
    controller?.initialize().then((_) async {
      await controller?.play();
      setState(() {isPlaying = true; buffering = false;});
      setState(() { showControls = false; showBackdrop = false; });
      widget.onAspectRatioUpdate(controller?.value.aspectRatio ?? 16/9);
    });
    controller?.addListener(() {
      if ((controller?.value.isBuffering ?? false) && buffering == false) {
        setState(() => buffering = true);
      }
      if (!(controller?.value.isBuffering ?? false) && buffering == true) {
        setState(() => buffering = false);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.content.videoPlayerController._addState(this);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: controller != null
        ? _videoPlayer()
        : _thumbnail(),
    );
  }

  Widget _videoPlayer() {
    UiProvider uiProvider = Provider.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller!),
          AnimatedBuilder(
            animation: uiProvider.fwController.animationController,
            builder: (context, child) {
              return Opacity(
                opacity: (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) > 0
                  ? (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) : 0,
                child: child,
              );
            },
            child: _playbackControlsOverlay(),
          )
        ],
      ));
  }

  Widget _thumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Opacity(
            opacity: 0.6,
            child: ImageFade(
              fadeDuration: const Duration(milliseconds: 300),
              placeholder: const ShimmerContainer(height: null, width: null),
              fit: BoxFit.cover,
              image: NetworkImage(widget.content.infoItem is StreamInfoItem
                ? widget.content.infoItem.thumbnails!.hqdefault
                : widget.content.infoItem.thumbnailUrl),
            ),
          ),
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  // Full UI for playback controls and gestures
  Widget _playbackControlsOverlay() {
    return Stack(
      children: [
        // Player Gestures Detector
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: showControlsHandler,
                onDoubleTap: () {
                  if (controller?.value.isInitialized ?? false) {
                    Duration seekNewPosition;
                    if ((currentPosition ?? const Duration(seconds: 0)) < const Duration(seconds: 10)) {
                      seekNewPosition = Duration.zero;
                    } else {
                      seekNewPosition = (currentPosition ?? const Duration(seconds: 0)) - const Duration(seconds: 10);
                    }
                    handleSeek(seekNewPosition);
                    setState(() => showReverse = true);
                    Future.delayed(const Duration(milliseconds: 250), ()
                      => setState(() => showReverse = false));
                  }
                },
                onVerticalDragUpdate: MediaQuery.of(context).orientation == Orientation.landscape
                  ? (update) { handleBrightnessGesture(update.primaryDelta ?? 0); } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: double.infinity,
                  color: !showBackdrop
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.3),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      child: showBrightnessUI
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(EvaIcons.sun,
                              color: Colors.white,
                              size: 32),
                            const SizedBox(width: 12),
                            Text(
                              "$currentBrightnessPercentage%",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 36,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ],
                        )
                        : Container()
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: showControlsHandler,
                onDoubleTap: () {
                  if (controller?.value.isInitialized ?? false) {
                    handleSeek((currentPosition ?? const Duration(seconds: 0)) + const Duration(seconds: 10));
                    setState(() => showForward = true);
                    Future.delayed(const Duration(milliseconds: 300), ()
                      => setState(() => showForward = false));
                  }
                },
                onVerticalDragUpdate: MediaQuery.of(context).orientation == Orientation.landscape
                  ? (update) { handleVolumeGesture(update.primaryDelta ?? 0); } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: double.infinity,
                  color: !showBackdrop
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.3),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      child: showVolumeUI
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(EvaIcons.volumeUp,
                              color: Colors.white,
                              size: 32),
                            const SizedBox(width: 12),
                            Text(
                              "$currentVolumePercentage%",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 36,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ],
                        )
                        : Container()
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Player Fast Forward/Backward Animation
        IgnorePointer(
          ignoring: true,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(50),
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: showReverse
                      ? const Icon(Icons.replay_10_outlined,
                          color: Colors.white,
                          size: 40)
                      : Container()
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(50),
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: showForward
                      ? const Icon(Icons.forward_10_outlined,
                          color: Colors.white,
                          size: 40)
                      : Container()
                  ),
                ),
              )
            ],
          ),
        ),
        // Player controls UI
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: showControls ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Player AppBar
                Align(
                  alignment: Alignment.topLeft,
                  child: VideoPlayerAppBar(
                    audioOnly: false,
                    currentQuality: '720p',
                    videoTitle: widget.content.videoDetails?.videoInfo.name ?? '',
                    onChangeQuality: () {
                      
                    },
                    onEnterPipMode: () {

                    },
                  ),
                ),
                // Play/Pause Buttons
                VideoPlayerPlayPauseButton(
                  isPlaying: isPlaying,
                  onPlayPause: () async {
                    if (controller?.value.isPlaying ?? false) {
                      await controller?.pause();
                      isPlaying = false;
                    } else {
                      await controller?.play();
                      isPlaying = true;
                    }
                    setState(() {});
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Builder(
                    builder: (context) {
                      return StreamBuilder<Object>(
                        stream: Rx.combineLatest2<double, double, double>(
                          _dragPositionSubject.stream,
                          Stream.periodic(const Duration(milliseconds: 1000), ((computationCount) {
                            return computationCount.toDouble();
                          })),
                          (dragPosition, _) => dragPosition),
                        builder: (context, snapshot) {
                          return VideoPlayerProgressBar(
                            onAudioOnlySwitch: () {
                              
                            },
                            audioOnly: false,
                            segments: widget.content.videoDetails?.segments,
                            position: controller?.value.position ?? const Duration(seconds: 0),
                            duration: controller?.value.duration ?? const Duration(seconds: 1),
                            onSeek: (double newPosition) {
                              handleSeek(Duration(seconds: newPosition.round()));
                              setState(() => isSeeking = false);
                            },
                            onFullScreenTap: () {
                              
                            },
                            onSeekStart: () {
                              setState(() => isSeeking = true);
                            },
                          );
                        }
                      );
                    }
                  ),
                )
              ],
            ),
          ) : Container()
        ),
        // Player buffering indicator
        Center(
          child: buffering
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 2)
            : Container()
        )
      ],
    );
  }

}

class VideoPlayerWidgetController {

  VideoPlayerWidgetState? _videoPlayerWidgetState;

  void _addState(VideoPlayerWidgetState state) {
    _videoPlayerWidgetState = state;
  }

  // Get the VideoPlayer Controller
  VideoPlayerController? get videoPlayerController => _videoPlayerWidgetState?.controller;

}