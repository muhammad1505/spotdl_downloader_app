class DownloadOptions {
  final String quality;
  final String mode; // single, playlist
  final bool skipExisting;
  final bool embedArt;
  final bool normalizeAudio;

  const DownloadOptions({
    this.quality = '320',
    this.mode = 'single',
    this.skipExisting = true,
    this.embedArt = true,
    this.normalizeAudio = false,
  });

  DownloadOptions copyWith({
    String? quality,
    String? mode,
    bool? skipExisting,
    bool? embedArt,
    bool? normalizeAudio,
  }) {
    return DownloadOptions(
      quality: quality ?? this.quality,
      mode: mode ?? this.mode,
      skipExisting: skipExisting ?? this.skipExisting,
      embedArt: embedArt ?? this.embedArt,
      normalizeAudio: normalizeAudio ?? this.normalizeAudio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quality': quality,
      'mode': mode,
      'skipExisting': skipExisting,
      'embedArt': embedArt,
      'normalizeAudio': normalizeAudio,
    };
  }
}
