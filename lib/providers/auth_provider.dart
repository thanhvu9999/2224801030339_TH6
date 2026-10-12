import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = true;
  Set<String> _likedSongIds = {};
  List<Playlist> _userPlaylists = [];

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  Set<String> get likedSongIds => _likedSongIds;
  List<Playlist> get userPlaylists => _userPlaylists;

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await StorageService.getCurrentUser();
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData(String userId) async {
    _likedSongIds = await StorageService.getLikedSongIds(userId);
    _userPlaylists = await StorageService.getUserPlaylists(userId);
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await StorageService.authenticateUser(username, password);
    if (user != null) {
      _currentUser = user;
      await _loadUserData(user.id);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String username,
    required String password,
    required String displayName,
    required String email,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await StorageService.registerUser(
      username: username,
      password: password,
      displayName: displayName,
      email: email,
    );

    if (success) {
      // Auto login upon registration
      final user = await StorageService.authenticateUser(username, password);
      if (user != null) {
        _currentUser = user;
        await _loadUserData(user.id);
      }
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.clearCurrentUser();
    _currentUser = null;
    _likedSongIds.clear();
    _userPlaylists.clear();

    _isLoading = false;
    notifyListeners();
  }

  bool isLiked(String songId) {
    return _likedSongIds.contains(songId);
  }

  Future<bool> toggleLike(String songId) async {
    if (!isLoggedIn) return false;

    if (_likedSongIds.contains(songId)) {
      _likedSongIds.remove(songId);
    } else {
      _likedSongIds.add(songId);
    }
    notifyListeners();

    await StorageService.saveLikedSongIds(_currentUser!.id, _likedSongIds);
    return true;
  }

  Future<Playlist?> createPlaylist(String name, {String description = ''}) async {
    if (!isLoggedIn) return null;

    final newPlaylist = Playlist(
      id: 'pl_user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Playlist của tôi' : name.trim(),
      description: description.trim(),
      songIds: [],
      isCustom: true,
      userId: _currentUser!.id,
    );

    _userPlaylists.insert(0, newPlaylist);
    notifyListeners();

    await StorageService.saveUserPlaylists(_currentUser!.id, _userPlaylists);
    return newPlaylist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    if (!isLoggedIn) return;

    _userPlaylists.removeWhere((p) => p.id == playlistId);
    notifyListeners();

    await StorageService.saveUserPlaylists(_currentUser!.id, _userPlaylists);
  }

  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    if (!isLoggedIn) return false;

    final index = _userPlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return false;

    final playlist = _userPlaylists[index];
    if (!playlist.songIds.contains(songId)) {
      playlist.songIds.add(songId);
      notifyListeners();
      await StorageService.saveUserPlaylists(_currentUser!.id, _userPlaylists);
      return true;
    }
    return false;
  }

  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    if (!isLoggedIn) return false;

    final index = _userPlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return false;

    final playlist = _userPlaylists[index];
    if (playlist.songIds.contains(songId)) {
      playlist.songIds.remove(songId);
      notifyListeners();
      await StorageService.saveUserPlaylists(_currentUser!.id, _userPlaylists);
      return true;
    }
    return false;
  }
}

