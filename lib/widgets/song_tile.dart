import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import 'add_to_playlist_dialog.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song>? queue;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.queue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isCurrent = musicProvider.currentSong?.id == song.id;
    final isLiked = authProvider.isLiked(song.id);

    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ?? () => musicProvider.playSong(song, queue: queue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent
              ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    song.artworkUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 52,
                      height: 52,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.music_note, color: Colors.white70),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 52,
                        height: 52,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                  if (isCurrent)
                    Container(
                      width: 52,
                      height: 52,
                      color: Colors.black45,
                      child: Icon(
                        musicProvider.isPlaying ? Icons.equalizer : Icons.pause,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Song Info (Title & Artist)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? theme.colorScheme.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        song.formattedDuration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Like Button
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.redAccent : Colors.grey.shade400,
                size: 22,
              ),
              onPressed: () async {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredSnackbar(context);
                  return;
                }
                await authProvider.toggleLike(song.id);
                if (context.mounted) {
                  final nowLiked = authProvider.isLiked(song.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nowLiked
                            ? 'Đã thêm "${song.title}" vào bài hát yêu thích'
                            : 'Đã xóa "${song.title}" khỏi bài hát yêu thích',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),

            // More Options (Add to playlist)
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF1E1E2C),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => AddToPlaylistDialog(song: song),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vui lòng đăng nhập để lưu bài hát yêu thích!'),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () {
            // Can navigate to login
          },
        ),
      ),
    );
  }
}
