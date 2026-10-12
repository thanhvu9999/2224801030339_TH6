import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF131324),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tài Khoản Cá Nhân (*)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: auth.isLoggedIn
              ? _buildLoggedInView(context, auth, theme)
              : _buildGuestView(context, theme),
        ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthProvider auth, ThemeData theme) {
    final user = auth.currentUser!;
    final likedCount = auth.likedSongIds.length;
    final playlistCount = auth.userPlaylists.length;

    return Column(
      children: [
        // Avatar & Info
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.displayName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              if (user.email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stats Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      '$likedCount',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bài hát yêu thích',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.queue_music, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      '$playlistCount',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Playlist cá nhân',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Information Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin ứng dụng',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Divider(color: Colors.white10, height: 20),
              _buildInfoRow('Trạng thái:', 'Đã đăng nhập tài khoản cá nhân'),
              const SizedBox(height: 8),
              _buildInfoRow('Audio Player:', 'just_audio (Online Streaming)'),
              const SizedBox(height: 8),
              _buildInfoRow('Dữ liệu yêu thích & playlist:', 'Lưu trữ theo từng tài khoản'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Logout Button
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text('Đăng Xuất Tài Khoản', style: TextStyle(color: Colors.redAccent)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF232338),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await auth.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đăng xuất')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildGuestView(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Icon(Icons.account_circle, size: 80, color: Colors.grey.shade600),
        const SizedBox(height: 16),
        const Text(
          'Chưa Đăng Nhập',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để thích bài hát và lưu playlist nhạc cá nhân theo yêu cầu bài tập (*)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập / Đăng ký ngay'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

