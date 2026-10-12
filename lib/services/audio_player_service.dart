import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  final StreamController<Song?> _currentSongController = StreamController<Song?>.broadcast();
  final StreamController<List<Song>> _queueController = StreamController<List<Song>>.broadcast();

  AudioPlayerService() {
    _initListeners();
  }

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;

  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<List<Song>> get queueStream => _queueController.stream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  void _initListeners() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackEnded();
      }
    });
  }

  void _handleTrackEnded() {
    if (_loopMode == LoopMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else {
      next();
    }
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    if (queue != null && queue.isNotEmpty) {
      _queue = List.from(queue);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else {
      if (_queue.isEmpty || !_queue.any((s) => s.id == song.id)) {
        _queue = [song];
        _currentIndex = 0;
      } else {
        _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      }
    }

    _currentSong = song;
    _currentSongController.add(_currentSong);
    _queueController.add(_queue);

    try {
      await _player.stop();
      await _player.setUrl(song.audioUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Error streaming audio from URL: $e');
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffle && _queue.length > 1) {
      final nextIdx = (_currentIndex + 1 + (DateTime.now().millisecond % (_queue.length - 1))) % _queue.length;
      _currentIndex = nextIdx;
    } else {
      if (_currentIndex + 1 < _queue.length) {
        _currentIndex++;
      } else if (_loopMode == LoopMode.all) {
        _currentIndex = 0;
      } else {
        // End of queue and not looping all
        await _player.pause();
        await _player.seek(Duration.zero);
        return;
      }
    }

    final nextSong = _queue[_currentIndex];
    await playSong(nextSong, queue: _queue);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // If current song has played more than 3 seconds, replay from start
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = _queue.length - 1;
    } else {
      await _player.seek(Duration.zero);
      return;
    }

    final prevSong = _queue[_currentIndex];
    await playSong(prevSong, queue: _queue);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
  }

  void toggleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
  }

  void dispose() {
    _player.dispose();
    _currentSongController.close();
    _queueController.close();
  }
}

