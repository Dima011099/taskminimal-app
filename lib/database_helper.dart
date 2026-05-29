import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onOpen: (db) async {await db.execute('PRAGMA foreign_keys = ON');});

   
  }

  Future _createDB(Database db, int version) async {
await db.execute('''
  CREATE TABLE projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0, -- ДОБАВИТЬ СТРОКУ
      created_at TEXT NOT NULL,
      update_at TEXT NOT NULL
  )
''');


    await db.execute('''
        CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        task_token TEXT NOT NULL UNIQUE,      -- Глобальный уникальный ID задачи
        title TEXT NOT NULL,
        status INTEGER NOT NULL, 
        difficulty INTEGER NOT NULL DEFAULT 1, 
        is_deleted INTEGER NOT NULL DEFAULT 0, -- Мягкое удаление (0 - жива, 1 - удалена)
        created_at TEXT NOT NULL,  
        update_at TEXT NOT NULL,          
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
        )
    ''');


    await db.execute('''
          CREATE TABLE sync_tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL,
            sync_token TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_used_at DATETIME,
            UNIQUE(project_id) 
          )
    ''');
  }

  Future<List<Map<String, dynamic>>> readAllTasks() async {
    final db = await instance.database;
    return await db.query('tasks', where: 'is_deleted = 0');
  }

    Future<List<Map<String, dynamic>>> readAllTasksWithDelete() async {
    final db = await instance.database;
    return await db.query('tasks');
  }


  

  


  Future<List<Map<String, dynamic>>> readAllTasksWhereProjectID(int projectID) async {
    final db = await instance.database;
    return db.query(
      'tasks',
      where: 'project_id = ? AND is_deleted = 0',
      whereArgs: [projectID],
    );
  }

    Future<List<Map<String, dynamic>>> readActiveTasksWhereProjectID(int projectID) async {
    final db = await instance.database;
    return db.query(
      'tasks',
      where: 'project_id = ? AND is_deleted = 0', // Показываем только живые
      whereArgs: [projectID],
    );
  }

  Future<Map<String, dynamic>?> readProjectWhereID(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    'projects',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return maps.first; // Возвращаем найденный проект
  } else {
    return null; // Если проекта с таким id нет в базе
  }
}
Future<void> vacuumDeletedData() async {
  final dbClient = await instance.database;
  
  // Физически удаляем из базы проекты и задачи, которые были мягко удалены
  await dbClient.delete('tasks', where: 'is_deleted = 1');
  await dbClient.delete('projects', where: 'is_deleted = 1');
  
  // Сжимаем файл базы данных на диске, возвращая свободное место операционной системе
  await dbClient.execute('VACUUM');
}


  Future<List<Map<String, dynamic>>> readAllProjects() async {
    final db = await instance.database;
    return await db.query('projects', where: 'is_deleted = 0');
  }
    Future<List<Map<String, dynamic>>> readAllProjectsWithDelete() async {
    final db = await instance.database;
    return await db.query('projects');
  }

   Future<int> createProject (String title) async {
     final db = await instance.database;
     return await db.insert('projects', {
      'name': title,
      'created_at': DateTime.now().toIso8601String(), 
      'update_at': DateTime.now().toIso8601String(), 
      });
   }


    Future<int> createTask(String title, int projectID) async {
    final dbClient = await instance.database;
    final String taskToken = 'task_${DateTime.now().microsecondsSinceEpoch}';

    return await dbClient.insert('tasks', {
      'project_id': projectID,
      'task_token': taskToken,
      'title': title,
      'status': 0,
      'difficulty': 1,
      'is_deleted': 0,
      'created_at': DateTime.now().toIso8601String(), 
      'update_at': DateTime.now().toIso8601String(), 
    });
  }


   Future<List<Map<String, dynamic>>> readTaskWhereID(int id) async {
      final db = await instance.database;
      return db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
   }
/*
  Future<int> updateTaskTitle(int id, String title) async {
    final db = await instance.database;
    return await db.update('tasks', {'title': title}, where: 'id = ?', whereArgs: [id]);
  }*/
   Future<int> updateTaskTitle(int id, String title) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'title': title, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> updateProjectTitle(int id, String title) async {
    final db = await instance.database;
    return await db.update('projects', {'name': title,  'update_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

/*
  Future<int> updateTaskStatus(int id, int status) async {
    final db = await instance.database;
    return await db.update('tasks', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }*/
    Future<int> updateTaskStatus(int id, int status) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'status': status, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
/*
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }*/
    Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'is_deleted': 1, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

/*
  Future<int> deleteProject(int id) async {
    final db = await instance.database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }*/
  Future<int> deleteProject(int id) async {
  final dbClient = await instance.database;
  final now = DateTime.now().toIso8601String();

  return await dbClient.transaction((txn) async {
    // 1. Помечаем удаленным сам проект
    await txn.update(
      'projects',
      {'is_deleted': 1, 'update_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2. Помечаем удаленными все задачи этого проекта (вместо каскадного удаления)
    return await txn.update(
      'tasks',
      {'is_deleted': 1, 'update_at': now},
      where: 'project_id = ?',
      whereArgs: [id],
    );
  });
}

  Future<int> insertTask(Map<String, dynamic> taskData, {Transaction? txn}) async {
  // 1. Используем переданную транзакцию или получаем обычный экземпляр БД
  final dbClient = txn ?? await instance.database;

  // 2. Создаем копию данных, чтобы добавить поля по умолчанию, если их нет
  final Map<String, dynamic> finalTask = Map<String, dynamic>.from(taskData);

  // Добавляем значения по умолчанию только если они не переданы (например, из JSON)
  finalTask['status'] ??= 0;
  finalTask['difficulty'] ??= 1;
  finalTask['created_at'] ??= DateTime.now().toIso8601String();
  finalTask['update_at'] = DateTime.now().toIso8601String(); // Обновляем всегда

  // 3. Выполняем вставку
  return await dbClient.insert(
    'tasks',
    finalTask,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
}