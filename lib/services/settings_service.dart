import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class SettingsService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('SettingsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // --- General ---

  String get defaultQuality =>
      _p.getString(AppConstants.keyDefaultQuality) ?? AppConstants.defaultQuality;
  set defaultQuality(String value) =>
      _p.setString(AppConstants.keyDefaultQuality, value);

  String get defaultMode =>
      _p.getString(AppConstants.keyDefaultMode) ?? AppConstants.modeSingle;
  set defaultMode(String value) =>
      _p.setString(AppConstants.keyDefaultMode, value);

  bool get autoClearLogs =>
      _p.getBool(AppConstants.keyAutoClearLogs) ?? false;
  set autoClearLogs(bool value) =>
      _p.setBool(AppConstants.keyAutoClearLogs, value);

  bool get autoOpenFolder =>
      _p.getBool(AppConstants.keyAutoOpenFolder) ?? false;
  set autoOpenFolder(bool value) =>
      _p.setBool(AppConstants.keyAutoOpenFolder, value);

  // --- Download Settings ---

  int get maxConcurrent =>
      _p.getInt(AppConstants.keyMaxConcurrent) ?? 1;
  set maxConcurrent(int value) =>
      _p.setInt(AppConstants.keyMaxConcurrent, value);

  bool get retryOnFailure =>
      _p.getBool(AppConstants.keyRetryOnFailure) ?? true;
  set retryOnFailure(bool value) =>
      _p.setBool(AppConstants.keyRetryOnFailure, value);

  bool get backgroundDownload =>
      _p.getBool(AppConstants.keyBackgroundDownload) ?? false;
  set backgroundDownload(bool value) =>
      _p.setBool(AppConstants.keyBackgroundDownload, value);

  // --- Storage ---

  String get outputDirectory =>
      _p.getString(AppConstants.keyOutputDirectory) ?? '';
  set outputDirectory(String value) =>
      _p.setString(AppConstants.keyOutputDirectory, value);

  // --- Developer ---

  bool get showDebugLogs =>
      _p.getBool(AppConstants.keyShowDebugLogs) ?? false;
  set showDebugLogs(bool value) =>
      _p.setBool(AppConstants.keyShowDebugLogs, value);

  // --- Download Options ---

  bool get skipExisting =>
      _p.getBool(AppConstants.keySkipExisting) ?? true;
  set skipExisting(bool value) =>
      _p.setBool(AppConstants.keySkipExisting, value);

  bool get embedArt =>
      _p.getBool(AppConstants.keyEmbedArt) ?? true;
  set embedArt(bool value) =>
      _p.setBool(AppConstants.keyEmbedArt, value);

  bool get normalizeAudio =>
      _p.getBool(AppConstants.keyNormalizeAudio) ?? false;
  set normalizeAudio(bool value) =>
      _p.setBool(AppConstants.keyNormalizeAudio, value);

  // --- Environment ---

  bool get envSetupDone =>
      _p.getBool(AppConstants.keyEnvSetupDone) ?? false;
  set envSetupDone(bool value) =>
      _p.setBool(AppConstants.keyEnvSetupDone, value);

  // --- Reset ---

  Future<void> resetAll() async {
    await _p.clear();
  }
}
