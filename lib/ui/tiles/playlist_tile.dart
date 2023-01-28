import 'package:songtube/internal/models/media_playlist.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/providers/playlist_provider.dart';
import 'package:songtube/ui/playlist_artwork.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    required this.playlist,
    required this.song,
    Key? key}) : super(key: key);
  final MediaPlaylist playlist;
  final SongItem song;
  @override
  Widget build(BuildContext context) {
    PlaylistProvider playlistProvider = Provider.of(context);
    bool containsSong = playlist.songs.any((element) => element.id == song.id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.2)
                )
              ],
            ), 
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: PlaylistArtwork(mediaSet: playlist.toMediaSet(), useThumbnail: true)
              ),
            ),
          ),
        ),
      ),
      title: Text(
        playlist.name,
        style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      subtitle: Text(
        playlist.songs.isEmpty ? 'Empty' : '${playlist.songs.length} songs',
        style: tinyTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w500),
        maxLines: 1,
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Transform.scale(
          scale: 0.6,
          child: RoundCheckBox(
            animationDuration: const Duration(milliseconds: 250),
            isChecked: containsSong,
            onTap: (_) {
              playlistProvider.addToGlobalPlaylist(playlist.id, song: song);
            },
            borderColor: Theme.of(context).dividerColor,
            checkedColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      onTap: () {
        playlistProvider.addToGlobalPlaylist(playlist.id, song: song);
      },
    );
  }

}