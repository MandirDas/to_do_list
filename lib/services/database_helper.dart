import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority INTEGER NOT NULL,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> create(Todo todo) async {
    final db = await instance.database;
    final id = await db.insert('todos', todo.toMap());
    return id;
  }

  Future<Todo?> readTodo(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'todos',
      columns: [
        'id',
        'title',
        'description',
        'priority',
        'dueDate',
        'isCompleted',
        'createdAt'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Todo>> readAllTodos() async {
    final db = await instance.database;
    final orderBy = 'createdAt DESC';
    final result = await db.query('todos', orderBy: orderBy);
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> searchTodos(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> getTodosSortedBy(String sortBy) async {
    final db = await instance.database;
    String orderBy;

    switch (sortBy) {
      case 'priority':
        orderBy = 'priority DESC';
        break;
      case 'dueDate':
        orderBy = 'dueDate ASC';
        break;
      case 'createdAt':
      default:
        orderBy = 'createdAt DESC';
        break;
    }

    final result = await db.query('todos', orderBy: orderBy);
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
