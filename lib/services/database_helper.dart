import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/models/weight.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:myapp/utils/logger_config.dart'; // Import logger

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (!kIsWeb) { // Only initialize database if not on web
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ckd_care_app.db');
    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patient_details(
        id TEXT PRIMARY KEY,
        user_id TEXT, -- New column for user ID
        name TEXT,
        email TEXT,
        phone_number TEXT,
        weight REAL,
        height REAL,
        ckd_stage TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE feedback(
        id TEXT PRIMARY KEY,
        name TEXT,
        phone_number TEXT,
        feedback_text TEXT,
        category TEXT, -- Added category column
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE blood_pressure_readings(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        systolic INTEGER,
        diastolic INTEGER,
        timestamp TEXT,
        comment TEXT -- New column for comment
      )
    ''');
    await db.execute('''
      CREATE TABLE creatine_readings(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        value REAL,
        timestamp TEXT,
        comment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE weight_readings(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        value REAL,
        timestamp TEXT,
        comment TEXT
      )
    ''');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // This is a simple migration strategy for development: drop and recreate table.
      // For production, you would use ALTER TABLE to add the column without losing data.
      await db.execute('DROP TABLE IF EXISTS feedback');
      await db.execute('''
        CREATE TABLE feedback(
          id TEXT PRIMARY KEY,
          name TEXT,
          phone_number TEXT,
          feedback_text TEXT,
          category TEXT, -- Added category column
          timestamp TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Migrate from version 2 to 3: Add user_id column to patient_details
      await db.execute('ALTER TABLE patient_details ADD COLUMN user_id TEXT;');
    }
    if (oldVersion < 4) {
      // Migrate from version 3 to 4: Add blood_pressure_readings table and comment column
      await db.execute('''
        CREATE TABLE blood_pressure_readings(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          systolic INTEGER,
          diastolic INTEGER,
          timestamp TEXT,
          comment TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      // Migrate from version 4 to 5: Add email column to patient_details
      await db.execute('ALTER TABLE patient_details ADD COLUMN email TEXT;');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE creatine_readings(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          value REAL,
          timestamp TEXT,
          comment TEXT
        )
      ''');
    }
     if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE weight_readings(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          value REAL,
          timestamp TEXT,
          comment TEXT
        )
      ''');
    }
  }

  // Patient Details Operations
  Future<String?> insertPatientDetails(PatientDetails details) async {
    if (kIsWeb) return null; // Do not use SQLite on web
    Database db = await database;
    details.id ??= Uuid().v4();
    // Ensure user_id is included in the map for insertion
    await db.insert('patient_details', details.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return details.id!;
  }

  Future<PatientDetails?> getPatientDetails() async {
    if (kIsWeb) return null; // Do not use SQLite on web
    Database db = await database;
    // Fetch all columns, including user_id
    List<Map<String, dynamic>> maps = await db.query('patient_details', limit: 1);
    if (maps.isNotEmpty) {
      return PatientDetails.fromMap(maps.first);
    }
    return null;
  }

  // Feedback Operations
  Future<String?> insertFeedback(FeedbackModel feedback) async {
    if (kIsWeb) return null; // Do not use SQLite on web
    Database db = await database;
    feedback.id ??= Uuid().v4(); // Generate UUID if not provided
    await db.insert('feedback', feedback.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return feedback.id!;
  }

  Future<List<FeedbackModel>> getFeedbacks() async {
    if (kIsWeb) return []; // Do not fetch from SQLite on web
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('feedback', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }

  // Blood Pressure Operations
  Future<String?> insertBloodPressure(BloodPressure bp) async {
    if (kIsWeb) return null; // Do not use SQLite on web
    Database db = await database;
    bp.id ??= Uuid().v4();
    await db.insert('blood_pressure_readings', bp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return bp.id!;
  }

  Future<List<BloodPressure>> getBloodPressureReadings(String userId) async {
    if (kIsWeb) return []; // Do not fetch from SQLite on web
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC', // Order by newest first
    );
    return List.generate(maps.length, (i) {
      return BloodPressure.fromMap(maps[i]);
    });
  }

  Future<void> clearBloodPressureReadings() async {
    if (kIsWeb) return; // Do not clear SQLite on web
    Database db = await database;
    await db.delete('blood_pressure_readings');
    logger.i('All blood pressure readings cleared from SQLite.');
  }

  Future<void> deleteBloodPressure(String id) async {
    if (kIsWeb) return; // Do not delete from SQLite on web
    Database db = await database;
    await db.delete(
      'blood_pressure_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
    logger.i('Blood pressure reading with ID $id deleted from SQLite.');
  }

  // Creatine Operations
  Future<String?> insertCreatine(Creatine creatine) async {
    if (kIsWeb) return null;
    Database db = await database;
    creatine.id ??= Uuid().v4();
    await db.insert('creatine_readings', creatine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return creatine.id!;
  }

  Future<List<Creatine>> getCreatineReadings(String userId) async {
    if (kIsWeb) return [];
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'creatine_readings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return Creatine.fromMap(maps[i]);
    });
  }

  Future<void> deleteCreatine(String id) async {
    if (kIsWeb) return;
    Database db = await database;
    await db.delete(
      'creatine_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
    logger.i('Creatine reading with ID $id deleted from SQLite.');
  }

  Future<void> clearCreatineReadings() async {
    if (kIsWeb) return;
    Database db = await database;
    await db.delete('creatine_readings');
    logger.i('All creatine readings cleared from SQLite.');
  }

  // Weight Operations
  Future<String?> insertWeight(Weight weight) async {
    if (kIsWeb) return null;
    Database db = await database;
    weight.id ??= Uuid().v4();
    await db.insert('weight_readings', weight.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return weight.id!;
  }

  Future<List<Weight>> getWeightReadings(String userId) async {
    if (kIsWeb) return [];
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'weight_readings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return Weight.fromMap(maps[i]);
    });
  }

  Future<void> deleteWeight(String id) async {
    if (kIsWeb) return;
    Database db = await database;
    await db.delete(
      'weight_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
    logger.i('Weight reading with ID $id deleted from SQLite.');
  }

  Future<void> clearWeightReadings() async {
    if (kIsWeb) return;
    Database db = await database;
    await db.delete('weight_readings');
    logger.i('All weight readings cleared from SQLite.');
  }
}
