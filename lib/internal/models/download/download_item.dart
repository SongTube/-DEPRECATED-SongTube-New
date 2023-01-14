import 'dart:io';

import 'package:audio_tagger/audio_tagger.dart' as tagger;
import 'package:audio_tagger/audio_tags.dart' as tags;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:newpipeextractor_dart/utils/url.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:songtube/internal/artwork_manager.dart';
import 'package:songtube/internal/enums/download_status.dart';
import 'package:songtube/internal/enums/download_type.dart';
import 'package:songtube/internal/ffmpeg/converter.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/audio_tags.dart';
import 'package:songtube/internal/models/download/download_info.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

class DownloadItem {

  DownloadItem({
    required this.downloadInfo,
    required this.downloadPath,
    required this.downloadFile,
    required this.onDownloadCancelled,
    required this.onDownloadCompleted
  });

  final String id = const Uuid().v4();
  final DownloadInfo downloadInfo;

  // It is recommended to initialize this object with this static function as new data
  // that might be added in the future (which would be required to initialize this object)
  // might be obtained asynchroniously, therefore to avoid nullable essential variables
  // we can initialize them here.
  static Future<DownloadItem> buildData({required DownloadInfo info, Directory? preloadedDirectory}) async {
    // Build the download path
    final directory = preloadedDirectory ?? await getApplicationDocumentsDirectory();
    final fileName = info.tags.titleController.text;
    // Return built download item
    return DownloadItem(downloadInfo: info,
      downloadPath: directory,
      downloadFile: File('${directory.path}/$fileName.${info.audioStream.formatSuffix}'),
      onDownloadCancelled: (_) {},
      onDownloadCompleted: (_, __) {}
    );
  }

  // File path & Name
  final Directory downloadPath;
  File downloadFile;

  // Download Callbacks
  Function(String id, SongItem song) onDownloadCompleted;
  Function(String id) onDownloadCancelled;

  // Download Related Stuff
  final BehaviorSubject<double?> downloadProgress = BehaviorSubject.seeded(0);
  final BehaviorSubject<String?> downloadStatus = BehaviorSubject.seeded('queued');

  // Conversion Related Stuff
  // final FfmpegTask conversionTask =

  // Error message in case anything goes wrong
  String? errorMessage;

  // Cancel Status
  bool canceled = false;

  // Reset current Streams
  void resetStreams() {
    downloadProgress.add(null);
    downloadStatus.add(null);
  }

  // Close Streams, when the initDownload() process has finalized
  // or this download object is no longer needed
  void closeStreams() {
    downloadProgress.close();
    downloadStatus.close();
  }

  // Convert this download item onto a SongItem so it can be saved
  // into the downloaded list
  Future<SongItem> toSongItem({AudioTags? tags, File? file}) async {
    return MediaUtils.downloadToSongItem(
      tags != null ? (downloadInfo..tags = tags) : downloadInfo,
      file != null ? file.path : downloadFile.path);
  }

  // Initialize this media download, this process should take care of everything
  // from downloading, to conversion, tagging and more, but the file has to be
  // the same, by making a copy, motifying it and overriding this object downloadFile
  //
  // Anything we need to run to process the download must check if canceled is true
  // and stop this function as soon as possible
  Future<void> initDownload() async {
    downloadStatus.add('Initializing...');
    resetStreams();
    // Start Downloading
    if (downloadInfo.downloadType == DownloadType.audio && (downloadInfo.segmentTracks?.isEmpty ?? true)) {
      // Download Audio Stream, we don't need the resulting file because its gonna
      // be written directly into the given output
      final result = await _downloadStream(downloadInfo.audioStream, context: 'Downloading', output: downloadFile);
      // If download result is null, cancel download
      if (result == null) {
        onDownloadCancelled(id);
        return;
      }
      // Clean up download file
      downloadStatus.add('Clearing tags...');
      downloadFile = await FFmpegConverter.clearFileMetadata(downloadFile.path);
      // Apply Filters
      if (downloadInfo.filters.normalizeAudio) {
        downloadStatus.add('Reencoding (Normalize)...');
        downloadFile = await FFmpegConverter.normalizeAudio(downloadFile.path);
      }
      if (downloadInfo.filters.conversionRequired) {  
        downloadStatus.add('Reencoding (Filters)...');
        downloadFile = await FFmpegConverter.applyAudioModifiers(downloadFile.path, downloadInfo.filters);
      }
      // Convert Audio File
      if (downloadInfo.conversionTask != null) { 
        downloadStatus.add('Reencoding (Conversion)...');
        downloadFile = await FFmpegConverter.convertAudio(audioFile: downloadFile.path, task: downloadInfo.conversionTask!);
      }
      // Write all Tags to this Song
      await writeAllMetadata(downloadFile.path, downloadInfo.tags);
      // Deem this download as completed
      downloadStatus.add('Saving download...');
      onDownloadCompleted(id, await toSongItem());
    }
  }
  
  

  // Start Downloading our Stream
  Future<File?> _downloadStream(dynamic stream, {required String context, File? output}) async {
    // Download
    File download = output ?? File(
      "${(await getExternalStorageDirectory())!.path}/${MediaUtils.getRandomString(10)}"
    );
    if (await download.exists()) {
      await download.delete();
    }
    await download.create();
    // Update Streams
    downloadStatus.add(context);
    // Stream to Download
    dynamic streamToDownload = stream;
    // Try fetch content-length
    int contentLengthTries = 0;
    if (streamToDownload.size == null) {
      while (contentLengthTries < 4) {
        streamToDownload.size = await MediaUtils.getContentSize(streamToDownload.url);
        if (streamToDownload.size != null) {
          break;
        } else {
          print('content size null, retrying...');
        }
      }
    }
    // Check if content-lenght is still null, if it is, cancel download
    if (streamToDownload.size == null) {
      return null;
    }
    // StreamData
    Stream<List<int>> streamData = ExtractorHttpClient.getStream(streamToDownload, headers: {
      'Keep-Alive': 'timeout=1, max=1000'
    });
    // Update Streams
    downloadProgress.add(0.0);
    // Open the file in write.
    final ioSink = download.openWrite(mode: FileMode.write);
    // Track Downloaded Bytes
    int totalDownloaded = 0;
    // Start stream download while updating internal
    // BehaviorSubject for external access
    await for (var data in streamData) {
      if (canceled) {
        ioSink.close();
        downloadStatus.add('Canceled');
        onDownloadCancelled(id);
        return null;
      }
      totalDownloaded += data.length;
      downloadProgress.add((totalDownloaded/streamToDownload.size));
      ioSink.add(data);
    }
    await ioSink.flush();
    await ioSink.close();
    return download;
  }

  // Write Tags & Artwork
  Future<void> writeAllMetadata(String filePath, AudioTags userTags) async {
    downloadStatus.add('Writting Tags...');
    try {
      await tagger.AudioTagger.writeAllTags(
        songPath: filePath,
        tags: tags.AudioTags(
          title: userTags.titleController.text,
          album: userTags.albumController.text,
          artist: userTags.artistController.text,
          genre: userTags.genreController.text,
          year: userTags.dateController.text,
          disc: userTags.discController.text,
          track: userTags.trackController.text
        )
      );
      // Only add Artwork if song is in AAC Format
      if (downloadInfo.audioStream.formatSuffix == 'm4a') {
        File croppedImage = File(
          "${(await getExternalStorageDirectory())!.path}/${MediaUtils.getRandomString(5)}"
        );
        if (isURL(userTags.artwork)) {
          File artwork = File(
            "${(await getExternalStorageDirectory())!.path}/${MediaUtils.getRandomString(5)}"
          );
          Response? response;
          try {
            response = await get(Uri.parse(userTags.artwork));
            await artwork.writeAsBytes(response.bodyBytes);
            var decodedImage = await decodeImageFromList(artwork.readAsBytesSync());
            if (decodedImage.width == 120 && decodedImage.height == 90) {
              response = null;
            }
          } catch (_) {}
          // If it doesnt exist try Getting MediumQuality Artwork
          if (response == null) {
            try {
              String? id = await YoutubeId.getIdFromStreamUrl(downloadInfo.url);
              response = await get(Uri.parse("https://img.youtube.com/vi/$id/mqdefault.jpg"))
                .timeout(const Duration(seconds: 30));
              await artwork.writeAsBytes(response.bodyBytes);
              downloadInfo.tags.artwork = "https://img.youtube.com/vi/$id/mqdefault.jpg";
            } catch (_) {}
          }
          await croppedImage.writeAsBytes(
            (await tagger.AudioTagger.cropToSquare(artwork))!.toList());
        } else {
          await croppedImage.writeAsBytes(
            (await tagger.AudioTagger.cropToSquare(File(userTags.artwork)))!.toList());
        }
        await ArtworkManager.writeArtwork(filePath, forceRefresh: true, artwork: croppedImage, embedToSong: true);
        await ArtworkManager.writeThumbnail(filePath, forceRefresh: true, artwork: croppedImage);
        
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

}