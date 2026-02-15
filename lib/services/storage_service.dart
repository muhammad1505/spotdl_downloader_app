import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../models/download_item.dart';

class StorageService {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/${AppConstants.dbName}';

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableDownloads} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            url TEXT NOT NULL,
            albumArt TEXT,
            duration TEXT,
            fileSize TEXT,
            filePath TEXT NOT NULL,
            status TEXT NOT NULL,
            type TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a new download record
  Future<int> insertDownload(DownloadItem item) async {
    final db = await database;
    return db.insert(
      AppConstants.tableDownloads,
      item.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all downloads
  Future<List<DownloadItem>> getAllDownloads() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableDownloads,
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DownloadItem.fromMap(map)).toList();
  }

  /// Search downloads
  Future<List<DownloadItem>> searchDownloads(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableDownloads,
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DownloadItem.fromMap(map)).toList();
  }

  /// Get downloads filtered by type
  Future<List<DownloadItem>> getDownloadsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableDownloads,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DownloadItem.fromMap(map)).toList();
  }

  /// Get downloads sorted
  Future<List<DownloadItem>> getDownloadsSorted(String sortBy) async {
    final db = await database;
    String orderBy;
    switch (sortBy) {
      case 'name':
        orderBy = 'title ASC';
        break;
      case 'size':
        orderBy = 'fileSize DESC';
        break;
      case 'newest':
      default:
        orderBy = 'createdAt DESC';
        break;
    }
    final maps = await db.query(
      AppConstants.tableDownloads,
      orderBy: orderBy,
    );
    return maps.map((map) => DownloadItem.fromMap(map)).toList();
  }

  /// Update download status
  Future<int> updateDownloadStatus(int id, String status) async {
    final db = await database;
    return db.update(
      AppConstants.tableDownloads,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a download record
  Future<int> deleteDownload(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableDownloads,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all downloads
  Future<int> deleteAllDownloads() async {
    final db = await database;
    return db.delete(AppConstants.tableDownloads);
  }

  /// Get download count
  Future<int> getDownloadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableDownloads}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
