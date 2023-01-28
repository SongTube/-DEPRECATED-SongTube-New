import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/app_settings.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/players/music_player/background_carousel.dart';
import 'package:songtube/ui/players/music_player/player_body.dart';
import 'package:songtube/ui/text_styles.dart';
 
class MusicPlayer extends StatefulWidget {
  const MusicPlayer({ Key? key }) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {

  // MediaProvider
  MediaProvider get mediaProvider => Provider.of<MediaProvider>(context, listen: false);
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
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedBuilder(
        animation: uiProvider.fwController.animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Blurred Background
              BackgroundCarousel(
                enabled: AppSettings.enableMusicPlayerBlur,
                backgroundImage: File(song.thumbnailUri!.path),
                backdropColor: song.palette!.vibrant ?? Theme.of(context).cardColor,
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
          );
        },
        child: Column(
          children: [
            // Now Playing
            _nowPlaying(),
            // Player Body
            const ExpandedPlayerBody(),
            // Show Playlist Text
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
                  uiProvider.fwController.animationController.animateTo(0, curve: Curves.fastOutSlowIn);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Show Playlist', style: tinyTextStyle(context)),
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
            icon: Icon(Icons.expand_more_rounded, color: Theme.of(context).iconTheme.color)
          ),
          // Now Playing Text
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                child: Text(
                  mediaProvider.currentPlaylistName ?? 'Unknown Playlist',
                  style: subtitleTextStyle(context)
                ),
              ),
            ),
          ),
          // Show Equalizer
          IconButton(
            onPressed: () {
              uiProvider.fwController.close();
            },
            icon: Icon(Icons.graphic_eq_outlined, color: Theme.of(context).iconTheme.color)
          ),
          const SizedBox(width: 8)
        ],
      ),
    );
  }

}