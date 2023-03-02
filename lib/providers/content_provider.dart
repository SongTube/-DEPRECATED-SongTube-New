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
    if (playingContent?.infoItem is PlaylistInfoItem && playingContent?.playlistDetails != null) {
      final currentIndex = playingContent!.selectedPlaylistIndex ?? 0;
      final length = playingContent!.playlistDetails!.streams!.length-1;
      return currentIndex == length ? null : playingContent!.playlistDetails!.streams![currentIndex+1];
    } else {
      return null;
    }
  }
  // Load next video in Playlist
  void loadNextPlaylistVideo({StreamInfoItem? override}) async {
    playingContent!.videoDetails = null;
    notifyListeners();
    if (override != null) {
      // Load next video from the provided override
      playingContent?.selectedPlaylistIndex = playingContent?.playlistDetails?.streams?.indexWhere((element) => element.id == override.id);
      notifyListeners();
      playingContent!.videoDetails = await ContentService.fetchVideoFromInfoItem(override);
      saveToHistory(nextPlaylistVideo!);
      notifyListeners();
    } else {
      if (nextPlaylistVideo != null) {
        // Load next video
        playingContent?.selectedPlaylistIndex = playingContent?.playlistDetails?.streams?.indexWhere((element) => element.id == nextPlaylistVideo?.id);
        notifyListeners();
        playingContent!.videoDetails = await ContentService.fetchVideoFromInfoItem(nextPlaylistVideo!);
        saveToHistory(nextPlaylistVideo!);
        notifyListeners();
      }
    }
  }

  // End the video player
  void endVideoPlayer() {
    playingContent = null;
    notifyListeners();
  }

  // Save playlist to favorites


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

  // Favorite Videos
  List<StreamInfoItem> get favoriteVideos {
    var map = jsonDecode(sharedPreferences.getString('newFavoriteVideos') ?? "{}");
    List<StreamInfoItem> videos = [];
    if (map.isNotEmpty) {
      if (map['favoriteVideos'].isNotEmpty) {
        map['favoriteVideos'].forEach((v) {
          videos.add(StreamInfoItem.fromMap(v));
        });
      }
    }
    return videos;
  }
  set favoriteVideos(List<StreamInfoItem> videos) {
    var map = videos.map((e) {
      return e.toMap();
    }).toList();
    String json = jsonEncode({ 'favoriteVideos': map });
    sharedPreferences.setString('newFavoriteVideos', json).then((_) {
      notifyListeners();
    });
  }
  void saveVideoToFavorites(StreamInfoItem item) {
    favoriteVideos = favoriteVideos..add(item);
    notifyListeners();
  }
  void removeVideoFromFavorites(String id) {
    favoriteVideos = favoriteVideos..removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // ------------------------------------
  // Stream Playlists Creation/Management
  // ------------------------------------
  void loadLocalPlaylist(int index) {
    final playlist = streamPlaylists[index];
    // Switch to video player
    Provider.of<UiProvider>(navigatorKey.currentState!.context, listen: false).currentPlayer = CurrentPlayer.video;
    playingContent = ContentWrapper(infoItem: playlist.toPlaylistInfoItem())..playlistDetails = playlist;
    notifyListeners();
  }
  set streamPlaylists(List<YoutubePlaylist> playlist) {
    String json = playlist.isNotEmpty ? jsonEncode(playlist.map((e) => e.toMap()).toList()) : jsonEncode({});
    sharedPreferences.setString('videoplaylists', json);
    notifyListeners();
  }
  List<YoutubePlaylist> get streamPlaylists {
    String? json = sharedPreferences.getString('videoplaylists');
    if (json != null) {
      final map = jsonDecode(json);
      return List<YoutubePlaylist>.generate(map.length, (index) {
        final playlist = YoutubePlaylist.fromMap(map[index]);
        return playlist..streamCount = playlist.streams!.length;
      });
    } else {
      return [];
    }
  }
  void streamPlaylistCreate(String name, String author, List<StreamInfoItem> streams) {
    final playlist =  YoutubePlaylist(null, name, null, author, null, null, null, streams.first.thumbnails!.maxresdefault, streams.length)..streams = streams;
    streamPlaylists = streamPlaylists..add(playlist);
  }
  void streamPlaylistRemove(String name) {
    int index = streamPlaylists.indexWhere((element) => element.name == name);
    if (index == -1) return;
    streamPlaylists = streamPlaylists..removeAt(index);
  }
  void streamPlaylistsInsertStream(String name, StreamInfoItem stream) {
    int index = streamPlaylists.indexWhere((element) => element.name == name);
    if (index == -1) return;
    final newPlaylist = streamPlaylists[index]..streams!.add(stream);
    newPlaylist.thumbnailUrl ??= stream.thumbnails!.hqdefault;
    streamPlaylists = streamPlaylists..[index] = newPlaylist;
  }
  void streamPlaylistRemoveStream(String name, StreamInfoItem stream) {
    int index = streamPlaylists.indexWhere((element) => element.name == name);
    if (index == -1) return;
    final newPlaylist = streamPlaylists[index]..streams!.removeWhere((element) => element.id == stream.id);
    if (newPlaylist.streams!.isEmpty) {
      newPlaylist.thumbnailUrl = null;
    }
    streamPlaylists = streamPlaylists..[index] = newPlaylist;
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