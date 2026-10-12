class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> songIds;
  final bool isCustom;
  final String? userId;
  final String? coverUrl;

  Playlist({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? songIds,
    this.isCustom = false,
    this.userId,
    this.coverUrl,
  }) : songIds = songIds ?? [];

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      songIds: (json['songIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isCustom: json['isCustom'] as bool? ?? false,
      userId: json['userId'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songIds': songIds,
      'isCustom': isCustom,
      'userId': userId,
      'coverUrl': coverUrl,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? songIds,
    bool? isCustom,
    String? userId,
    String? coverUrl,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songIds: songIds ?? List.from(this.songIds),
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

