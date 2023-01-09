import 'dart:io';
import 'package:songtube/internal/artwork_manager.dart';
import 'package:songtube/internal/media_utils.dart';

class AlbumUtils {

  // Album Artwork Getter, if it aint available, it will be
  static Future<File> getAlbumImageFromSong(String path, String modelId) async {
    if (await artworkFile(modelId).exists()) {
      return artworkFile(modelId);
    } else {
      await ArtworkManager.writeDefaultThumbnail(path);
      return artworkFile(modelId);
    }
  }

}