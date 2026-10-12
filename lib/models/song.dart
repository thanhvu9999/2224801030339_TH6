class Song {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String artworkUrl;
  final int durationSeconds;
  final String album;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.artworkUrl,
    this.durationSeconds = 0,
    this.album = 'Single',
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      audioUrl: json['audioUrl'] as String,
      artworkUrl: json['artworkUrl'] as String,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      album: json['album'] as String? ?? 'Single',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'artworkUrl': artworkUrl,
      'durationSeconds': durationSeconds,
      'album': album,
    };
  }

  Duration get duration => Duration(seconds: durationSeconds);

  String get formattedDuration {
    if (durationSeconds <= 0) return '--:--';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

