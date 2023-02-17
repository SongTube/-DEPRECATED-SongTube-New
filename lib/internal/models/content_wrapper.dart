import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:songtube/internal/models/playback_quality.dart';
import 'package:songtube/services/content_service.dart';
import 'package:songtube/ui/players/video_player/player_widget.dart';
import 'package:songtube/ui/players/video_player/suggestions.dart';
import 'package:video_player/video_player.dart';

class ContentWrapper {

  ContentWrapper({
    required this.infoItem
  });

  // Video/Playlist InfoItem
  final dynamic infoItem;

  // Video Information
  YoutubeVideo? videoDetails;

  // Video Quality
  List<VideoPlaybackQuality>? get videoOnlyOptions =>
    videoDetails != null ? VideoPlaybackQuality.fetchAllVideoOnlyQuality(videoDetails!) : null;

  // Video Quality
  List<VideoPlaybackQuality>? get videoOptions =>
    videoDetails != null ? VideoPlaybackQuality.fetchAllVideoQuality(videoDetails!) : null;

  // Playlist Information
  YoutubePlaylist? playlistDetails;

  // Video Player Controller
  VideoPlayerWidgetController videoPlayerController = VideoPlayerWidgetController();

  // Youtube Video Suggestions Controller
  VideoSuggestionsController videoSuggestionsController = VideoSuggestionsController();

  Future<void> loadWrapper() async {
    if (infoItem is StreamInfoItem) {
      try {
        videoDetails = await ContentService.fetchVideoFromInfoItem(infoItem);
      } catch (e) {
        errorMessage = e.toString();
      }
    } else if (infoItem is PlaylistInfoItem) {
      try {
        playlistDetails = await ContentService.fetchPlaylistFromInfoItem(infoItem);
        await playlistDetails!.getStreams();
        videoDetails = await ContentService.fetchVideoFromInfoItem(playlistDetails!.streams!.first);
      } catch (e) {
        errorMessage = e.toString();
      }
    } else {
      errorMessage = 'InfoItem is an invalid object';
    }
  }

  // Error Message
  String? errorMessage;

}