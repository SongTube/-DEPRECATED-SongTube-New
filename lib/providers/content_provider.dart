import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:newpipeextractor_dart/extractors/search.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/channel_data.dart';
import 'package:songtube/internal/models/content_wrapper.dart';
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
    playingContent = null;
    notifyListeners();
    // Check wheter this InfoItem is a Stream/Playlist and load accordingly
    // if a String was provided, most probably it is a URL, we can also load from that
    if (infoItem is StreamInfoItem || infoItem is PlaylistInfoItem) {
      playingContent = ContentWrapper(infoItem: infoItem);
    } else if (infoItem is String) {
      final item = await ContentService.fetchInfoItemFromUrl(infoItem);
      playingContent = ContentWrapper(infoItem: item);
    }
  }

  // End the video player
  void endVideoPlayer() {
    playingContent = null;
    notifyListeners();
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