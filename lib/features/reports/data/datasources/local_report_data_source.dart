import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';

abstract interface class LocalReportDataSource {
  Future<void> insertReport(LocalReportModel report);
  Future<void> updateReport(LocalReportModel report);
  Future<void> deleteReport(String localId);
  Future<LocalReportModel?> getReportById(String localId);
  Future<List<LocalReportModel>> getAllReports();
}

class LocalReportDataSourceImpl implements LocalReportDataSource {
  final DatabaseHelper _dbHelper;

  LocalReportDataSourceImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> insertReport(LocalReportModel report) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateReport(LocalReportModel report) async {
    final db = await _dbHelper.database;
    await db.update(
      'reports',
      report.toMap(),
      where: 'local_id = ?',
      whereArgs: [report.localId],
    );
  }

  @override
  Future<void> deleteReport(String localId) async {
    final db = await _dbHelper.database;
    await db.delete('reports', where: 'local_id = ?', whereArgs: [localId]);
  }

  @override
  Future<LocalReportModel?> getReportById(String localId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reports',
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    if (maps.isNotEmpty) {
      return LocalReportModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<LocalReportModel>> getAllReports() async {
    final db = await _dbHelper.database;
    final maps = await db.query('reports', orderBy: 'created_at DESC');
    return maps.map((map) => LocalReportModel.fromMap(map)).toList();
  }
}
