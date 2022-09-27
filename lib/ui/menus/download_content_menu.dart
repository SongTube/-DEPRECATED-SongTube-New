import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/ui/info_item_renderer.dart';
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
      padding: const EdgeInsets.only(top: 16, bottom: 16),
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
            const SizedBox(height: 12),
            IgnorePointer(
              ignoring: true,
              child: InfoItemRenderer(infoItem: content.infoItem, expandItem: false)),
            const SizedBox(height: 8),
            Divider(indent: 12, endIndent: 12, color: Theme.of(context).dividerColor),
            _optionTile(context, title: 'Download Music', subtitle: 'Select quality, convert and download audio only', icon: Ionicons.musical_notes_outline, onTap: () {
              // Open Music Download Menu
            }),
            _optionTile(context, title: 'Download Video', subtitle: 'Choose a video quality from the list and download it', icon: Ionicons.videocam_outline, onTap: () {
              // Open Music Download Menu
            }),
            _optionTile(context, title: 'Instant Download', subtitle: 'Instantly download this content based on your pre-defined settings', icon: Ionicons.flash_outline, onTap: () {
              // Open Music Download Menu
            })
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
        height: kToolbarHeight,
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
                  Text(title, style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: tinyTextStyle(context, opacity: 0.6))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}