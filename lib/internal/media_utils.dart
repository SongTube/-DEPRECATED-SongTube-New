import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_tagger/audio_tagger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:songtube/internal/cache_utils.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/colors_palette.dart';
import 'package:songtube/internal/models/song_item.dart';

class MediaUtils {

  static Future<void> fetchDeviceSongs(Function(SongItem) onUpdateTrigger) async {
    // New songs found on device
    List<SongInfo> userSongs = await FlutterAudioQuery()
      .getSongs(sortType: SongSortType.DISPLAY_NAME);
    // Cached Songs
    List<MediaItem> cachedSongs = fetchCachedSongsAsMediaItems();
    // Filter out non needed songs from this process
    // ignore: avoid_function_literals_in_foreach_calls
    cachedSongs.forEach((item) {
      if (userSongs.any((element) => element.filePath == item.id)) {
        userSongs.removeWhere((element) => element.filePath == item.id);
      }
    });
    // Build Thumbnails
    Stopwatch thumbnailsStopwatch = Stopwatch()..start();
    for (final song in userSongs) {
      await writeDefaultThumbnail(song.filePath, song.id);
    }
    thumbnailsStopwatch.stop();
    if (kDebugMode) {
      print('Thumbnails spent a total of ${thumbnailsStopwatch.elapsed.inSeconds}s');
    }
    final List<SongItem> songs = [];
    for (final element in userSongs) {
      try {
        final song = await MediaUtils.convertToSongItem(element);
        songs.add(song);
        onUpdateTrigger(song);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    CacheUtils.cacheSongs = fetchCachedSongsAsSongItems()..addAll(songs);
  }

  // Writes the default Artwork image to the given song id
  // path for the file is needed to check if it exists before processing the image
  static Future<void> writeDefaultArtwork(String? path, String modelId) async {
    try {
      if (!(await artworkFile(modelId).exists())) {
        if (path != null) {
          final artwork = await AudioTagger.extractArtwork(path);
          if (artwork != null && artwork.isNotEmpty) {
            await artworkFile(modelId).writeAsBytes(artwork);
          } else {
            await writeDefaultImage(modelId);
          }
        } else {
          await writeDefaultImage(modelId);
        }
      }
    } catch (e) {
      await writeDefaultImage(modelId);
    }
  }

  // Writes the default Thumbnail image to the given song id
  // path for the file is needed to check if it exists before processing the image
  static Future<void> writeDefaultThumbnail(String? path, String modelId) async {
    try {
      if (!(await thumbnailFile(modelId).exists())) {
        if (path != null) {
          final thumbnail = await AudioTagger.extractThumbnail(path);
          if (thumbnail != null && thumbnail.isNotEmpty) {
            await thumbnailFile(modelId).writeAsBytes(thumbnail);
          } else {
            await writeDefaultImage(modelId, isArtwork: false);
          }
        } else {
          await writeDefaultImage(modelId, isArtwork: false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      await writeDefaultImage(modelId, isArtwork: false);
    }
  }

  // Writes the default asset image to the given song id
  static Future<void> writeDefaultImage(String modelId, {bool isArtwork = true}) async {
    final file = isArtwork ? artworkFile(modelId) : thumbnailFile(modelId);
    final byteData = await rootBundle.load('assets/images/artworkPlaceholder_big.png');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  static MediaItem fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      genre: map['genre'],
      duration: Duration(milliseconds: int.parse(map['duration'])),
      artUri: Uri.parse(map['artUri']),
      displayTitle: map['displayTitle'],
      displaySubtitle: map['displaySubtitle'],
      displayDescription: map['displayDescription'],
      extras: {
        'lastModified': map['lastModified'] == ''
          ? null : map['lastModified']
      }
    );
  }

  static Map<String, dynamic> toMap(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'album': item.album,
      'artist': item.artist,
      'genre': item.genre,
      'duration': item.duration!.inMilliseconds.toString(),
      'artUri': item.artUri.toString(),
      'displayTitle': item.displayTitle,
      'displaySubtitle': item.displaySubtitle,
      'displayDescription': item.displayDescription,
      'lastModified': item.extras?['lastModified'] ?? ''
    };
  } 

  static List<MediaItem> fromMapList(List<dynamic> list) {
    return List<MediaItem>.generate(list.length, (index) {
      return fromMap(list[index]);
    });
  }

  static List<Map<String, dynamic>> toMapList(List<MediaItem> list) {
    return List<Map<String, dynamic>>.generate(list.length, (index) {
      return toMap(list[index]);
    });
  }

  // Convert any List<SongFile> to a List<MediaItem>
  static Future<SongItem> convertToSongItem(SongInfo element) async {
    int hours = 0;
    int minutes = 0;
    int? micros;
    List<String> parts = element.duration!.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    Duration duration = Duration(
      milliseconds: Duration(
        hours: hours, 
        minutes: minutes,
        microseconds: micros
      ).inMilliseconds
    );
    FileStat stats = await FileStat.stat(element.filePath!);
    PaletteGenerator palette;
    try {
      palette = await PaletteGenerator.fromImageProvider(FileImage(thumbnailFile(element.id)));
    } catch (e) {
      await MediaUtils.writeDefaultImage(element.id, isArtwork: false);
      palette = await PaletteGenerator.fromImageProvider(FileImage(thumbnailFile(element.id)));
    }
    return SongItem(
      id: element.filePath!,
      modelId: element.id,
      title: element.title!,
      album: element.album,
      artist: element.artist,
      artworkPath: artworkFile(element.id),
      thumbnailPath: thumbnailFile(element.id),
      duration: duration,
      lastModified: stats.changed,
      palette: ColorsPalette(
        dominant: palette.dominantColor?.color,
        vibrant: palette.vibrantColor?.color,
      )
    );
  }

  static List<SongItem> fetchCachedSongsAsSongItems() {
    final songString = sharedPreferences.getString('deviceSongs');
    if (songString != null) {
      final List<dynamic> songsMap = jsonDecode(songString);
      final songs = List<SongItem>.generate(songsMap.length, (index) {
        return SongItem.fromMap(songsMap[index]);
      });
      return songs;
    } else {
      return [];
    }
  }

  static List<MediaItem> fetchCachedSongsAsMediaItems() {
    final items = fetchCachedSongsAsSongItems();
    return List<MediaItem>.generate(items.length, (index) => items[index].mediaItem);
  }

}