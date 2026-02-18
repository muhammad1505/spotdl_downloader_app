import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/queue_engine.dart';
import 'core/download_backend.dart';
import 'platform_bridge/command_executor.dart';
import 'services/environment_service.dart';
import 'services/download_service.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'services/audio_service.dart';
import 'managers/queue_manager.dart';
import 'managers/analytics_manager.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.spotifyDarkGrey,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize services
  final settingsService = SettingsService();
  await settingsService.init();

  final storageService = StorageService();
  final audioService = AudioService();
  await audioService.init();

  final executor = resolveExecutor();
  final envService = EnvironmentService(executor: executor);
  final backend = TermuxDownloadBackend(
    executor: executor,
    resolveDistro: envService.resolveDistro,
  );
  final queueEngine = QueueEngine(backend: backend);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DownloadService(),
        ),
        ChangeNotifierProvider(
          create: (_) => QueueManager(
            queueEngine: queueEngine,
            settingsService: settingsService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsManager(storageService: storageService),
        ),
        Provider<AudioService>.value(value: audioService),
        Provider<EnvironmentService>.value(value: envService),
      ],
      child: SpotifyDownloaderApp(settingsService: settingsService),
    ),
  );
}

class SpotifyDownloaderApp extends StatelessWidget {
  final SettingsService settingsService;

  const SpotifyDownloaderApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Downloader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: MainShell(settingsService: settingsService),
    );
  }
}

class MainShell extends StatefulWidget {
  final SettingsService settingsService;
  final StorageService? libraryStorageService;

  const MainShell({
    super.key,
    required this.settingsService,
    this.libraryStorageService,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      LibraryScreen(storageService: widget.libraryStorageService),
      const AnalyticsScreen(),
      SettingsScreen(settingsService: widget.settingsService),
      const AboutScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runEnvironmentChecks();
    });
  }

  Future<void> _runEnvironmentChecks() async {
    final env = context.read<EnvironmentService>();
    final logger = context.read<QueueManager>();
    final settings = widget.settingsService;

    if (!settings.envSetupDone) {
      await _showFirstRunSetup(env, logger, settings);
    } else {
      _autoCheckEnvironment(env, logger);
    }
  }

  Future<void> _showFirstRunSetup(
    EnvironmentService env,
    QueueManager logger,
    SettingsService settings,
  ) async {
    final action = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Environment Setup'),
          content: const Text(
            'This app requires Termux + Termux:Tasker + proot-distro + spotdl. '
            'Run one-click setup now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Run Setup'),
            ),
          ],
        );
      },
    );

    if (action == true) {
      logger.appendExternalLog('Setup: starting environment configuration');
      final res = await env.oneClickSetup(
        onLog: (msg) => logger.appendExternalLog('Setup: $msg'),
      );
      if (res.isSuccess) {
        settings.envSetupDone = true;
      }
      if (mounted) {
        final message = res.isSuccess
            ? (res.stdout.isNotEmpty ? res.stdout : 'Setup complete')
            : 'Setup failed: ${res.stderr}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Future<void> _autoCheckEnvironment(
    EnvironmentService env,
    QueueManager logger,
  ) async {
    logger.appendExternalLog('Env check: starting');
    final termux = await env.isTermuxInstalled();
    final tasker = await env.isTermuxTaskerInstalled();
    final proot = await env.isProotDistroAvailable();
    final distro = await env.resolveDistro();
    final spotdl = await env.isSpotdlAvailable();
    logger.appendExternalLog(
      'Env check: Termux=${termux ? "OK" : "MISSING"} '
      'Tasker=${tasker ? "OK" : "MISSING"} '
      'proot=${proot ? "OK" : "MISSING"} '
      'distro=$distro '
      'spotdl=${spotdl ? "OK" : "MISSING"}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: IndexedStack(
            key: ValueKey<int>(_currentIndex),
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.spotifyLightGrey.withAlpha(40),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.download_rounded),
              label: 'Download',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_rounded),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}
