import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/app_settings.dart';
import 'package:songtube/internal/artwork_manager.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/media_item_models.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/providers/playlist_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/screens/playlist.dart';
import 'package:songtube/ui/players/music_player/background_carousel.dart';
import 'package:songtube/ui/players/music_player/player_body.dart';
import 'package:songtube/ui/sheets/music_equalizer.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/ui_utils.dart';
 
class MusicPlayer extends StatefulWidget {
  const MusicPlayer({ Key? key }) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {

  // MediaProvider
  MediaProvider get mediaProvider => Provider.of<MediaProvider>(context, listen: false);
  // Playlist Provider
  PlaylistProvider get playlistProvider => Provider.of<PlaylistProvider>(context, listen: false);
  // DownloadProvider
  DownloadProvider get downloadProvider => Provider.of<DownloadProvider>(context, listen: false);
  // UiProvider
  UiProvider get uiProvider => Provider.of(context, listen: false);

  // Current Song
  SongItem get song => SongItem.fromMediaItem(audioHandler.mediaItem.value!);

  @override
  void initState() {
    audioHandler.mediaItem.listen((event) {
      if (mounted) {
        setState(() {});
        if (uiProvider.fwController.isPanelOpen && event != null) {
          final iconColor = Theme.of(context).brightness == Brightness.light
            ? Brightness.light : Brightness.dark;
          final Color? textColor = SongItem.fromMediaItem(event).palette?.text;
          if (textColor != null) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarIconBrightness: AppSettings.enableMusicPlayerBlur ? textColor == Colors.black
                  ? Brightness.dark : Brightness.light : iconColor,
              ),
            );
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Playlist exception filter
    const playlistExceptionFilter = <String>[
      'Music',
      'Downloads',
      'Most Played',
      'Recently Added'
    ];
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedBuilder(
        animation: uiProvider.fwController.animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).cardColor,
              boxShadow: uiProvider.fwController.lockNotificationListener
              ? [BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.2)
                )]
              : null,
            ),
            child: Stack(
              children: [
                // Blurred Background
                BackgroundCarousel(
                  enabled: AppSettings.enableMusicPlayerBlur,
                  backgroundImage: thumbnailFile(song.id),
                  backdropColor: AppSettings.enableMusicPlayerBlur
                    ? song.palette!.dominant ?? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).scaffoldBackgroundColor,
                  backdropOpacity: AppSettings.musicPlayerBackdropOpacity,
                  blurIntensity: AppSettings.musicPlayerBlurStrenght,
                  transparency: Tween<double>(begin: 0, end: 1).animate(uiProvider.fwController.animationController).value,
                ),
                // Player UI
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.only(top: Tween<double>(begin: 0, end: MediaQuery.of(context).padding.top).animate(uiProvider.fwController.animationController).value),
                  child: child
                ),
              ],
            ),
          );
        },
        child: Column(
          children: [
            // Now Playing
            _nowPlaying(),
            // Player Body
            const ExpandedPlayerBody(),
            // Show Playlist Text, filtered by the exception list
            if (!playlistExceptionFilter.any((element) => element == mediaProvider.currentPlaylistName))
            AnimatedBuilder(
              animation: uiProvider.fwController.animationController,
              builder: (context, child) {
                return SizedBox(
                  height: Tween<double>(begin: 0, end: kToolbarHeight*0.7).animate(uiProvider.fwController.animationController).value,
                  child: Opacity(
                    opacity: (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) > 0
                      ? (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) : 0,
                    child: child
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  // Build mediaSet from the current playing playlist to push playlist page
                  final name = mediaProvider.currentPlaylistName;
                  final albums = MediaItemAlbum.fetchAlbums(mediaProvider.songs);
                  var playlistScreen;
                  if (name == 'Favorites') {
                    playlistScreen = PlaylistScreen(mediaSet: playlistProvider.favorites.toMediaSet());
                  } else if (name == 'Most Played') {
                    
                  } else if (name == 'Downloads') {

                  } else if (playlistProvider.globalPlaylists.any((element) => element.name == name)) {
                    playlistScreen = PlaylistScreen(mediaSet: playlistProvider.globalPlaylists.firstWhere((element) => element.name == name).toMediaSet());
                  } else if (albums.any((element) => element.albumTitle == name)) {
                    playlistScreen = PlaylistScreen(mediaSet: albums.firstWhere((element) => element.albumTitle == name).toMediaSet());
                  }
                  UiUtils.pushRouteAsync(navigatorKey.currentState!.context, playlistScreen, providerContext: context);
                  uiProvider.fwController.close();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Show Playlist', style: tinyTextStyle(context, bold: true)),
                    Icon(Icons.expand_less, color: Theme.of(context).iconTheme.color, size: 18)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nowPlaying() {
    return AnimatedBuilder(
      animation: uiProvider.fwController.animationController,
      builder: (context, child) {
        return SizedBox(
          height: Tween<double>(begin: 0, end: kToolbarHeight).animate(uiProvider.fwController.animationController).value,
          child: Opacity(
            opacity: (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) > 0
              ? (uiProvider.fwController.animationController.value - (1 - uiProvider.fwController.animationController.value)) : 0,
            child: Transform.translate(
              offset: Offset(0, Tween<double>(begin: -64, end: 0).animate(uiProvider.fwController.animationController).value),
              child: child
            ),
          ),
        );
      },
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Hide Player Button
          IconButton(
            onPressed: () {
              uiProvider.fwController.close();
            },
            icon: Icon(Icons.expand_more_rounded, color: song.palette?.text ?? Theme.of(context).iconTheme.color)
          ),
          // Now Playing Text
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                child: Text(
                  mediaProvider.currentPlaylistName ?? 'Unknown Playlist',
                  style: subtitleTextStyle(context, bold: true).copyWith(letterSpacing: 1, color: song.palette?.text)
                ),
              ),
            ),
          ),
          // Show Equalizer
          IconButton(
            onPressed: () async {
              final equalizerMap = await audioHandler.customAction('retrieveEqualizer');
              final loudnessMap = await audioHandler.customAction('retrieveLoudnessGain');
              showModalBottomSheet(
                context: internalNavigatorKey.currentContext!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => MusicEqualizerSheet(equalizerMap: equalizerMap, loudnessMap: loudnessMap));
            },
            icon: Icon(Icons.graphic_eq_outlined, color: song.palette?.text ?? Theme.of(context).iconTheme.color)
          ),
          const SizedBox(width: 8)
        ],
      ),
    );
  }

}