import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'app_vocacional.db'),
      version: 1,
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE ${Tables.profile}(id INTEGER PRIMARY KEY,name TEXT NOT NULL,age INTEGER,gender TEXT,schoolId TEXT,schoolNameSnapshot TEXT,languageIds TEXT,languageNamesSnapshot TEXT,otherLanguage TEXT,avatarId TEXT,updatedAt TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE ${Tables.schools}(id TEXT PRIMARY KEY,name TEXT NOT NULL,active INTEGER NOT NULL DEFAULT 1,updatedAt TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE ${Tables.languages}(id TEXT PRIMARY KEY,name TEXT NOT NULL,active INTEGER NOT NULL DEFAULT 1,updatedAt TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE ${Tables.testSessions}(id TEXT PRIMARY KEY,startedAt TEXT NOT NULL,completedAt TEXT,questionOrder TEXT NOT NULL,currentIndex INTEGER NOT NULL DEFAULT 0,openResponse TEXT,status TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE ${Tables.answers}(id INTEGER PRIMARY KEY AUTOINCREMENT,sessionId TEXT NOT NULL,questionId TEXT NOT NULL,value INTEGER,position INTEGER NOT NULL,updatedAt TEXT NOT NULL,UNIQUE(sessionId,questionId))',
        );
        await db.execute(
          'CREATE TABLE ${Tables.results}(id TEXT PRIMARY KEY,sessionId TEXT NOT NULL,createdAt TEXT NOT NULL,riasecJson TEXT NOT NULL,hollandCode TEXT NOT NULL,careersJson TEXT NOT NULL,openResponse TEXT,profileSnapshotJson TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE ${Tables.syncQueue}(id INTEGER PRIMARY KEY AUTOINCREMENT,entityType TEXT NOT NULL,entityId TEXT NOT NULL,payloadJson TEXT NOT NULL,createdAt TEXT NOT NULL,attempts INTEGER NOT NULL DEFAULT 0,lastError TEXT)',
        );
      },
    );
    return _db!;
  }
}
