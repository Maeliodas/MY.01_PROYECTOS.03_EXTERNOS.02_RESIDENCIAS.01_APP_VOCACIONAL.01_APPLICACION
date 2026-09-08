import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CatalogDatabase {
  CatalogDatabase._();

  static final CatalogDatabase instance = CatalogDatabase._();

  static const String _databaseName = 'ittux_catalog.db';
  static const String _assetPath = 'assets/database/ittux_catalog.db';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final databasesPath = await getDatabasesPath();
    final databasePath = join(
      databasesPath,
      _databaseName,
    );

    final exists = await databaseExists(databasePath);

    if (!exists) {
      await _copyDatabaseFromAssets(databasePath);
    }

    _db = await openDatabase(
      databasePath,
      readOnly: false,
    );

    return _db!;
  }

  Future<void> _copyDatabaseFromAssets(
    String databasePath,
  ) async {
    final data = await rootBundle.load(_assetPath);

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final file = File(databasePath);

    await file.parent.create(
      recursive: true,
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
