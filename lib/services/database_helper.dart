import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // 👇 แก้จุดนี้: เปลี่ยนชื่อไฟล์เป็น _v2 เพื่อบังคับสร้างใหม่ (แก้ Error: no such table)
    String path = join(await getDatabasesPath(), 'mixtail_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // สร้างตาราง
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            name TEXT,
            imageUrl TEXT,
            instructions TEXT,
            isCustom INTEGER
          )
        ''');
      },
    );
  }

  // 1. เพิ่มรายการโปรด
  Future<void> insertFavorite(Recipe recipe) async {
    final db = await database;
    await db.insert(
      'favorites',
      recipe.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. ดึงข้อมูลทั้งหมด
  Future<List<Recipe>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      return Recipe.fromJson(maps[i]);
    });
  }

  // 3. ลบข้อมูล
  Future<int> deleteFavorite(String id) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 4. เช็คว่าบันทึกหรือยัง
  Future<bool> isFavorite(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
