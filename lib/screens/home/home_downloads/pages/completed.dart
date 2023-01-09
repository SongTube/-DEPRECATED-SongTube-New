import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/song_tile.dart';

class DownloadsCompletedPage extends StatefulWidget {
  const DownloadsCompletedPage({super.key});

  @override
  State<DownloadsCompletedPage> createState() => _DownloadsCompletedPageState();
}

class _DownloadsCompletedPageState extends State<DownloadsCompletedPage> {
  @override
  Widget build(BuildContext context) {
    DownloadProvider downloadProvider = Provider.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: downloadProvider.downloadedSongs.isEmpty
        ? Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Ionicons.cloud_download_outline, size: 64),
              const SizedBox(height: 8),
              Text('No downloads yet', style: textStyle(context)),
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Text('Go home, search for something to download or wait for the queue!', style: subtitleTextStyle(context, opacity: 0.6), textAlign: TextAlign.center,),
              ),
            ],
          ))
        : _body(),
    );
  }

  Widget _body() {
    DownloadProvider downloadProvider = Provider.of<DownloadProvider>(context);
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    UiProvider uiProvider = Provider.of(context);
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final playerOpened = snapshot.data != null;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8).copyWith(bottom: playerOpened ? (kToolbarHeight*1.6)+24 : 24),
          physics: const BouncingScrollPhysics(),
          itemCount: downloadProvider.downloadedSongs.length,
          itemBuilder: (context, index) {
            final song = downloadProvider.downloadedSongs[index];
            return SongTile(
              song: song,
              onPlay: () async {
                mediaProvider.currentPlaylistName = 'Downloads';
                final queue = List<MediaItem>.generate(downloadProvider.downloadedSongs.length, (index) {
                  return downloadProvider.downloadedSongs[index].mediaItem;
                });
                uiProvider.currentPlayer = CurrentPlayer.music;
                mediaProvider.playSong(queue, index);
              }
            );
          }
        );
      }
    );
  }
}