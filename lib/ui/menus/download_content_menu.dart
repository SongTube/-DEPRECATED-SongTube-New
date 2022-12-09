import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/menus/download_menu/music.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/text_styles.dart';

class DownloadContentMenu extends StatelessWidget {
  const DownloadContentMenu({
    required this.content,
    super.key});
  final ContentWrapper content;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20)
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: BottomSheetPhill()),
            const SizedBox(height: 6),
            // Menu Title
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).iconTheme.color),
                  ),
                ),
                const SizedBox(width: 4),
                Text('Download', style: textStyle(context)),
              ],
            ),
            const SizedBox(height: 8),
            _optionTile(context, title: 'Music', subtitle: 'Select quality, convert and download audio only', icon: Ionicons.musical_notes_outline, onTap: () {
              // Open Music Download Menu
              Navigator.pop(context);
              showModalBottomSheet(context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                return AudioDownloadMenu(video: content.videoDetails!,
                  onDownload: () {

                  },
                  onBack: () {
                    Navigator.pop(context);
                    showModalBottomSheet(context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: ((context) => DownloadContentMenu(content: content)));
                  }
                );
              });
            }),
            _optionTile(context, title: 'Video', subtitle: 'Choose a video quality from the list and download it', icon: Ionicons.videocam_outline, onTap: () {
              // Open Music Download Menu
            }),
            _optionTile(context, title: 'Instant', subtitle: 'Instantly start downloading. Tap settings to configure', icon: Ionicons.flash_outline,
              onConfigure: () {

              },
              onTap: () {
                // Open Instant Download Settings
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Function() onTap, Function()? onConfigure}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
        height: kToolbarHeight+16,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Icon(icon, color: icon == LineIcons.trash ? Colors.red : Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: subtitleTextStyle(context, bold: true)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: smallTextStyle(context, opacity: 0.7), maxLines: 3)
                ],
              ),
            ),
            if (onConfigure != null)
            IconButton(
              onPressed: () {

              },
              icon: Icon(Iconsax.setting, color: Theme.of(context).primaryColor)
            )
          ],
        ),
      ),
    );
  }

}