import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_database.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        userType TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY,
        parentId INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        FOREIGN KEY (parentId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        subject TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE children (
          id INTEGER PRIMARY KEY,
          parentId INTEGER NOT NULL,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          birthdate TEXT NOT NULL,
          FOREIGN KEY (parentId) REFERENCES users(id)
        )
      ''');
    }
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE teachers (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          subject TEXT NOT NULL
        )
      ''');
    }
  }

  Future<int> registerUser(String username, String password, String userType) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
      'userType': userType,
    });
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> checkAndRegisterAdmin() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    if (result.isEmpty) {
      await registerUser('admin', 'admin123', 'admin');
    }
  }

  Future<List<Map<String, dynamic>>> getParents() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'userType = ?',
      whereArgs: ['parent'],
    );
  }

  Future<int> registerChild(int parentId, String name, String address, String birthdate) async {
    final db = await database;
    return await db.insert('children', {
      'parentId': parentId,
      'name': name,
      'address': address,
      'birthdate': birthdate,
    });
  }

  Future<int> registerTeacher(String name, String subject) async {
    final db = await database;
    return await db.insert('teachers', {
      'name': name,
      'subject': subject,
    });
  }

  Future<List<Map<String, dynamic>>> getTeachers() async {
    final db = await database;
    return await db.query('teachers');
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete(
      'teachers', // Cambiado a la tabla correcta
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
