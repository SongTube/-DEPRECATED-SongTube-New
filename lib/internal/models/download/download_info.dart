import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoOnlyStream.dart';
import 'package:songtube/internal/enums/download_type.dart';
import 'package:songtube/internal/models/audio_tags.dart';
import 'package:songtube/internal/models/stream_segment_track.dart';

class DownloadInfo {

  DownloadInfo({
    required this.url,
    required this.duration,
    required this.downloadType,
    required this.audioStream,
    required this.tags,
    this.segmentTracks,
    this.videoStream
  });

  final String url;
  final int duration;
  final DownloadType downloadType;
  final AudioOnlyStream audioStream;
  final VideoOnlyStream? videoStream;
  final List<StreamSegmentTrack>? segmentTracks;
  AudioTags tags;

  static Future<DownloadInfo> initializeFromUrl(String url, DownloadType downloadType) async {
    final data = await VideoExtractor.getStream(url);
    return DownloadInfo(
      url: url,
      duration: data.videoInfo.length ?? 0,
      downloadType: downloadType,
      audioStream: data.audioWithHighestQuality!,
      tags: AudioTags.withStreamInfoItem(data.toStreamInfoItem())
    );
  }

  

}