import 'dart:convert';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/models/career_match.dart';
import '../domain/models/riasec_result.dart';
import '../../../../core/constants/riasec_constants.dart';

class ResultLocalDataSource {
  final AppDatabase db;
  ResultLocalDataSource({AppDatabase? database})
    : db = database ?? AppDatabase.instance;
  Future<void> save({
    required String id,
    required String sessionId,
    required RiasecResult result,
    required List<CareerMatch> careers,
    required String? openResponse,
    required Map<String, dynamic> profile,
  }) async {
    final d = await db.database;
    await d.insert(Tables.results, {
      'id': id,
      'sessionId': sessionId,
      'createdAt': AppDateUtils.now(),
      'riasecJson': jsonEncode(
        result.scores.map((k, v) => MapEntry(k.code, v)),
      ),
      'hollandCode': result.hollandCode,
      'careersJson': jsonEncode(
        careers
            .map(
              (c) => {'id': c.careerId, 'name': c.careerName, 'score': c.score},
            )
            .toList(),
      ),
      'openResponse': openResponse,
      'profileSnapshotJson': jsonEncode(profile),
    });
  }

  Future<Map<String, dynamic>?> latest() async {
    final d = await db.database;
    final r = await d.query(
      Tables.results,
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    return r.isEmpty ? null : _decode(r.first);
  }

  Future<List<Map<String, dynamic>>> history() async {
    final d = await db.database;
    final r = await d.query(Tables.results, orderBy: 'createdAt DESC');
    return r.map(_decode).toList();
  }

  Map<String, dynamic> _decode(Map<String, Object?> r) => {
    ...r,
    'riasec': jsonDecode(r['riasecJson'] as String),
    'careers': jsonDecode(r['careersJson'] as String),
  };
}
