import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/providers/playlist_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/animations/fade_in.dart';
import 'package:songtube/ui/playlist_artwork.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/song_tile.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    required this.playlistId,
    Key? key}) : super(key: key);
  final String playlistId;
  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of(context);
    PlaylistProvider playlistProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    final playlist = playlistProvider.globalPlaylists.firstWhere((element) => element.id == playlistId);
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: (16/9),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlaylistArtwork(playlist: playlist, color: Theme.of(context).cardColor, opacity: 0.7, shadowIntensity: 0.2, shadowSpread: 24, enableHeroAnimation: false),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 12, right: 12, top: MediaQuery.of(context).padding.top),
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Iconsax.arrow_left, color: Theme.of(context).iconTheme.color)
                          ), 
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Iconsax.edit, color: Theme.of(context).iconTheme.color)
                          ), 
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(playlist.name, style: bigTextStyle(context)),
                              const SizedBox(width: 2),
                              playlist.favorite
                                ? const FadeInTransition(
                                    duration: Duration(milliseconds: 500),
                                    child: Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 18))
                                : const SizedBox()
                            ],
                          ),
                          Text(playlist.songs.isEmpty ? 'Empty' : '${playlist.songs.length} songs', style: smallTextStyle(context))
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          Expanded(
            child: StreamBuilder<MediaItem?>(
              stream: audioHandler.mediaItem,
              builder: (context, snapshot) {
                final playerOpened = snapshot.data != null;
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16)
                    .copyWith(bottom: playerOpened
                      ? (kToolbarHeight * 1.6)+(kToolbarHeight)+48
                      : (kToolbarHeight * 1.6)+24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: playlist.songs.length,
                  itemBuilder: (context, index) {
                    final song = playlist.songs[index];
                    return SongTile(
                      song: song,
                      onPlay: () async {
                        mediaProvider.currentPlaylistName = playlist.name;
                        final queue = List<MediaItem>.generate(playlist.songs.length, (index) {
                          return playlist.songs[index].mediaItem;
                        });
                        uiProvider.currentPlayer = CurrentPlayer.music;
                        mediaProvider.playSong(queue, index);
                      }
                    );
                  }
                );
              }
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final playerOpened = snapshot.data != null;
          return AnimatedContainer(
            color: Colors.transparent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
            margin: EdgeInsets.only(bottom: playerOpened ? (kToolbarHeight * 1.6)+24 : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    playlistProvider.favoriteGlobalPlaylist(playlist.id);
                  },
                  child: Container(
                    decoration: BoxDecoration( 
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0,0),
                          color: Theme.of(context).shadowColor.withOpacity(0.1)
                        )
                      ]
                    ),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        playlist.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        key: ValueKey('${playlist.favorite}+${playlist.id}'),
                        color: playlist.favorite ? Colors.orangeAccent : Theme.of(context).iconTheme.color)),
                  ),
                ),
                InkWell(
                  onTap: () {
            
                  },
                  child: Container(
                    decoration: BoxDecoration( 
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0,0),
                          color: Theme.of(context).shadowColor.withOpacity(0.1)
                        )
                      ]
                    ),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Ionicons.shuffle_outline, color: Theme.of(context).iconTheme.color),
                  ),
                ),
                InkWell(
                  onTap: () {
                    mediaProvider.currentPlaylistName = playlist.name;
                    final queue = List<MediaItem>.generate(playlist.songs.length, (index) {
                      return playlist.songs[index].mediaItem;
                    });
                    mediaProvider.playSong(queue, 0);
                  },
                  child: Container(
                    decoration: BoxDecoration( 
                      color: playlist.songs.first.palette!.vibrant,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0,0),
                          color: Theme.of(context).shadowColor.withOpacity(0.1)
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(12).copyWith(left: 18, right: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Ionicons.play, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Play all', style: textStyle(context).copyWith(color: Colors.white))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}