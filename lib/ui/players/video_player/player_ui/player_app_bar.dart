import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerAppBar extends StatelessWidget {
  final String videoTitle;
  final Function() onChangeQuality;
  final Function() onEnterPipMode;
  final String currentQuality;
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              videoTitle,
              style: smallTextStyle(context).copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          if (!audioOnly)
          const SizedBox(width: 12),
          if (!audioOnly)
          FutureBuilder(
            future: DeviceInfoPlugin().androidInfo, 
            builder: (context, AsyncSnapshot<AndroidDeviceInfo> info) {
              if (info.hasData) {
                if ((info.data?.version.sdkInt ?? 0) >= 26) {
                  return GestureDetector(
                    onTap: onEnterPipMode,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.transparent,
                      child: const Icon(
                        MdiIcons.pictureInPictureBottomRightOutline,
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
                      MdiIcons.pictureInPictureBottomRightOutline,
                      color: Colors.transparent,
                      size: 18,
                    ),
                  );
                }
              } else {
                return Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.transparent,
                  child: const Icon(
                    MdiIcons.pictureInPictureBottomRightOutline,
                    color: Colors.transparent,
                    size: 18,
                  ),
                );
              }
            }
          ),
          if (!audioOnly)
          const SizedBox(width: 12),
          if (!audioOnly)
          GestureDetector(
            onTap: () => onChangeQuality(),
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.transparent,
              child: Text(
                ("${("${currentQuality.split('p').first}p").split('•').last.trim()}${currentQuality.split('p').last.contains("60") ? " • 60 FPS" : ""}"),
                style: smallTextStyle(context).copyWith(color: Colors.white)
              )
            ),
          ),
          const SizedBox(width: 12),
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