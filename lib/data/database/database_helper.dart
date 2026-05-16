import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/detection.dart';
import '../models/achievement.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('axon_scout.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Detection table
    await db.execute('''
      CREATE TABLE detections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        rssi INTEGER NOT NULL,
        estimated_distance REAL NOT NULL,
        bearing INTEGER,
        timestamp TEXT NOT NULL,
        device_label TEXT,
        is_team_beacon INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        unlocked_at TEXT
      )
    ''');

    // Statistics table
    await db.execute('''
      CREATE TABLE statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Calibration data table
    await db.execute('''
      CREATE TABLE calibration (
        id INTEGER PRIMARY KEY,
        rssi_1m INTEGER,
        rssi_5m INTEGER,
        rssi_10m INTEGER,
        path_loss_exponent REAL,
        calibrated_at TEXT
      )
    ''');

    // Initialize achievements
    for (final achievement in Achievements.all) {
      await db.insert('achievements', achievement.toMap());
    }

    // Initialize default statistics
    await db.insert('statistics', {
      'key': 'longest_session',
      'value': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
    await db.insert('statistics', {
      'key': 'most_beacons_detected',
      'value': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
    await db.insert('statistics', {
      'key': 'total_detections',
      'value': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Detection operations
  Future<int> insertDetection(Detection detection) async {
    final db = await database;
    return await db.insert('detections', detection.toMap());
  }

  Future<List<Detection>> getAllDetections() async {
    final db = await database;
    final maps = await db.query(
      'detections',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => Detection.fromMap(map)).toList();
  }

  Future<List<Detection>> getRecentDetections(int limit) async {
    final db = await database;
    final maps = await db.query(
      'detections',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => Detection.fromMap(map)).toList();
  }

  Future<int> getUniqueDeviceCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT device_id) as count FROM detections',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalDetectionCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM detections',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getDetectionCountByHour() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT 
        strftime('%H', timestamp) as hour,
        COUNT(*) as count 
      FROM detections 
      GROUP BY hour
    ''');
    
    final result = <String, int>{};
    for (final map in maps) {
      result[map['hour'] as String] = map['count'] as int;
    }
    return result;
  }

  // Achievement operations
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final maps = await db.query('achievements');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.update(
      'achievements',
      {'unlocked_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics operations
  Future<int> getStatistic(String key) async {
    final db = await database;
    final result = await db.query(
      'statistics',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return 0;
    return result.first['value'] as int;
  }

  Future<void> updateStatistic(String key, int value) async {
    final db = await database;
    await db.update(
      'statistics',
      {
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> updateStatisticIfGreater(String key, int value) async {
    final current = await getStatistic(key);
    if (value > current) {
      await updateStatistic(key, value);
    }
  }

  // Reset all data
  Future<void> resetAllData() async {
    final db = await database;
    await db.delete('detections');
    await db.update('achievements', {'unlocked_at': null});
    await db.update('statistics', {'value': 0});
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}