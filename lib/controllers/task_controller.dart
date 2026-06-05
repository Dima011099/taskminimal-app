import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:task_minimal/controllers/ProjectFileService.dart';

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../database_helper.dart';

class TaskController extends ChangeNotifier {
  final DatabaseHelper db;
   final ProjectFileService _fileService;

  List<Task> _tasks = [];
  List<Project> _projects = [];
  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;

  TaskController(this.db, this._fileService);

  int? _projectID;

  set projectID(int value) => _projectID = value;
  int? get projectID => _projectID;

  Future<void> load() async {
    //final data = await db.readAllTasks();
    final data = await db.readAllTasksWhereProjectID(_projectID!);
    _tasks = data.map(Task.fromMap).toList();
    notifyListeners();
  }

  Future<void> loadProjects() async {
    final data = await db.readAllProjects();
    _projects = data.map(Project.fromMap).toList();
    notifyListeners();
  }

  List<Task> byStatus(TaskStatus status) =>
      _tasks.where((t) => t.status == status).toList();

  Future<void> add(String title) async {
    await db.createTask(title, _projectID!);
    await load();
  }

  Future<void> updateTask(int id, String title) async{
    await db.updateTaskTitle(id, title);
    await load();
  }

  Future<void> updateProject(int id, String title) async{
    await db.updateProjectTitle(id, title);
    await loadProjects();
  }

  Future<void> exportProject(int id) async {
    await _fileService.exportProject(id);
  }

  /// Возвращает имя импортированного проекта или null при отмене/ошибке
   /*
  Future<String?> importProject() async {
    final projectName = await _fileService.importProject();
    if (projectName != null) {
      await loadProjects();
    }
    return projectName;
  }
  */

  
/*
Future<void> exportJson(int id) async {
  final projectData = await db.readProjectWhereID(id); 
  if (projectData == null) return;
  
  final dbClient = await db.database;
  
  // 1. Проверяем или создаем sync_token для этого проекта
  final List<Map<String, dynamic>> syncRecords = await dbClient.query(
    'sync_tasks',
    where: 'project_id = ?',
    whereArgs: [id],
  );
  
  String projectToken;
 if (syncRecords.isEmpty) {
  projectToken = const Uuid().v4(); 
  
  await dbClient.insert('sync_tasks', {
    'project_id': id,
    'sync_token': projectToken,
  });
} else {
  projectToken = syncRecords.first['sync_token'] as String;
}
  
  final tasksData = await db.readAllTasksWhereProjectID(id);

  // 2. Добавляем project_token в JSON payload
  final Map<String, dynamic> exportPayload = {
    "export_version": "1.0",
    "project_token": projectToken, // Ключевой маркер против дубликатов
    "project": {
      "name": projectData['name'],
      "created_at": projectData['created_at'],
      "update_at": projectData['update_at'],
    },
    "tasks": tasksData,
  };

  String jsonString = jsonEncode(exportPayload);
  Uint8List bytes = utf8.encode(jsonString);

  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Выберите место для сохранения экспорта',
    fileName: 'project_export_$id.json',
    type: FileType.custom,
    allowedExtensions: ['json'],
    bytes: bytes, 
  );

  if (outputFile != null) {
    await File(outputFile).writeAsBytes(bytes);
  }
}
*/

Future<void> importProject(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result == null || result.files.single.path == null) return;

  try {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    Map<String, dynamic> importPayload = jsonDecode(content);

    String? projectToken = importPayload['project_token'];
    Map<String, dynamic> projectData = importPayload['project'] ?? {};
    String projectName = projectData['name'] ?? 'Импортированный проект';
    
    final dbClient = await db.database;
    int targetProjectId;
    bool isExist = false;

    // 1. Проверяем, импортировался ли этот проект ранее по токену
    if (projectToken != null) {
      final List<Map<String, dynamic>> existingSync = await dbClient.query(
        'sync_tasks',
        where: 'sync_token = ?',
        whereArgs: [projectToken],
      );

      if (existingSync.isNotEmpty) {
        // Проект уже существует! Получаем его локальный ID
        targetProjectId = existingSync.first['project_id'] as int;
        isExist = true;
        
        // Очищаем старые задачи этого проекта, чтобы избежать дублирования строк
        await dbClient.delete(
          'tasks',
          where: 'project_id = ?',
          whereArgs: [targetProjectId],
        );
        
        // Обновляем имя проекта на случай, если оно изменилось в файле
        await db.updateProjectTitle(targetProjectId, projectName);
      } else {
        // Проекта с таким токеном нет, создаем новый
        targetProjectId = await db.createProject(projectName);
        // Регистрируем его токен в таблице синхронизации
        await dbClient.insert('sync_tasks', {
          'project_id': targetProjectId,
          'sync_token': projectToken,
        });
      }
    } else {
      // Если файл старый или без токена, просто создаем новый проект
      targetProjectId = await db.createProject(projectName);
    }

    // 2. Записываем задачи (id конфликтов не будет, они генерируются заново)
    List<dynamic> tasksData = importPayload['tasks'] ?? [];
    for (var item in tasksData) {
      Map<String, dynamic> taskMap = Map<String, dynamic>.from(item);
      taskMap.remove('id'); 
      taskMap['project_id'] = targetProjectId; 

      await db.insertTask(taskMap);
    }
    
    loadProjects(); 

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isExist 
            ? 'Данные проекта "$projectName" успешно обновлены!' 
            : 'Проект "$projectName" успешно импортирован!'),
          backgroundColor: const Color(0xFF1E68F6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка импорта: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}




  Future<void> addProject(String name) async {
    await db.createProject(name);
    await loadProjects();
  }

  Future<void> delete(int id) async {
    await db.deleteTask(id);
    await load();
  }

  Future<void> deleteProject(int id) async {
    debugPrint("=== ПОПЫТКА ЭКСПОРТА ПРОЕКТА С ID: $id ===");
    await db.deleteProject(id);
    await loadProjects();
  }

  Future<void> move(int id, TaskStatus status) async {
    await db.updateTaskStatus(id, status.index);
    await load();
  }
}