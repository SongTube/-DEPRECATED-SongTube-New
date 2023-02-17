import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Function(double) onSeek;
  final Function() onFullScreenTap;
  final List<StreamSegment>? segments;
  final Function() onSeekStart;
  final bool audioOnly;
  final Function() onAudioOnlySwitch;
  const VideoPlayerProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.segments,
    required this.audioOnly,
    required this.onAudioOnlySwitch,
    required this.onFullScreenTap,
    required this.onSeekStart,
    Key? key
  }) : super(key: key);

  @override
  State<VideoPlayerProgressBar> createState() => _VideoPlayerProgressBarState();
}

class _VideoPlayerProgressBarState extends State<VideoPlayerProgressBar> with TickerProviderStateMixin {

  // Current label, modified if segmets are available
  String? currentLabel;
  bool isDragging = false;
  double seekValue = 0;

  StreamSegment? currentSegment(double value) {
    if (widget.segments == null) return null;
    int position = value.round();
    if (value < widget.segments![1].startTimeSeconds) {
      return widget.segments!.first;
    } else if (value >= widget.segments!.last.startTimeSeconds) {
      return widget.segments!.last;
    } else {
      List<int> startTimes = List.generate(widget.segments!.length, (index)
        => widget.segments![index].startTimeSeconds).toList();
      int closestStartTime = (startTimes.where((e) => e >= position).toList()..sort()).first;
      int nearIndex = (widget.segments!.indexWhere((element) =>
        element.startTimeSeconds == closestStartTime))-1;
      return widget.segments![nearIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                "${widget.position.inMinutes.toString().padLeft(2, '0')}:${widget.position.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                style: tinyTextStyle(context)
              ),
              Expanded(
                child: SizedBox(
                  height: 10,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                        disabledThumbRadius: 3
                      ),
                      trackHeight: 1,
                    ),
                    child: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                      label: '${Duration(seconds: widget.position.inSeconds).inMinutes.toString().padLeft(2, '0')}:${Duration(seconds: widget.position.inSeconds).inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      value: isDragging ? seekValue : widget.position.inSeconds.toDouble(),
                      onChangeEnd: (newPosition) {
                        double seekPosition = newPosition;
                        if (widget.segments != null && widget.segments!.length >= 2) {
                          StreamSegment segment = currentSegment(newPosition)!;
                          if (segment.startTimeSeconds < newPosition) {
                            if (newPosition - segment.startTimeSeconds <= 10) {
                              seekPosition = segment.startTimeSeconds.toDouble();
                            }
                          }
                          if (segment.startTimeSeconds >= newPosition) {
                            if (segment.startTimeSeconds - newPosition <= 10) {
                              seekPosition = segment.startTimeSeconds.toDouble();
                            }
                          }
                        }
                        widget.onSeek(seekPosition);
                        setState(() => isDragging = false);
                      },
                      max: widget.duration.inSeconds.toDouble() == 0
                        ? 1 : widget.duration.inSeconds.toDouble(),
                      min: 0,
                      onChangeStart: (_) {
                        widget.onSeekStart();
                        setState(() { isDragging = true; currentLabel = null; seekValue = widget.position.inSeconds.toDouble(); });
                      },
                      onChanged: (value) {
                        setState(() {
                          seekValue = value;
                        });
                        if (widget.segments != null && widget.segments!.length >= 2) {
                          if (currentLabel != currentSegment(value)!.title) {
                            setState(() => currentLabel = currentSegment(value)!.title);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              Text(
                "${widget.duration.inMinutes.toString().padLeft(2, '0')}:${widget.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                style: tinyTextStyle(context).copyWith(color: Colors.white)
              ),
              const SizedBox(width: 12),
              // Audio Only Switch
              GestureDetector(
                onTap: widget.onAudioOnlySwitch,
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    widget.audioOnly
                      ? Icons.music_note_outlined : Icons.music_off_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // FullScreen Button
              GestureDetector(
                onTap: widget.onFullScreenTap,
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    MediaQuery.of(context).orientation == Orientation.portrait
                      ? Icons.fullscreen_outlined : Icons.fullscreen_exit_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: isDragging && currentLabel != null
              ? SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width-48,
                  child: PageTransitionSwitcher(
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return FadeThroughTransition(
                        fillColor: Colors.transparent,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                      );
                    },
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      currentLabel!,
                      key: ValueKey<String>(currentLabel!),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: smallTextStyle(context).copyWith(color: Colors.white)
                    ),
                  ),
                )
              : Container(
                  height: 8
                )
          )
        ],
      ),
    );
  }
}