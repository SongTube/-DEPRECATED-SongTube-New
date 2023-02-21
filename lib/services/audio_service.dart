import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

MediaControl playControl = const MediaControl(
  androidIcon: 'drawable/ic_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = const MediaControl(
  androidIcon: 'drawable/ic_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = const MediaControl(
  androidIcon: 'drawable/ic_navigate_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = const MediaControl(
  androidIcon: 'drawable/ic_navigate_before',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = const MediaControl(
  androidIcon: 'drawable/ic_clear',
  label: 'Stop',
  action: MediaAction.stop,
);

class StAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {

  StAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  late final _player = AudioPlayer(audioPipeline: AudioPipeline(
    androidAudioEffects: [ equalizer, loudnessEnhancer ]));
  final _playlist = ConcatenatingAudioSource(children: []);

  // Equalizer
  AndroidEqualizer equalizer = AndroidEqualizer();
  AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: getControls(),
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri(path: mediaItem.id),
      tag: MediaItem(
        id: mediaItem.id,
        title: mediaItem.title,
        artist: mediaItem.artist,
        album: mediaItem.album,
        genre: mediaItem.genre,
        duration: mediaItem.duration,
        artUri: Uri.parse('file://${mediaItem.artUri.toString()}'),
        extras: mediaItem.extras,
      )
    );
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    _player.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    final audioSource = newQueue.map(_createAudioSource);
    await _playlist.clear();
    await _playlist.addAll(audioSource.toList());
    queue.add(newQueue);
    return super.updateQueue(newQueue);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }
  
  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == "retrieveEqualizer") {
      final parameters = await equalizer.parameters;
      final map = {
        'enabled': equalizer.enabled ? 'true' : 'false',
        'bands': List.generate(parameters.bands.length, (index) {
          final band = parameters.bands[index];
          return {
            'centerFrequency': band.centerFrequency,
            'minFreq': parameters.minDecibels,
            'maxFreq': parameters.maxDecibels,
            'gain': band.gain
          };
        })
      };
      return map;
    }
    if (name == "updateEqualizer") {
      final enabled = extras!['enabled'] == 'true' ? true : false;
      if (enabled) {
        await equalizer.setEnabled(true);
      } else {
        await equalizer.setEnabled(false);
      }
      final bands = List.from(extras['bands']);
      final parameters = await equalizer.parameters;
      for (int i = 0; parameters.bands.length > i; i++) {
        final bandMap = Map<String, dynamic>.from(bands[i]);
        parameters.bands[i].setGain(bandMap["gain"]);
      }
    }
    if (name == 'retrieveLoudnessGain') {
      return {
        'enabled': loudnessEnhancer.enabled ? 'true' : 'false',
        'gain': loudnessEnhancer.targetGain
      };
    }
    if (name == 'updateLoudnessGain') {
      final enabled = extras!['enabled'] == 'true' ? true : false;
      if (enabled) {
        await loudnessEnhancer.setEnabled(true);
      } else {
        await loudnessEnhancer.setEnabled(false);
      }
      final gain = extras['gain'] as double;
      loudnessEnhancer.setTargetGain(gain);
    }
    return null;
  }


  /// Get MediaPlayer Controls
  List<MediaControl> getControls() {
    if (_player.playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        skipToNextControl,
        stopControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        skipToNextControl,
        stopControl,
      ];
    }
  }

}