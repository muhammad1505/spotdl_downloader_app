class DownloadItem {
  final int? id;
  final String title;
  final String artist;
  final String url;
  final String? albumArt;
  final String? duration;
  final String? fileSize;
  final String filePath;
  final String status;
  final String type; // track, playlist
  final DateTime createdAt;

  DownloadItem({
    this.id,
    required this.title,
    required this.artist,
    required this.url,
    this.albumArt,
    this.duration,
    this.fileSize,
    required this.filePath,
    required this.status,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'albumArt': albumArt,
      'duration': duration,
      'fileSize': fileSize,
      'filePath': filePath,
      'status': status,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String,
      url: map['url'] as String,
      albumArt: map['albumArt'] as String?,
      duration: map['duration'] as String?,
      fileSize: map['fileSize'] as String?,
      filePath: map['filePath'] as String,
      status: map['status'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  DownloadItem copyWith({
    int? id,
    String? title,
    String? artist,
    String? url,
    String? albumArt,
    String? duration,
    String? fileSize,
    String? filePath,
    String? status,
    String? type,
    DateTime? createdAt,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
