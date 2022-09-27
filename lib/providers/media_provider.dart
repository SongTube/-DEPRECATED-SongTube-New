import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/ui/components/fancy_scaffold.dart';

class MediaProvider extends ChangeNotifier {

  MediaProvider() {
    songs = MediaUtils.fetchCachedSongsAsSongItems();
    // Check for permissions
    fetchMedia();
  }

  // Status for Storage Permission
  PermissionStatus? permissionStatus;

  // Status for the fetchMedia function
  bool fetchMediaRunning = false;

  // Fetch Songs for this Provider
  Future<void> fetchMedia() async {
    permissionStatus = await Permission.storage.status;
    if (permissionStatus == PermissionStatus.granted) {
      if (kDebugMode) {
        print('Fetching device Media...');
      }
      fetchMediaRunning = true;
      notifyListeners();
      Timer timer = Timer.periodic(const Duration(seconds: 5), (_) {
        notifyListeners();
      });
      await MediaUtils.fetchDeviceSongs((newSong) {
        songs.add(newSong);
      });
      fetchMediaRunning = false;
      timer.cancel();
      notifyListeners();
    }
  }

  // Current Playlist Name
  String? currentPlaylistName;

  // User Songs
  List<SongItem> _songs = [];
  List<SongItem> get songs {
    return _songs..sort(((a, b) => a.title.compareTo(b.title)));
  }
  set songs(List<SongItem> items) {
    _songs = items;
    notifyListeners();
  }

  Future<void> playSong(List<MediaItem> queue, int index) async {
    if (listEquals(queue, audioHandler.queue.value) == false) {
      await audioHandler.updateQueue(queue);
    }
    await audioHandler.skipToQueueItem(index);
  }

  // -------------------
  // Downloader Section
  // -------------------
  

}