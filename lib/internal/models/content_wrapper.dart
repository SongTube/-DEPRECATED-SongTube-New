import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
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

  // Playlist Information
  YoutubePlaylist? playlistDetails;

  // Streaming Video from Playlist
  YoutubeVideo? playlistVideoDetails;

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
        playlistVideoDetails = await ContentService.fetchVideoFromInfoItem(playlistDetails!.streams!.first);
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