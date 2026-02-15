# 🎵 SpotDL Downloader

An Android app to download Spotify tracks, playlists, and albums for offline listening. Built with **Flutter**, **Kotlin**, and **Python (Chaquopy + spotdl)**.

## ✨ Features

- 📥 Download tracks, playlists, and albums from Spotify
- 🎛️ Quality selection (128/192/320 kbps)
- 📂 Download history with search, filter & sort
- 🖥️ Real-time terminal log viewer
- 🔔 Foreground service with progress notifications
- 🌙 Spotify-themed dark mode UI
- ⚙️ Configurable settings (output dir, concurrent downloads, etc.)

## 🏗️ Architecture

```
Flutter UI ─► PythonBridge ─► MethodChannel ─► Kotlin ─► Chaquopy ─► spotdl/yt-dlp
```

| Layer | Tech |
|-------|------|
| UI | Flutter + Provider |
| Bridge | Kotlin + MethodChannel/EventChannel |
| Engine | Python 3.12 + spotdl + yt-dlp + FFmpeg |
| Storage | sqflite + SharedPreferences |

## 📁 Project Structure

```
lib/
├── core/            # Theme, constants
├── models/          # DownloadItem, DownloadOptions, LogEntry
├── screens/         # Home, Library, Settings, About
├── services/        # PythonBridge, DownloadService, StorageService, SettingsService
├── widgets/         # UrlInput, ProgressCard, TerminalLog, etc.
└── main.dart        # App entry point

android/
├── app/src/main/
│   ├── kotlin/      # MainActivity, DownloadForegroundService
│   └── python/      # spotdl_service.py
```

## 🚀 Build

```bash
# Debug
flutter build apk --debug

# Release (split per ABI)
flutter build apk --release --split-per-abi

# Universal release
flutter build apk --release
```

## 📋 Requirements

- Flutter 3.4+
- Android SDK 24+ (Android 7.0)
- Java 17

## 🔄 CI/CD

Push to `main` to trigger builds. Tag with `v*` for auto-release:

```bash
git tag v1.0.0
git push origin --tags
```

## 📜 License

MIT
