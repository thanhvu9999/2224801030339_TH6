import '../models/song.dart';
import '../models/playlist.dart';

class MusicApiService {
  static final List<Song> _mockSongs = [
    const Song(
      id: 's_01',
      title: 'Chilling in the Sun',
      artist: 'SoundHelix Project',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80',
      durationSeconds: 372,
      album: 'Acoustic Sunset',
    ),
    const Song(
      id: 's_02',
      title: 'Night Melody',
      artist: 'SoundHelix Studio',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80',
      durationSeconds: 425,
      album: 'Midnight Echoes',
    ),
    const Song(
      id: 's_03',
      title: 'The Neverwritten RPG',
      artist: 'Kangaroo MusiQue',
      audioUrl: 'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80',
      durationSeconds: 216,
      album: 'Arcade Adventures',
    ),
    const Song(
      id: 's_04',
      title: 'Microtonal Groove',
      artist: 'Sevish',
      audioUrl: 'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&q=80',
      durationSeconds: 180,
      album: 'Harmony Waves',
    ),
    const Song(
      id: 's_05',
      title: 'Atmospheric Soundscape',
      artist: 'Sounddogs Studio',
      audioUrl: 'https://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/soundtrack.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=500&q=80',
      durationSeconds: 110,
      album: 'Cinematic Moods',
    ),
    const Song(
      id: 's_06',
      title: 'Sunny Acoustic Vibes',
      artist: 'Rafael Reis',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&q=80',
      durationSeconds: 184,
      album: 'Golden Days',
    ),
    const Song(
      id: 's_07',
      title: 'Urban Rhythm Beats',
      artist: 'Audio Studio Lab',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample2.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500&q=80',
      durationSeconds: 135,
      album: 'Street Beats Vol. 1',
    ),
    const Song(
      id: 's_08',
      title: 'Morning Breeze',
      artist: 'SoundHelix Project',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=500&q=80',
      durationSeconds: 340,
      album: 'Dawn Horizons',
    ),
    const Song(
      id: 's_09',
      title: 'Sunset Symphony',
      artist: 'SoundHelix Studio',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1520523839898-507127022a16?w=500&q=80',
      durationSeconds: 502,
      album: 'Sunset Symphony',
    ),
    const Song(
      id: 's_10',
      title: 'Electro Horizon',
      artist: 'SoundHelix Project',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      artworkUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500&q=80',
      durationSeconds: 450,
      album: 'Electronic Waves',
    ),
  ];

  static final List<Playlist> _defaultPlaylists = [
    Playlist(
      id: 'pl_trending',
      name: 'Top Thịnh Hành 2024',
      description: 'Những bản nhạc online được nghe nhiều nhất hiện nay',
      songIds: ['s_01', 's_03', 's_06', 's_07'],
      isCustom: false,
      coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80',
    ),
    Playlist(
      id: 'pl_chill',
      name: 'Acoustic & Chill Lofi',
      description: 'Giai điệu nhẹ nhàng giúp thư giãn và tập trung làm việc',
      songIds: ['s_01', 's_02', 's_06', 's_08', 's_09'],
      isCustom: false,
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80',
    ),
    Playlist(
      id: 'pl_electronic',
      name: 'Electronic & Gaming Hits',
      description: 'Âm nhạc sôi động bùng nổ năng lượng tích cực',
      songIds: ['s_03', 's_04', 's_05', 's_07', 's_10'],
      isCustom: false,
      coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80',
    ),
  ];

  Future<List<Song>> getSongs() async {
    // Simulating light async network latency
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockSongs);
  }

  Future<List<Playlist>> getDefaultPlaylists() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_defaultPlaylists);
  }
}

