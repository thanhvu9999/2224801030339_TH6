import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/user.dart';

class StorageService {
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsersList = 'registered_users';
  static const String _prefixLikedSongs = 'liked_songs_';
  static const String _prefixUserPlaylists = 'user_playlists_';

  // Current User Session
  static Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
  }

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCurrentUser);
    if (data == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }

  // User Accounts
  static Future<bool> registerUser({
    required String username,
    required String password,
    required String displayName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_keyUsersList);
    Map<String, dynamic> usersMap = {};
    if (usersRaw != null) {
      try {
        usersMap = jsonDecode(usersRaw) as Map<String, dynamic>;
      } catch (_) {}
    }

    final normalizedUser = username.trim().toLowerCase();
    if (usersMap.containsKey(normalizedUser)) {
      return false; // User already exists
    }

    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim(),
      displayName: displayName.trim().isEmpty ? username.trim() : displayName.trim(),
      email: email.trim(),
    );

    usersMap[normalizedUser] = {
      'user': user.toJson(),
      'password': password,
    };

    await prefs.setString(_keyUsersList, jsonEncode(usersMap));
    return true;
  }

  static Future<AppUser?> authenticateUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_keyUsersList);
    if (usersRaw == null) {
      // Default initial mock accounts if none registered yet
      if (username.trim().toLowerCase() == 'demo' && password == '123456') {
        const defaultUser = AppUser(
          id: 'u_demo_default',
          username: 'demo',
          displayName: 'Demo User',
          email: 'demo@music.vn',
        );
        await saveCurrentUser(defaultUser);
        return defaultUser;
      }
      return null;
    }

    try {
      final usersMap = jsonDecode(usersRaw) as Map<String, dynamic>;
      final normalizedUser = username.trim().toLowerCase();
      if (!usersMap.containsKey(normalizedUser)) {
        // Also support demo account
        if (normalizedUser == 'demo' && password == '123456') {
          const defaultUser = AppUser(
            id: 'u_demo_default',
            username: 'demo',
            displayName: 'Demo User',
            email: 'demo@music.vn',
          );
          await saveCurrentUser(defaultUser);
          return defaultUser;
        }
        return null;
      }

      final record = usersMap[normalizedUser] as Map<String, dynamic>;
      if (record['password'] == password) {
        final user = AppUser.fromJson(record['user'] as Map<String, dynamic>);
        await saveCurrentUser(user);
        return user;
      }
    } catch (_) {}

    return null;
  }

  // Liked Songs for User
  static Future<Set<String>> getLikedSongIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('$_prefixLikedSongs$userId') ?? [];
    return list.toSet();
  }

  static Future<void> saveLikedSongIds(String userId, Set<String> songIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_prefixLikedSongs$userId', songIds.toList());
  }

  // User Custom Playlists
  static Future<List<Playlist>> getUserPlaylists(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_prefixUserPlaylists$userId');
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data) as List<dynamic>;
      return list.map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUserPlaylists(String userId, List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = playlists.map((p) => p.toJson()).toList();
    await prefs.setString('$_prefixUserPlaylists$userId', jsonEncode(listJson));
  }
}

