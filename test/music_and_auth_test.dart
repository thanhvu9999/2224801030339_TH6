import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/providers/auth_provider.dart';
import 'package:music_app/providers/music_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider Tests', () {
    test('Default demo login works', () async {
      final auth = AuthProvider();
      await auth.init();

      expect(auth.isLoggedIn, false);

      final loggedIn = await auth.login('demo', '123456');
      expect(loggedIn, true);
      expect(auth.isLoggedIn, true);
      expect(auth.currentUser?.username, 'demo');
    });

    test('Register and like songs persistence', () async {
      final auth = AuthProvider();
      await auth.init();

      final registered = await auth.register(
        username: 'student222',
        password: 'password123',
        displayName: 'Sinh Vien',
        email: 'student@example.com',
      );
      expect(registered, true);
      expect(auth.isLoggedIn, true);

      // Like a song
      expect(auth.isLiked('s_01'), false);
      await auth.toggleLike('s_01');
      expect(auth.isLiked('s_01'), true);

      // Create personal playlist
      final playlist = await auth.createPlaylist('Playlist Hoc Tap');
      expect(playlist, isNotNull);
      expect(auth.userPlaylists.length, 1);
      expect(auth.userPlaylists.first.name, 'Playlist Hoc Tap');

      // Add song to playlist
      final added = await auth.addSongToPlaylist(playlist!.id, 's_01');
      expect(added, true);
      expect(auth.userPlaylists.first.songIds.contains('s_01'), true);

      // Remove song from playlist
      final removed = await auth.removeSongFromPlaylist(playlist.id, 's_01');
      expect(removed, true);
      expect(auth.userPlaylists.first.songIds.contains('s_01'), false);

      // Unlike song
      await auth.toggleLike('s_01');
      expect(auth.isLiked('s_01'), false);

      // Logout
      await auth.logout();
      expect(auth.isLoggedIn, false);
      expect(auth.currentUser, isNull);
    });
  });

  group('MusicProvider Tests', () {
    test('Load songs and search filter', () async {
      final music = MusicProvider();
      await music.loadData();

      expect(music.allSongs.isNotEmpty, true);
      final initialCount = music.songs.length;

      // Search for specific song
      music.search('Chilling');
      expect(music.songs.length, 1);
      expect(music.songs.first.title.contains('Chilling'), true);

      // Clear search
      music.search('');
      expect(music.songs.length, initialCount);

      // Search for artist
      music.search('SoundHelix');
      expect(music.songs.isNotEmpty, true);
      for (final s in music.songs) {
        expect(s.artist.toLowerCase().contains('soundhelix') || s.title.toLowerCase().contains('soundhelix'), true);
      }
    });

    test('Default playlists loaded and resolved', () async {
      final music = MusicProvider();
      await music.loadData();

      expect(music.defaultPlaylists.isNotEmpty, true);
      final firstPlaylist = music.defaultPlaylists.first;
      final songs = music.getSongsForPlaylist(firstPlaylist);
      expect(songs.length, firstPlaylist.songIds.length);
    });
  });
}

