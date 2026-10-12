import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import '../widgets/add_to_playlist_dialog.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double? _dragPositionSeconds;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showQueueBottomSheet(BuildContext context, MusicProvider music) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final queue = music.queue;
        final currentSong = music.currentSong;

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh Sách Chờ Phát (Queue)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${queue.length} bài',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isPlaying = currentSong?.id == song.id;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song.artworkUrl,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.music_note, color: Colors.white),
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? Theme.of(context).colorScheme.primary : Colors.white,
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      trailing: isPlaying
                          ? Icon(Icons.equalizer, color: Theme.of(context).colorScheme.primary)
                          : Text(song.formattedDuration, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      onTap: () {
                        music.playSong(song, queue: queue);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final auth = context.watch<AuthProvider>();
    final song = music.currentSong;

    if (song == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF12121E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Chưa có bài hát nào được chọn', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final isLiked = auth.isLiked(song.id);
    final theme = Theme.of(context);

    final currentSeconds = _dragPositionSeconds ?? music.position.inSeconds.toDouble();
    final totalSeconds = music.duration.inSeconds > 0
        ? music.duration.inSeconds.toDouble()
        : (song.durationSeconds > 0 ? song.durationSeconds.toDouble() : 1.0);
    final clampedCurrent = currentSeconds.clamp(0.0, totalSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF131324),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'ĐANG PHÁT ONLINE',
              style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: Colors.white54, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              song.album,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white70),
            onPressed: () => _showQueueBottomSheet(context, music),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Large Album Artwork
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 320, maxWidth: 320),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        song.artworkUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey.shade900,
                          child: const Icon(Icons.music_note, size: 80, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title, Artist and Action Buttons (Like / Add to playlist)
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add to playlist button
                      IconButton(
                        icon: const Icon(Icons.playlist_add, size: 28, color: Colors.white70),
                        tooltip: 'Thêm vào playlist',
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
                      // Like button (*)
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 28,
                          color: isLiked ? Colors.redAccent : Colors.white70,
                        ),
                        tooltip: isLiked ? 'Bỏ thích' : 'Yêu thích',
                        onPressed: () async {
                          if (!auth.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng đăng nhập tài khoản để thích bài hát!'),
                              ),
                            );
                            return;
                          }
                          await auth.toggleLike(song.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  auth.isLiked(song.id)
                                      ? 'Đã thêm "${song.title}" vào mục Yêu thích'
                                      : 'Đã xóa "${song.title}" khỏi mục Yêu thích',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Progress Bar (Slider + Duration texts)
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: clampedCurrent,
                      min: 0.0,
                      max: totalSeconds,
                      onChanged: (val) {
                        setState(() {
                          _dragPositionSeconds = val;
                        });
                      },
                      onChangeEnd: (val) {
                        music.seek(Duration(seconds: val.round()));
                        setState(() {
                          _dragPositionSeconds = null;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(Duration(seconds: clampedCurrent.toInt())),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                        Text(
                          _formatDuration(Duration(seconds: totalSeconds.toInt())),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Media Player Controls: Shuffle, Previous, Play/Pause, Next, Loop
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: music.isShuffle ? theme.colorScheme.primary : Colors.white38,
                    ),
                    onPressed: () => music.toggleShuffle(),
                  ),

                  // Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                    onPressed: () => music.previous(),
                  ),

                  // Play / Pause / Buffering button
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      onTap: () => music.togglePlayPause(),
                      child: Center(
                        child: music.isBuffering
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                music.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 38,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),

                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                    onPressed: () => music.next(),
                  ),

                  // Loop mode
                  IconButton(
                    icon: Icon(
                      music.loopMode == LoopMode.one
                          ? Icons.repeat_one
                          : (music.loopMode == LoopMode.all ? Icons.repeat : Icons.repeat),
                      color: music.loopMode != LoopMode.off ? theme.colorScheme.primary : Colors.white38,
                    ),
                    onPressed: () => music.toggleLoop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
