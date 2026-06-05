import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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

   Future<int> updateTaskTitle(int id, String title) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'title': title, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
/*
  Future<int> updateProjectTitle(int id, String title) async {
    final db = await instance.database;
    return await db.update('projects', {'name': title,  'update_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }
*/

Future<int> updateProjectTitle(int id, String title) async {
  final dbClient = await instance.database;
  final now = DateTime.now().toIso8601String();

  // Обязательно используем транзакцию, чтобы оба обновления выполнились вместе
  return await dbClient.transaction((txn) async {
    // 1. Обновляем имя и дату самого проекта
    final res = await txn.update(
      'projects', 
      {
        'name': title,  
        'update_at': now
      }, 
      where: 'id = ?', 
      whereArgs: [id]
    );

    // 2. ИСПРАВЛЕНИЕ: Обновляем update_at у всех задач этого проекта.
    // Теперь локальные задачи станут "свежее" серверных, и сервер не затрет их старыми копиями.
    await txn.update(
      'tasks',
      {'update_at': now},
      where: 'project_id = ?',
      whereArgs: [id],
    );

    return res;
  });
}

    Future<int> updateTaskStatus(int id, int status) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'status': status, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

    Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.update(
      'tasks', 
      {'is_deleted': 1, 'update_at': DateTime.now().toIso8601String()}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }


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



/// Получает существующий токен проекта или генерирует новый, если его нет
  Future<String> getOrCreateSyncToken(int projectId) async {
    final dbClient = await database;

    final List<Map<String, dynamic>> syncRecords = await dbClient.query(
      'sync_tasks',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    if (syncRecords.isNotEmpty) {
      return syncRecords.first['sync_token'] as String;
    }

    // Если токена нет, создаем новый UUID v4
    final String newToken = const Uuid().v4();
    
    await dbClient.insert('sync_tasks', {
      'project_id': projectId,
      'sync_token': newToken,
    });

    return newToken;
  }

  /// Логика импорта: проверяет токен, очищает старые данные при совпадении 
  /// или создает новый проект. Все операции выполняются в одной транзакции.
  Future<void> importProjectData({
    required String? token,
    required String name,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final dbClient = await database;

    // Одно атомарное действие: если внутри что-то упадет, изменения откатятся
    await dbClient.transaction((txn) async {
      int targetProjectId;

      if (token != null) {
        final List<Map<String, dynamic>> existingSync = await txn.query(
          'sync_tasks',
          where: 'sync_token = ?',
          whereArgs: [token],
        );

        if (existingSync.isNotEmpty) {
          // Сценарий 1: Проект уже импортировался ранее
          targetProjectId = existingSync.first['project_id'] as int;

          // Очищаем старые задачи
          await txn.delete(
            'tasks',
            where: 'project_id = ?',
            whereArgs: [targetProjectId],
          );

          // Обновляем имя (на случай, если оно изменилось)
        await txn.update(
            'projects',
            {
              'name': name,
              'is_deleted': 0, // <--- ВОТ ЭТА СТРОКА ОЖИВИТ ИМПОРТ!
              'update_at': DateTime.now().toIso8601String(),
            }, // Замените на ваши реальные поля, если нужно
            where: 'id = ?',
            whereArgs: [targetProjectId],
          );
        } else {
          // Сценарий 2: Токен есть, но в нашей БД такого проекта еще нет
          targetProjectId = await _createProjectInsideTxn(txn, name);
          
          await txn.insert('sync_tasks', {
            'project_id': targetProjectId,
            'sync_token': token,
          });
        }
      } else {
        // Сценарий 3: Файл старый, токена нет — просто создаем новый проект
        targetProjectId = await _createProjectInsideTxn(txn, name);
      }

      // Записываем новые задачи в рамках той же транзакции
      for (var item in tasks) {
        final taskMap = Map<String, dynamic>.from(item);
        taskMap.remove('id'); // Удаляем старый ID, чтобы сгенерировался новый Autoincrement
        taskMap['project_id'] = targetProjectId;

        await txn.insert('tasks', taskMap);
      }
    });
  }

  // Вспомогательный метод для вставки проекта внутри транзакции
  Future<int> _createProjectInsideTxn(Transaction txn, String name) async {
    return await txn.insert('projects', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
      'update_at': DateTime.now().toIso8601String(),
    });
  }
}