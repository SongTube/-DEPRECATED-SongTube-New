import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/download/download_info.dart';
import 'package:songtube/internal/models/download/download_item.dart';
import 'package:songtube/internal/models/song_item.dart';

class DownloadProvider extends ChangeNotifier {

  DownloadProvider() {
    downloadedSongs = fetchDownloads();
  } 

  // Queued/Cancelled Downloads
  List<DownloadItem> queue = [];
  List<DownloadItem> canceled = [];

  // Downloaded List
  List<SongItem> downloadedSongs = [];

  // Max simultaneous downloads
  int maxSimultaneousDownloads = 2;

  // Handle Single Video Download
  Future<void> handleDownloadItem({required DownloadInfo info}) async {
    queue.add(await DownloadItem.buildData(info: info)
      ..onDownloadCancelled = (id) {
        moveToCancelled(id);
      }
      ..onDownloadCompleted = (id, songItem) {
        handleNewDownload(song: songItem);
        final index = queue.indexWhere((element) => element.id == id);
        queue.removeAt(index);
        notifyListeners();
        checkQueue();
      });
    checkQueue();
  }

  // Handle Playlist Download
  Future<void> handleDownloadItems({required List<DownloadInfo> infos}) async {
    final directory = await getApplicationDocumentsDirectory();
    for (final info in infos) {
      queue.add(await DownloadItem.buildData(info: info, preloadedDirectory: directory)
        ..onDownloadCancelled = (id) {
          moveToCancelled(id);
        }
        ..onDownloadCompleted = (id, songItem) {
          handleNewDownload(song: songItem);
          final index = queue.indexWhere((element) => element.id == id);
          queue.removeAt(index);
          notifyListeners();
          checkQueue();
        });
    }
    checkQueue();
  }

  void checkQueue() {
    if (queue.isEmpty) return;
    final maxDownloads = queue.length <= maxSimultaneousDownloads
      ? queue.length : maxSimultaneousDownloads;
    for (int i = 0; i < maxDownloads; i++) {
      if (queue[i].downloadStatus.value == 'queued') {
        queue[i].initDownload();
      }
    }
    notifyListeners();
  }

  void moveToCancelled(String id) {
    int index = queue.indexWhere((element)
      => element.id == id);
    canceled.add(queue[index]);
    queue.removeAt(index);
    notifyListeners();
    checkQueue();
  }

  void retryDownload(String id) {
    final index = canceled.indexWhere((element)
      => element.id == id);
    canceled[index].resetStreams();
    queue.add(canceled[index]);
    canceled.removeAt(index);
    notifyListeners();
    checkQueue();
  }

  void cancelDownload(String id) async {
    final index = queue.indexWhere((element)
      => element.id == id);
    queue[index].canceled = true;
    canceled.add(queue[index]);
    queue.removeAt(index);
    notifyListeners();
    checkQueue();
  }

  void handleNewDownload({required SongItem song}) {
    // Update download songs list
    downloadedSongs.add(song);
    // Save song into sharedPreferences
    saveDownload(song);
  }

  // Fetch Downloaded Songs
  List<SongItem> fetchDownloads() {
    final json = sharedPreferences.getString('user-downloads');
    if (json == null) {
      return [];
    } else {
      final List<SongItem> downloadList = [];
      final List<dynamic> mapList = jsonDecode(json);
      for (final element in mapList) {
        downloadList.add(SongItem.fromMap(element));
      }
      return downloadList;
    }
  }

  // Save song to downloads
  Future<void> saveDownload(SongItem song) async {
    final json = sharedPreferences.getString('user-downloads');
    final map = song.toMap();
    if (json == null) {
      List<dynamic> mapList = [map];
      sharedPreferences.setString('user-downloads', jsonEncode(mapList));
    } else {
      final List<dynamic> mapList = jsonDecode(json);
      mapList.add(map);
      sharedPreferences.setString('user-downloads', jsonEncode(mapList));
    }
  }

}