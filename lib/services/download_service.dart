import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../models/download_item.dart';
import '../models/download_options.dart';
import '../models/log_entry.dart';
import 'python_bridge.dart';
import 'storage_service.dart';
import 'settings_service.dart';

class DownloadService extends ChangeNotifier {
  final PythonBridge _pythonBridge = PythonBridge();
  final StorageService _storageService;
  final SettingsService _settingsService;

  // Download state
  bool _isDownloading = false;
  int _progress = 0;
  String _statusMessage = '';
  String _currentStatus = '';
  String _currentUrl = '';
  DownloadOptions _options = const DownloadOptions();
  StreamSubscription? _progressSubscription;

  // Logs
  final List<LogEntry> _logs = [];

  DownloadService({
    required StorageService storageService,
    required SettingsService settingsService,
  })  : _storageService = storageService,
        _settingsService = settingsService;

  // Getters
  bool get isDownloading => _isDownloading;
  int get progress => _progress;
  String get statusMessage => _statusMessage;
  String get currentStatus => _currentStatus;
  String get currentUrl => _currentUrl;
  DownloadOptions get options => _options;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void updateOptions(DownloadOptions options) {
    _options = options;
    notifyListeners();
  }

  /// Start downloading from a Spotify URL
  Future<void> startDownload(String url) async {
    if (_isDownloading) return;

    _isDownloading = true;
    _progress = 0;
    _statusMessage = 'Initializing...';
    _currentStatus = AppConstants.statusDownloading;
    _currentUrl = url;
    _logs.clear();
    notifyListeners();

    _addLog('Starting download: $url', 'info');

    try {
      // Get output directory
      final outputDir = await _getOutputDirectory();

      // Listen for progress events
      _progressSubscription = _pythonBridge.progressStream.listen(
        _handleProgressEvent,
        onError: (error) {
          _addLog('Stream error: $error', 'error');
          _finishDownload(false, 'Stream error: $error');
        },
      );

      // Start the download
      await _pythonBridge.startDownload(
        url: url,
        outputDir: outputDir,
        quality: _options.quality,
        skipExisting: _options.skipExisting,
        embedArt: _options.embedArt,
        normalize: _options.normalizeAudio,
      );
    } catch (e) {
      _addLog('Error: $e', 'error');
      _finishDownload(false, e.toString());
    }
  }

  /// Cancel the current download
  Future<void> cancelDownload() async {
    if (!_isDownloading) return;

    _addLog('Cancelling download...', 'warning');

    try {
      await _pythonBridge.cancelDownload();
      _finishDownload(false, 'Download cancelled');
    } catch (e) {
      _addLog('Cancel error: $e', 'error');
    }
  }

  /// Validate a Spotify URL
  Future<Map<String, dynamic>> validateUrl(String url) async {
    // First do a quick regex check
    if (AppConstants.spotifyAnyRegex.hasMatch(url)) {
      String type = 'track';
      if (AppConstants.spotifyPlaylistRegex.hasMatch(url)) {
        type = 'playlist';
      } else if (AppConstants.spotifyAlbumRegex.hasMatch(url)) {
        type = 'album';
      }
      return {'valid': true, 'type': type};
    }
    return {'valid': false, 'type': null};
  }

  void _handleProgressEvent(Map<String, dynamic> event) {
    final status = event['status'] as String? ?? '';
    final progress = event['progress'] as int? ?? 0;
    final message = event['message'] as String? ?? '';
    final type = event['type'] as String? ?? 'info';

    _addLog(message, type);

    if (status == 'completed') {
      _progress = 100;
      _statusMessage = message;
      _currentStatus = AppConstants.statusCompleted;
      _finishDownload(true, message);
      return;
    }

    if (status == 'error') {
      _finishDownload(false, message);
      return;
    }

    if (status == 'cancelled') {
      _finishDownload(false, message);
      return;
    }

    _progress = progress;
    _statusMessage = message;
    _currentStatus = status;
    notifyListeners();
  }

  void _finishDownload(bool success, String message) {
    _isDownloading = false;
    _statusMessage = message;
    _currentStatus = success ? AppConstants.statusCompleted : AppConstants.statusError;
    _progressSubscription?.cancel();
    _progressSubscription = null;

    if (success) {
      // Save to download history
      _saveToHistory();
    }

    notifyListeners();
  }

  Future<void> _saveToHistory() async {
    try {
      final item = DownloadItem(
        title: 'Downloaded Track',
        artist: 'Unknown',
        url: _currentUrl,
        filePath: await _getOutputDirectory(),
        status: AppConstants.statusCompleted,
        type: _options.mode,
        createdAt: DateTime.now(),
      );
      await _storageService.insertDownload(item);
    } catch (e) {
      debugPrint('Failed to save to history: $e');
    }
  }

  Future<String> _getOutputDirectory() async {
    final customDir = _settingsService.outputDirectory;
    if (customDir.isNotEmpty) return customDir;

    final dir = await getExternalStorageDirectory();
    return '${dir?.path ?? '/storage/emulated/0'}/SpotDL';
  }

  void _addLog(String message, String type) {
    if (message.isEmpty) return;
    _logs.add(LogEntry.fromType(type, message));
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}
