import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/colors_palette.dart';

class SongItem {

  /// File path.
  final String id;

  /// A unique id (Commonly used for Artwork & Thumbnails).
  final String modelId;

  /// The title of this media item.
  final String title;

  /// The album this media item belongs to.
  final String? album;

  /// The artist of this media item.
  final String? artist;

  /// The genre of this media item.
  final String? genre;

  /// The duration of this media item.
  final Duration? duration;

  /// The artwork for this media item as a File.
  final File? artworkPath;

  /// The thumbnail for this media item as a File.
  final File? thumbnailPath;

  /// Whether this is playable (i.e. not a folder).
  final bool? playable;

  /// Override the default title for display purposes.
  final String? displayTitle;

  /// Override the default subtitle for display purposes.
  final String? displaySubtitle;

  /// Override the default description for display purposes.
  final String? displayDescription;

  /// Last Modified
  final DateTime lastModified;

  /// Colors Palette
  final ColorsPalette? palette;

  /// Thumbnail Uri for MediaPlayer
  Uri? get thumbnailUri => thumbnailPath != null ? Uri.parse(thumbnailPath!.path) : null;

  /// Transform this object to MediaItem for MediaPlayer
  MediaItem get mediaItem => MediaItem(
    id: id,
    title: title,
    album: album,
    artist: artist,
    genre: genre,
    duration: duration,
    artUri: thumbnailUri,
    playable: playable,
    displayTitle: displayTitle,
    displaySubtitle: displaySubtitle,
    displayDescription: displayDescription,
    extras: {
      'artwork': artworkPath?.path,
      'modelId': modelId,
      'palette': palette?.toMap()
    }
  );

  // Play Count
  int get playCount => sharedPreferences.getInt('$id-playcount') ?? 0;

  // Add a Play Count
  void addPlayCount() => sharedPreferences.setInt('$id-playcount', playCount+1);

  factory SongItem.fromMediaItem(MediaItem item) {
    FileStat stats = FileStat.statSync(item.id);
    return SongItem(
      id: item.id,
      modelId: item.extras != null ? item.extras!['modelId'] : '',
      title: item.title,
      album: item.album,
      artist: item.artist,
      genre: item.genre,
      duration: item.duration,
      artworkPath: item.extras != null ? File(item.extras!['artwork']
        .replaceAll('file://', '')
        .replaceAll('file//', '')) : null,
      thumbnailPath: File(item.artUri.toString()
        .replaceAll('file://', '')
        .replaceAll('file//', '')),
      playable: item.playable,
      displayTitle: item.displayTitle,
      displaySubtitle: item.displaySubtitle,
      displayDescription: item.displayDescription,
      lastModified: stats.changed,
      palette: item.extras != null ? ColorsPalette.fromMap(item.extras!['palette']) : null
    );
  }

  SongItem({
    required this.id,
    required this.modelId,
    required this.title,
    this.album,
    this.artist,
    this.genre,
    this.duration,
    this.artworkPath,
    this.thumbnailPath,
    this.playable,
    this.displayTitle,
    this.displaySubtitle,
    this.displayDescription,
    required this.lastModified,
    this.palette
  });

  SongItem copyWith({
    String? id,
    String? modelId,
    String? title,
    String? album,
    String? artist,
    String? genre,
    Duration? duration,
    File? artworkPath,
    File? thumbnailPath,
    bool? playable,
    String? displayTitle,
    String? displaySubtitle,
    String? displayDescription,
    DateTime? lastModified,
    ColorsPalette? palette,
  }) {
    return SongItem(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      artworkPath: artworkPath ?? this.artworkPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      playable: playable ?? this.playable,
      displayTitle: displayTitle ?? this.displayTitle,
      displaySubtitle: displaySubtitle ?? this.displaySubtitle,
      displayDescription: displayDescription ?? this.displayDescription,
      lastModified: lastModified ?? this.lastModified,
      palette: palette ?? this.palette,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'title': title,
      'album': album,
      'artist': artist,
      'genre': genre,
      'duration': duration?.inSeconds,
      'artworkPath': artworkPath?.path,
      'thumbnailPath': thumbnailPath?.path,
      'playable': playable,
      'displayTitle': displayTitle,
      'displaySubtitle': displaySubtitle,
      'displayDescription': displayDescription,
      'lastModified': lastModified.toString(),
      'palette': palette?.toMap()
    };
  }

  factory SongItem.fromMap(Map<String, dynamic> map) {
    return SongItem(
      id: map['id'] ?? '',
      modelId: map['modelId'] ?? '',
      title: map['title'] ?? '',
      album: map['album'],
      artist: map['artist'],
      genre: map['genre'],
      duration: map['duration'] != null ? Duration(seconds: map['duration']) : null,
      artworkPath: map['artworkPath'] != null ? File(map['artworkPath']) : null,
      thumbnailPath: map['thumbnailPath'] != null ? File(map['thumbnailPath']) : null,
      playable: map['playable'],
      displayTitle: map['displayTitle'],
      displaySubtitle: map['displaySubtitle'],
      displayDescription: map['displayDescription'],
      lastModified: DateTime.parse(map['lastModified']),
      palette: map['palette'] != null ? ColorsPalette.fromMap(map['palette']) : null
    );
  }

  String toJson() => json.encode(toMap());

  factory SongItem.fromJson(String source) => SongItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongItem(id: $id, modelId: $modelId, title: $title, album: $album, artist: $artist, genre: $genre, duration: $duration, artworkPath: $artworkPath, thumbnailPath: $thumbnailPath, playable: $playable, displayTitle: $displayTitle, displaySubtitle: $displaySubtitle, displayDescription: $displayDescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SongItem &&
      other.id == id &&
      other.modelId == modelId &&
      other.title == title &&
      other.album == album &&
      other.artist == artist &&
      other.genre == genre &&
      other.duration == duration &&
      other.artworkPath == artworkPath &&
      other.thumbnailPath == thumbnailPath &&
      other.playable == playable &&
      other.displayTitle == displayTitle &&
      other.displaySubtitle == displaySubtitle &&
      other.displayDescription == displayDescription &&
      other.lastModified == lastModified &&
      other.palette == palette;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      modelId.hashCode ^
      title.hashCode ^
      album.hashCode ^
      artist.hashCode ^
      genre.hashCode ^
      duration.hashCode ^
      artworkPath.hashCode ^
      thumbnailPath.hashCode ^
      playable.hashCode ^
      displayTitle.hashCode ^
      displaySubtitle.hashCode ^
      displayDescription.hashCode ^
      lastModified.hashCode ^
      palette.hashCode;
  }
}
