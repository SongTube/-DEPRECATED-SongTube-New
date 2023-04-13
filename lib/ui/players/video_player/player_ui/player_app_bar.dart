import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/playback_quality.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerAppBar extends StatelessWidget {
  final String videoTitle;
  final Function() onChangeQuality;
  final Function() onEnterPipMode;
  final VideoPlaybackQuality? currentQuality;
  final bool audioOnly;
  const VideoPlayerAppBar({
    required this.videoTitle,
    required this.onChangeQuality,
    required this.currentQuality,
    required this.audioOnly,
    required this.onEnterPipMode,
    Key? key
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              videoTitle,
              style: smallTextStyle(context, bold: true).copyWith(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          if (!audioOnly)
          const SizedBox(width: 12),
          if (!audioOnly)
          Builder(
            builder: (context) {
              if (isPictureInPictureSupported) {
                return GestureDetector(
                  onTap: onEnterPipMode,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.picture_in_picture_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.picture_in_picture_alt_rounded,
                    color: Colors.transparent,
                    size: 18,
                  ),
                );
              }
            }
          ),
          if (!audioOnly)
          const SizedBox(width: 12),
          if (currentQuality != null)
          GestureDetector(
            onTap: () => onChangeQuality(),
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${currentQuality!.resolution}p', style: smallTextStyle(context, bold: true).copyWith(color: Colors.white, letterSpacing: 1)),
                  if (currentQuality!.framerate > 30)
                  Text(' • ${currentQuality!.framerate.round()}FPS', style: smallTextStyle(context, bold: true).copyWith(color: Colors.white, letterSpacing: 1))
                ],
              )
            ),
          ),
          const SizedBox(width: 6),
          // Switch(
          //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //   activeThumbImage: const AssetImage('assets/images/playArrow.png'),
          //   activeColor: Colors.white,
          //   activeTrackColor: Colors.white.withOpacity(0.6),
          //   inactiveThumbColor: Colors.white.withOpacity(0.6),
          //   inactiveTrackColor: Colors.white.withOpacity(0.2),
          //   value: prefs.youtubeAutoPlay,
          //   onChanged: (bool value) {
          //     prefs.youtubeAutoPlay = value;
          //   },
          // ),
        ],
      ),
    );
  }
}