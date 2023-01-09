import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/main.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/sheets/add_to_playlist.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SongOptionsSheet extends StatelessWidget {
  const SongOptionsSheet({
    required this.song,
    Key? key}) : super(key: key);
  final SongItem song;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20)
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: BottomSheetPhill()),
          SongTile(song: song,
            disablePlayingBackground: true,
            disablePlayingVisualizer: true),
          Divider(indent: 12, endIndent: 12, color: Theme.of(context).dividerColor),
          _optionTile(context,
            title: 'Play on Device',
            subtitle: 'Select device to play this song',
            icon: LineIcons.mobilePhone,
            onTap: () {

            }
          ),
          _optionTile(context,
            title: 'Add to Playlist',
            subtitle: 'Add to existing or new playlist',
            icon: LineIcons.list,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(context: internalNavigatorKey.currentContext!, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) {
                return AddToPlaylistSheet(song: song);
              });
            }
          ),
          _optionTile(context,
            title: 'Share Song',
            subtitle: 'Share with friends or other platforms',
            icon: LineIcons.share,
            onTap: () {

            }
          ),
          _optionTile(context,
            title: 'Edit Tags',
            subtitle: 'Open ID3 tags and artwork editor',
            icon: LineIcons.tags,
            onTap: () {

            }
          ),
        ],
      ),
    );
  }

  Widget _optionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 6),
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