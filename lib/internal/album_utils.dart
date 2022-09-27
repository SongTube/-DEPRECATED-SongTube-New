import 'dart:io';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';

class AlbumUtils {

  // Album Artwork Getter, if it aint available, it will be
  static Future<File> getAlbumImageFromSong(String path, String modelId) async {
    if (await artworkFile(modelId).exists()) {
      return artworkFile(modelId);
    } else {
      await MediaUtils.writeDefaultArtwork(path, modelId);
      return artworkFile(modelId);
    }
  }

}