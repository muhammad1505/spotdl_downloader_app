import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:spotify_downloader/main.dart';
import 'package:spotify_downloader/managers/analytics_manager.dart';
import 'package:spotify_downloader/managers/queue_manager.dart';
import 'package:spotify_downloader/models/download_task.dart';
import 'package:spotify_downloader/services/download_service.dart';
import 'package:spotify_downloader/services/settings_service.dart';
import 'package:spotify_downloader/models/download_item.dart';
import 'package:spotify_downloader/services/storage_service.dart';
import 'package:spotify_downloader/services/environment_service.dart';
import 'package:spotify_downloader/platform_bridge/command_executor.dart';

class FakeStorageService extends StorageService {
  @override
  Future<List<DownloadItem>> getAllDownloads() async => [];

  @override
  Future<List<DownloadItem>> getDownloadsSorted(String sortBy) async => [];

  @override
  Future<List<DownloadItem>> getDownloadsByType(String type) async => [];

  @override
  Future<List<DownloadItem>> searchDownloads(String query) async => [];

  @override
  Future<int> insertDownload(DownloadItem item) async => 0;

  @override
  Future<int> deleteDownload(int id) async => 0;
}

class FakeQueueManager extends ChangeNotifier implements QueueManager {
  final List<DownloadTask> _tasks = [];
  final List<String> _logs = [];

  @override
  List<DownloadTask> get tasks => List.unmodifiable(_tasks);

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  Future<String> enqueue(String url,
      {String quality = '320',
      bool skipExisting = true,
      bool embedArt = true,
      bool normalize = false}) async {
    return 'test-id';
  }

  @override
  void pauseTask(String id) {}

  @override
  void resumeTask(String id) {}

  @override
  void cancelTask(String id) {}

  @override
  void cancelAll() {}

  @override
  void appendExternalLog(String text) {}
}

class FakeEnvironmentService extends EnvironmentService {
  FakeEnvironmentService() : super(executor: _NoopExecutor());
}

class _NoopExecutor implements CommandExecutor {
  @override
  Future<CommandResult> execute(String command, {String? workingDir}) async {
    return const CommandResult(exitCode: 0, stdout: '', stderr: '');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bottom navigation switches between all screens', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({'env_setup_done': true});
    final settingsService = SettingsService();
    await settingsService.init();

    final fakeStorage = FakeStorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DownloadService>(
            create: (_) => DownloadService(),
          ),
          ChangeNotifierProvider<QueueManager>(
            create: (_) => FakeQueueManager(),
          ),
          Provider<EnvironmentService>(
            create: (_) => FakeEnvironmentService(),
          ),
          ChangeNotifierProvider<AnalyticsManager>(
            create: (_) => AnalyticsManager(storageService: fakeStorage),
          ),
        ],
        child: MaterialApp(
          home: MainShell(
            settingsService: settingsService,
            libraryStorageService: fakeStorage,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Spotify Downloader'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.library_music_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Library'), findsWidgets);

    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Analytics'), findsWidgets);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('POWERED BY'), findsOneWidget);
  });
}
