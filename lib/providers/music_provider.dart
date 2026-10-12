import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_player_service.dart';
import '../services/music_api_service.dart';

class MusicProvider extends ChangeNotifier {
  final MusicApiService _apiService = MusicApiService();
  final AudioPlayerService _audioService = AudioPlayerService();

  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  List<Playlist> _defaultPlaylists = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  Song? _currentSong;
  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _bufferedPositionSub;
  StreamSubscription? _currentSongSub;

  MusicProvider() {
    _init();
  }

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Song> get songs => _filteredSongs;
  List<Playlist> get defaultPlaylists => _defaultPlaylists;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  AudioPlayerService get audioService => _audioService;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _playerState.playing;
  bool get isBuffering =>
      _playerState.processingState == ProcessingState.buffering ||
      _playerState.processingState == ProcessingState.loading;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  bool get isShuffle => _audioService.isShuffle;
  LoopMode get loopMode => _audioService.loopMode;
  List<Song> get queue => _audioService.queue;

  Future<void> _init() async {
    _bindAudioListeners();
    await loadData();
  }

  void _bindAudioListeners() {
    _currentSongSub = _audioService.currentSongStream.listen((song) {
      _currentSong = song;
      notifyListeners();
    });

    _playerStateSub = _audioService.playerStateStream.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _positionSub = _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub = _audioService.durationStream.listen((dur) {
      _duration = dur ?? (_currentSong != null ? _currentSong!.duration : Duration.zero);
      notifyListeners();
    });

    _bufferedPositionSub = _audioService.bufferedPositionStream.listen((buf) {
      _bufferedPosition = buf;
      notifyListeners();
    });
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSongs = await _apiService.getSongs();
      _defaultPlaylists = await _apiService.getDefaultPlaylists();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading music data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _applyFilter();
  }

  void _applyFilter() {
    var result = List<Song>.from(_allSongs);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((song) {
        return song.album.toLowerCase().contains(_selectedCategory!.toLowerCase());
      }).toList();
    }

    // Apply search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((song) {
        return song.title.toLowerCase().contains(q) ||
            song.artist.toLowerCase().contains(q) ||
            song.album.toLowerCase().contains(q);
      }).toList();
    }

    _filteredSongs = result;
    notifyListeners();
  }

  Song? getSongById(String id) {
    try {
      return _allSongs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Song> getSongsForPlaylist(Playlist playlist) {
    return playlist.songIds
        .map((id) => getSongById(id))
        .whereType<Song>()
        .toList();
  }

  // Playback Control Actions
  Future<void> playSong(Song song, {List<Song>? queue}) async {
    await _audioService.playSong(song, queue: queue ?? _allSongs);
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> next() async {
    await _audioService.next();
  }

  Future<void> previous() async {
    await _audioService.previous();
  }

  void toggleShuffle() {
    _audioService.toggleShuffle();
    notifyListeners();
  }

  void toggleLoop() {
    _audioService.toggleLoopMode();
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedPositionSub?.cancel();
    _currentSongSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

