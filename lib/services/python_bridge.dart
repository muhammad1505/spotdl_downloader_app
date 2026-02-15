import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class PythonBridge {
  static const MethodChannel _methodChannel =
      MethodChannel(AppConstants.methodChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.eventChannel);

  /// Start a download with given parameters
  Future<bool> startDownload({
    required String url,
    required String outputDir,
    String quality = '320',
    bool skipExisting = true,
    bool embedArt = true,
    bool normalize = false,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod('startDownload', {
        'url': url,
        'outputDir': outputDir,
        'quality': quality,
        'skipExisting': skipExisting,
        'embedArt': embedArt,
        'normalize': normalize,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to start download: ${e.message}');
    }
  }

  /// Cancel the current download
  Future<bool> cancelDownload() async {
    try {
      final result = await _methodChannel.invokeMethod('cancelDownload');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to cancel download: ${e.message}');
    }
  }

  /// Validate a Spotify URL
  Future<Map<String, dynamic>> validateUrl(String url) async {
    try {
      final result = await _methodChannel.invokeMethod('validateUrl', {
        'url': url,
      });
      return json.decode(result as String) as Map<String, dynamic>;
    } on PlatformException catch (e) {
      return {
        'valid': false,
        'type': null,
        'message': e.message,
      };
    }
  }

  /// Get spotdl version
  Future<String> getVersion() async {
    try {
      final result = await _methodChannel.invokeMethod('getVersion');
      final data = json.decode(result as String) as Map<String, dynamic>;
      return data['version'] as String? ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Stream of progress events from Python
  Stream<Map<String, dynamic>> get progressStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      try {
        return json.decode(event as String) as Map<String, dynamic>;
      } catch (e) {
        return {
          'status': 'error',
          'progress': 0,
          'message': event.toString(),
          'type': 'error',
        };
      }
    });
  }
}
