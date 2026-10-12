import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/main.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/models/playlist.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MusicApp launches and smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MusicApp());
    await tester.pumpAndSettle();

    // Verify main screen header
    expect(find.text('ỨNG DỤNG NGHE NHẠC ONLINE'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Playlist'), findsOneWidget);
    expect(find.text('Yêu thích'), findsOneWidget);
  });

  test('Song model serialization and formattedDuration test', () {
    const song = Song(
      id: 'test_1',
      title: 'Test Song',
      artist: 'Test Artist',
      audioUrl: 'https://example.com/audio.mp3',
      artworkUrl: 'https://example.com/art.jpg',
      durationSeconds: 195,
      album: 'Test Album',
    );

    expect(song.formattedDuration, '03:15');
    final json = song.toJson();
    final fromJson = Song.fromJson(json);
    expect(fromJson.id, 'test_1');
    expect(fromJson.title, 'Test Song');
    expect(fromJson.durationSeconds, 195);
  });

  test('Playlist model serialization test', () {
    final playlist = Playlist(
      id: 'pl_1',
      name: 'My Playlist',
      description: 'Desc',
      songIds: ['s1', 's2'],
      isCustom: true,
    );

    expect(playlist.songIds.length, 2);
    final json = playlist.toJson();
    final fromJson = Playlist.fromJson(json);
    expect(fromJson.id, 'pl_1');
    expect(fromJson.songIds, ['s1', 's2']);
  });
}
