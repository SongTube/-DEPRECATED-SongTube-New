import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:songtube/ui/tiles/channel_tile.dart';
import 'package:songtube/ui/tiles/stream_playlist_tile.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';

class InfoItemRenderer extends StatelessWidget {
  const InfoItemRenderer({
    required this.infoItem,
    this.expandItem = false,
    super.key});
  final dynamic infoItem;
  final bool expandItem;
  @override
  Widget build(BuildContext context) {
    if (infoItem is ChannelInfoItem) {
      return ChannelTile(channel: infoItem);
    } else if (infoItem is StreamInfoItem) {
      if (expandItem) {
        return StreamTileExpanded(stream: infoItem);
      } else {
        return StreamTileCollapsed(stream: infoItem);
      }
    } else if (infoItem is PlaylistInfoItem) {
      if (expandItem) {
        return PlaylistTileExpanded(playlist: infoItem);
      } else {
        return PlaylistTileCollapsed(playlist: infoItem);
      }
    } else {
      return const SizedBox();
    }
  }
}