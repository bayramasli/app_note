import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_model.dart';
import '../../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'note_app.db');

    _database = await openDatabase(
      path,
      version: 3, // Yeni alanlar için versiyonu artırdık
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    // Kullanıcı tablosu
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT
      )
    ''');

    // Güncellenmiş Notlar tablosu (yeni alanlar eklendi)
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT,
        reminderDate TEXT,
        location TEXT,
        imagePath TEXT,
        imageUrl TEXT,
        type TEXT DEFAULT 'personal',
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Versiyon 1'den 2'ye geçiş
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

    if (oldVersion < 3) {
      // Versiyon 2'den 3'e geçiş (yeni alanlar eklendi)
      await db.execute('ALTER TABLE notes ADD COLUMN reminderDate TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN imagePath TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN imageUrl TEXT');
      await db
          .execute('ALTER TABLE notes ADD COLUMN type TEXT DEFAULT "personal"');
    }
  }

  // ------------------------- KULLANICI İŞLEMLERİ -------------------------

  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

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

  Future<int> addNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<NoteModel>> getNotesByUserId(int userId,
      {String? filterType, String? searchQuery}) async {
    final db = await database;

    String whereClause = 'userId = ?';
    List<Object> whereArgs = [userId];

    // Filtreleme
    if (filterType != null && filterType != 'all') {
      whereClause += ' AND type = ?';
      whereArgs.add(filterType);
    }

    // Arama
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (title LIKE ? OR content LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    final result = await db.query(
      'notes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> getNotesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  // Diğer yardımcı metodlar
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<List<NoteModel>> getRecentNotes({int limit = 50}) async {
    final db = await database;
    final result = await db.query(
      'notes',
      orderBy: 'date DESC',
      limit: limit,
    );
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }
}
