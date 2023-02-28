import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:newpipeextractor_dart/extractors/search.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/app_settings.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/channel_data.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/services/content_service.dart';

class ContentProvider extends ChangeNotifier {

  ContentProvider() {
    // Fetch Trending page for the Home Screen
    refreshTrendingPage();
  }

  // Home Screen Trending page videos
  List<StreamInfoItem>? trendingVideos;

  // Home Screen suggested Channels based on our Trending Videos
  List<ChannelData> get channelSuggestions {
    final channels = <ChannelData>[];
    if (trendingVideos != null) {
      for (final video in trendingVideos!) {
        final exist = channels.where((element) => element.url == video.uploaderUrl);
        if (exist.isEmpty) {
          channels.add(ChannelData(name: video.uploaderName??'', url: video.uploaderUrl??'', heroId: video.id??''));
        }
      }
      return channels;
    } else {
      return [];
    }
  }

  // Search Videos
  YoutubeSearch? searchContent;
  bool searchingContent = false;
  void searchContentFor(String query) async {
    searchContent = null;
    searchingContent = true;
    notifyListeners();
    try {
      searchContent = await SearchExtractor.searchYoutube(query, []);
      addStringtoSearchHistory(query);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    searchingContent = false;
    notifyListeners();
  }
  void clearSearchContent() {
    searchContent = null;
    notifyListeners();
  }

  // Refresh Trending page
  void refreshTrendingPage() {
    ContentService.getTrendingPage().then((value) {
      trendingVideos = value;
      notifyListeners();
    });
  }

  // Current Playing Content (Stream/Playlist)
  ContentWrapper? _playingContent;
  ContentWrapper? get playingContent => _playingContent;
  set playingContent(ContentWrapper? content) {
    _playingContent = content;
    notifyListeners();
    // If our content is not null, we can assume it is a video or playlist
    // in any case, we can automatically initialize this content
    if (_playingContent != null) {
      _playingContent!.loadWrapper().then((value) {
        notifyListeners();
      });
    }
  }

  // Load the video player with provided InfoItem
  void loadVideoPlayer(dynamic infoItem) async {
    if (infoItem == null) {
      return;
    }
    // Switch to VideoPlayer
    Provider.of<UiProvider>(navigatorKey.currentState!.context, listen: false).currentPlayer = CurrentPlayer.video;
    // Check wheter this InfoItem is a Stream/Playlist and load accordingly
    // if a String was provided, most probably it is a URL, we can also load from that
    if (infoItem is StreamInfoItem || infoItem is PlaylistInfoItem) {
      playingContent = ContentWrapper(infoItem: infoItem);
      if (infoItem is StreamInfoItem) {
        saveToHistory(infoItem);
      }
    } else if (infoItem is String) {
      final YoutubeVideo item = await ContentService.fetchInfoItemFromUrl(infoItem);
      playingContent = ContentWrapper(infoItem: item.toStreamInfoItem())
        ..videoDetails = item;
      saveToHistory(item.toStreamInfoItem());
    }
  }

  // Next playlist video getter
  StreamInfoItem? get nextPlaylistVideo {
    if (playingContent?.videoDetails != null && playingContent?.infoItem is PlaylistInfoItem) {
      final currentIndex = playingContent!.playlistDetails!.streams!
        .indexWhere((element) => element.id == playingContent!.videoDetails!.toStreamInfoItem().id);
      final length = playingContent!.playlistDetails!.streams!.length-1;
      return currentIndex == length ? null : playingContent!.playlistDetails!.streams![currentIndex+1];
    } else {
      return null;
    }
  }
  // Load next video in Playlist
  void loadNextPlaylistVideo() async {
    if (nextPlaylistVideo != null) {
      // Remove previous videos so the player enters a loading state
      playingContent!.videoDetails = null;
      notifyListeners();
      // Load next video
      playingContent!.videoDetails = await ContentService.fetchVideoFromInfoItem(nextPlaylistVideo!);
      saveToHistory(nextPlaylistVideo!);
      notifyListeners();
    }
  }

  // End the video player
  void endVideoPlayer() {
    playingContent = null;
    notifyListeners();
  }

  // Retrieve list of all videos on Watch History
  

  // Save video to Watch History
  Future<void> saveToHistory(StreamInfoItem video) async {
    if (AppSettings.enableWatchHistory) {
      String? json = sharedPreferences.getString('watchHistory');
      if (json == null) {
        List<StreamInfoItem> videos = [video];
        List<Map<dynamic, dynamic>> map =
        videos.map((e) => e.toMap()).toList();
        sharedPreferences.setString('watchHistory', jsonEncode(map));
      } else {
        List<StreamInfoItem> history = [];
        var map = jsonDecode(json);
        if (map.isNotEmpty) {
          map.forEach((element) {
            history.add(StreamInfoItem.fromMap(element));
          });
        }
        if (history.indexWhere((element) => element.url == video.url) != -1) {
          history.removeAt(history.indexWhere((element) => video.url == element.url));
          history.insert(0, video);
        } else {
          history.insert(0, video);
        }
        map = history.map((e) => e.toMap()).toList();
        sharedPreferences.setString('watchHistory', jsonEncode(map));
      }
    }
  }

  // Search History
  List<String> getSearchHistory() => sharedPreferences.getStringList('searchHistory') ?? [];
  void addStringtoSearchHistory(String searchQuery) {
    final searchHistory = getSearchHistory();
    if (searchHistory.contains(searchQuery)) {
      searchHistory.removeWhere((element) => element == searchQuery);
      searchHistory.insert(0, searchQuery);
    } else {
      searchHistory.insert(0, searchQuery);
    }
    sharedPreferences.setStringList('searchHistory', searchHistory);
  }
  void removeStringfromSearchHistory(int index) {
    final searchHistory = getSearchHistory();
    searchHistory.removeAt(index);
    sharedPreferences.setStringList('searchHistory', searchHistory);
    notifyListeners();
  }

}