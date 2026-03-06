import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/lung_nodule.dart';
import '../models/follow_up_record.dart';

/// 数据库管理类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lung_nodule.db');
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

  Future _createDB(Database db, int version) async {
    // 患者表
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        isMale INTEGER NOT NULL,
        phoneNumber TEXT,
        idCardNumber TEXT,
        isSmoker INTEGER NOT NULL DEFAULT 0,
        packYears INTEGER NOT NULL DEFAULT 0,
        hasCancerHistory INTEGER NOT NULL DEFAULT 0,
        hasFamilyHistory INTEGER NOT NULL DEFAULT 0,
        hasCOPD INTEGER NOT NULL DEFAULT 0,
        hasTuberculosis INTEGER NOT NULL DEFAULT 0,
        hasPulmonaryFibrosis INTEGER NOT NULL DEFAULT 0,
        occupation TEXT,
        hasHighRiskExposure INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 肺结节表
    await db.execute('''
      CREATE TABLE nodules (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        discoveryDate TEXT NOT NULL,
        discoveryMethod TEXT,
        diameter REAL NOT NULL,
        density INTEGER NOT NULL,
        solidComponentRatio REAL,
        solidComponentSize REAL,
        lobe INTEGER NOT NULL,
        segment TEXT,
        specificLocation TEXT,
        hasSpiculation INTEGER NOT NULL DEFAULT 0,
        hasLobulation INTEGER NOT NULL DEFAULT 0,
        hasPleuralIndentation INTEGER NOT NULL DEFAULT 0,
        hasVascularConvergence INTEGER NOT NULL DEFAULT 0,
        hasBubbleSign INTEGER NOT NULL DEFAULT 0,
        hasCavity INTEGER NOT NULL DEFAULT 0,
        ctValueMin REAL,
        ctValueMax REAL,
        ctValueMean REAL,
        malignancyProbability REAL,
        riskLevel TEXT,
        nextFollowUpDate TEXT,
        followUpPlan TEXT,
        followUpIntervalMonths INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        status TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // 随访记录表
    await db.execute('''
      CREATE TABLE follow_up_records (
        id TEXT PRIMARY KEY,
        noduleId TEXT NOT NULL,
        patientId TEXT NOT NULL,
        checkDate TEXT NOT NULL,
        checkMethod TEXT NOT NULL,
        hospitalName TEXT,
        doctorName TEXT,
        diameter REAL NOT NULL,
        previousDiameter REAL,
        diameterChange REAL,
        volumeChangePercent REAL,
        densityChange TEXT,
        hasNewSolidComponent INTEGER NOT NULL DEFAULT 0,
        hasSolidComponentIncrease INTEGER NOT NULL DEFAULT 0,
        newSolidComponentSize REAL,
        hasEnlargement INTEGER NOT NULL DEFAULT 0,
        hasMorphologyChange INTEGER NOT NULL DEFAULT 0,
        morphologyChangeDesc TEXT,
        volumeDoublingTime REAL,
        isStable INTEGER NOT NULL DEFAULT 1,
        isSuspicious INTEGER NOT NULL DEFAULT 0,
        assessment TEXT,
        doctorAdvice TEXT,
        nextFollowUpDate TEXT,
        nextFollowUpPlan TEXT,
        imagePath TEXT,
        dicomUid TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (noduleId) REFERENCES nodules (id) ON DELETE CASCADE,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_nodules_patient ON nodules(patientId)');
    await db.execute('CREATE INDEX idx_nodules_next_follow_up ON nodules(nextFollowUpDate)');
    await db.execute('CREATE INDEX idx_follow_up_nodule ON follow_up_records(noduleId)');
  }

  // ==================== 患者操作 ====================
  
  Future<String> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap());
    return patient.id;
  }

  Future<Patient?> getPatient(String id) async {
    final db = await database;
    final maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final result = await db.query('patients', orderBy: 'createdAt DESC');
    return result.map((map) => Patient.fromMap(map)).toList();
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await database;
    final result = await db.query(
      'patients',
      where: 'name LIKE ? OR phoneNumber LIKE ? OR idCardNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(String id) async {
    final db = await database;
    return db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 结节操作 ====================

  Future<String> insertNodule(LungNodule nodule) async {
    final db = await database;
    await db.insert('nodules', nodule.toMap());
    return nodule.id;
  }

  Future<LungNodule?> getNodule(String id) async {
    final db = await database;
    final maps = await db.query(
      'nodules',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return LungNodule.fromMap(maps.first);
    }
    return null;
  }

  Future<List<LungNodule>> getNodulesByPatient(String patientId) async {
    final db = await database;
    final result = await db.query(
      'nodules',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => LungNodule.fromMap(map)).toList();
  }

  Future<List<LungNodule>> getAllActiveNodules() async {
    final db = await database;
    final result = await db.query(
      'nodules',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'nextFollowUpDate ASC',
    );
    return result.map((map) => LungNodule.fromMap(map)).toList();
  }

  /// 获取需要随访的结节（ upcoming 或 overdue）
  Future<List<LungNodule>> getUpcomingFollowUps({int days = 30}) async {
    final db = await database;
    final targetDate = DateTime.now().add(Duration(days: days));
    
    final result = await db.query(
      'nodules',
      where: 'isActive = ? AND nextFollowUpDate <= ?',
      whereArgs: [1, targetDate.toIso8601String()],
      orderBy: 'nextFollowUpDate ASC',
    );
    return result.map((map) => LungNodule.fromMap(map)).toList();
  }

  Future<int> updateNodule(LungNodule nodule) async {
    final db = await database;
    return db.update(
      'nodules',
      nodule.toMap(),
      where: 'id = ?',
      whereArgs: [nodule.id],
    );
  }

  Future<int> deleteNodule(String id) async {
    final db = await database;
    return db.delete(
      'nodules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 随访记录操作 ====================

  Future<String> insertFollowUpRecord(FollowUpRecord record) async {
    final db = await database;
    await db.insert('follow_up_records', record.toMap());
    return record.id;
  }

  Future<List<FollowUpRecord>> getFollowUpRecordsByNodule(String noduleId) async {
    final db = await database;
    final result = await db.query(
      'follow_up_records',
      where: 'noduleId = ?',
      whereArgs: [noduleId],
      orderBy: 'checkDate DESC',
    );
    return result.map((map) => FollowUpRecord.fromMap(map)).toList();
  }

  Future<FollowUpRecord?> getLatestFollowUpRecord(String noduleId) async {
    final db = await database;
    final result = await db.query(
      'follow_up_records',
      where: 'noduleId = ?',
      whereArgs: [noduleId],
      orderBy: 'checkDate DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return FollowUpRecord.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateFollowUpRecord(FollowUpRecord record) async {
    final db = await database;
    return db.update(
      'follow_up_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteFollowUpRecord(String id) async {
    final db = await database;
    return db.delete(
      'follow_up_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 统计方法 ====================

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // 患者总数
    final patientCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM patients')
    ) ?? 0;
    
    // 结节总数
    final noduleCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM nodules')
    ) ?? 0;
    
    // 活跃结节数
    final activeNoduleCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM nodules WHERE isActive = 1')
    ) ?? 0;
    
    // 本月待随访
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final upcomingCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM nodules WHERE isActive = 1 AND nextFollowUpDate <= ?',
        [endOfMonth.toIso8601String()]
      )
    ) ?? 0;
    
    // 已逾期
    final overdueCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM nodules WHERE isActive = 1 AND nextFollowUpDate < ?',
        [now.toIso8601String()]
      )
    ) ?? 0;

    return {
      'patientCount': patientCount,
      'noduleCount': noduleCount,
      'activeNoduleCount': activeNoduleCount,
      'upcomingCount': upcomingCount,
      'overdueCount': overdueCount,
    };
  }

  // ==================== 数据库维护 ====================

  Future close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('follow_up_records');
    await db.delete('nodules');
    await db.delete('patients');
  }
}