import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ckd_care_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patient_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone_number TEXT,
        weight REAL,
        height REAL,
        ckd_stage TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE feedback(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone_number TEXT,
        feedback_text TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Patient Details Operations
  Future<int> insertPatientDetails(PatientDetails details) async {
    Database db = await database;
    return await db.insert('patient_details', details.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<PatientDetails?> getPatientDetails() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('patient_details', limit: 1);
    if (maps.isNotEmpty) {
      return PatientDetails.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePatientDetails(PatientDetails details) async {
    Database db = await database;
    return await db.update(
      'patient_details',
      details.toMap(),
      where: 'id = ?',
      whereArgs: [details.id],
    );
  }

  // Feedback Operations
  Future<int> insertFeedback(FeedbackModel feedback) async {
    Database db = await database;
    return await db.insert('feedback', feedback.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FeedbackModel>> getFeedbacks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('feedback', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }
}
