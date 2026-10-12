import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import 'login_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF131324),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Bài Hát Yêu Thích (*)'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Yêu cầu Đăng nhập (*)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đăng nhập tài khoản để xem và quản lý danh sách bài hát yêu thích của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Đăng nhập / Đăng ký'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final likedIds = auth.likedSongIds;
    final likedSongs = music.allSongs.where((s) => likedIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF131324),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bài Hát Yêu Thích',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (likedSongs.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Phát tất cả', style: TextStyle(color: Colors.white)),
              onPressed: () {
                music.playSong(likedSongs.first, queue: likedSongs);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: likedSongs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border, size: 60, color: Colors.white30),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có bài hát yêu thích',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn biểu tượng trái tim ❤️ ở bất kỳ bài hát nào để lưu vào đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: likedSongs.length,
                itemBuilder: (context, index) {
                  final song = likedSongs[index];
                  return SongTile(
                    song: song,
                    queue: likedSongs,
                  );
                },
              ),
      ),
    );
  }
}
