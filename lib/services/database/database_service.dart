import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_model.dart';
import '../../models/note_model.dart'; // Not modeli import edildi

class DatabaseHelper {
  // Singleton yapısı: sadece bir örnek oluşturulur
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Veritabanı nesnesine erişim
  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth_app.db');

    _database = await openDatabase(
      path,
      version: 2, // versiyon 2 oldu çünkü notes tablosu eklendi
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  /// Veritabanı ilk kez oluşturulduğunda çalışır
  Future<void> _createDB(Database db, int version) async {
    // Kullanıcı tablosu
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // Notlar tablosu
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Veritabanı versiyonu artarsa çalışır
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date TEXT NOT NULL,
          category TEXT,
          FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // ------------------------- KULLANICI İŞLEMLERİ -------------------------

  /// Yeni kullanıcı ekler
  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  /// Email'e göre kullanıcıyı getirir
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  /// Kullanıcı şifresini günceller
  Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // -------------------------- NOT İŞLEMLERİ --------------------------

  /// Yeni not ekler
  Future<int> addNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  /// Belirli kullanıcıya ait notları getirir
  Future<List<NoteModel>> getNotesByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  /// Notu günceller
  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Notu siler
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'date DESC');
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }
}
