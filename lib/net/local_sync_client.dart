import 'dart:io';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:task_minimal/database_helper.dart';

class LocalSyncClient {
  final db = DatabaseHelper.instance;

Future<bool> syncFromWifi(String ipAddress, Function(String log) onLog) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      onLog("Подключение к $ipAddress...");
      
      final cleanUrl = ipAddress.replaceAll('http://', '').trim();
      
      Uri targetUri;
      if (cleanUrl.contains('/') || cleanUrl.contains('.php')) {
        targetUri = Uri.parse('http://$cleanUrl');
      } else {
        targetUri = Uri.parse('http://$cleanUrl/sync');
      }

      final request = await client.getUrl(targetUri);
      
      request.headers.add(HttpHeaders.cacheControlHeader, "no-cache, no-store, must-revalidate");
      request.headers.add(HttpHeaders.pragmaHeader, "no-cache");
      request.headers.add(HttpHeaders.expiresHeader, "0");

      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        onLog("Ошибка сервера: статус ${response.statusCode}");
        return false;
      }

      final content = await response.transform(utf8.decoder).join();
      final cleanContent = content.trim().replaceAll(RegExp(r'^\uFEFF'), '');
      Map<String, dynamic> importPayload = jsonDecode(cleanContent);

      List<dynamic> incomingProjects = importPayload['projects'] ?? [];
      List<dynamic> incomingTasks = importPayload['tasks'] ?? [];

      final dbClient = await db.database;

      await dbClient.transaction((txn) async {
        // Карта для сопоставления: КЛЮЧ = серверный (старый) id проекта, ЗНАЧЕНИЕ = локальный id проекта на этом устройстве
        Map<int, int> projectIdMapping = {};

        // 1. СИНХРОНИЗАЦИРУЕМ ВСЕ ПРОЕКТЫ
        for (var projItem in incomingProjects) {
          Map<String, dynamic> projectMap = Map<String, dynamic>.from(projItem);
          int oldProjectId = projectMap['id'] as int;
          String projectToken = projectMap['project_token'] as String;
          String projectName = projectMap['name'] ?? 'Проект';
          
          int incomingIsDeleted = int.tryParse(projectMap['is_deleted'].toString()) ?? 0;

          final List<Map<String, dynamic>> existingSync = await txn.query(
            'sync_tasks',
            where: 'sync_token = ?',
            whereArgs: [projectToken],
          );

          int targetProjectId;

if (existingSync.isNotEmpty) {
  targetProjectId = existingSync.first['project_id'] as int;
  
  // 1. Получаем текущую локальную версию проекта из базы телефона
  final List<Map<String, dynamic>> localProjectRecord = await txn.query(
    'projects',
    where: 'id = ?',
    whereArgs: [targetProjectId],
  );

  if (localProjectRecord.isNotEmpty) {
    DateTime localUpdate = DateTime.parse(localProjectRecord.first['update_at'] as String);
    DateTime incomingUpdate = DateTime.parse(projectMap['update_at'] ?? DateTime.now().toIso8601String());

    // ИСПРАВЛЕНИЕ: Обновляем проект только если пришедшие данные из сети СВЕЖЕЕ локальных
    if (incomingUpdate.isAfter(localUpdate)) {
      await txn.update(
        'projects',
        {
          'name': projectName, 
          'is_deleted': incomingIsDeleted, 
          'update_at': projectMap['update_at']
        },
        where: 'id = ?',
        whereArgs: [targetProjectId],
      );

      // Если проект удален на сервере — гасим задачи
      if (incomingIsDeleted == 1) {
        await txn.update(
          'tasks',
          {'is_deleted': 1, 'update_at': DateTime.now().toIso8601String()},
          where: 'project_id = ?',
          whereArgs: [targetProjectId],
        );
      }}}
    }else {
            // Создание нового проекта, если его не было в sync_tasks
            targetProjectId = await txn.insert('projects', {
              'name': projectName,
              'is_deleted': incomingIsDeleted, 
              'created_at': projectMap['created_at'] ?? DateTime.now().toIso8601String(),
              'update_at': projectMap['update_at'] ?? DateTime.now().toIso8601String(),
            });

            await txn.insert('sync_tasks', {
              'project_id': targetProjectId,
              'sync_token': projectToken,
            });
          }

          projectIdMapping[oldProjectId] = targetProjectId;
        }

        // 2. УМНОЕ СЛИЯНИЕ ЗАДАЧ ПО ВРЕМЕНИ
        for (var taskItem in incomingTasks) {
          Map<String, dynamic> taskMap = Map<String, dynamic>.from(taskItem);
          int oldProjectIDForTask = taskMap['project_id'] as int;
          String taskToken = taskMap['task_token'] as String;

          if (projectIdMapping.containsKey(oldProjectIDForTask)) {
            taskMap['project_id'] = projectIdMapping[oldProjectIDForTask];
            final int targetProjectId = taskMap['project_id'];

            // Ищем задачу локально по её постоянному уникальному токену
            final List<Map<String, dynamic>> localTaskRecord = await txn.query(
              'tasks',
              where: 'task_token = ? AND project_id = ?',
              whereArgs: [taskToken, targetProjectId],
            );

            if (localTaskRecord.isEmpty) {
              // Задачи нет — вставляем чистую запись без поля 'id' (чтобы sqflite присвоил свой автоинкремент)
              taskMap.remove('id'); 
              await txn.insert('tasks', taskMap);
            } else {
              // Задача есть — теперь сравнение дат будет работать железно!
              DateTime localUpdate = DateTime.parse(localTaskRecord.first['update_at'] as String);
              DateTime incomingUpdate = DateTime.parse(taskMap['update_at'] as String);

              if (incomingUpdate.isAfter(localUpdate)) {
                int localTaskId = localTaskRecord.first['id'] as int;
                taskMap.remove('id'); 
                
                await txn.update(
                  'tasks',
                  taskMap,
                  where: 'id = ?',
                  whereArgs: [localTaskId],
                );
              }
              // Если локальные данные новее, входящие просто игнорируются
            }
          }
        }
      });

      onLog("Синхронизация успешно завершена!");
      return true;

    } catch (e) {
      onLog("Критическая ошибка синхронизации: $e");
      return false;
    }
}


  // --- МЕТОД ДЛЯ ОТПРАВКИ (POST) ---
  Future<bool> sendDataToRemoteNode(String ipAddress, Function(String log) onLog) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      onLog("Подготовка данных для отправки...");
      final dbClient = await db.database;

      final allProjects = await db.readAllProjectsWithDelete();
      final allTasks = await db.readAllTasksWithDelete();
      List<Map<String, dynamic>> projectsWithTokens = [];
      
      for (var project in allProjects) {
        final int projectId = project['id'] as int;
        final List<Map<String, dynamic>> syncRecords = await dbClient.query(
          'sync_tasks', 
          where: 'project_id = ?', 
          whereArgs: [projectId]
        );
        
        String projectToken;
        if (syncRecords.isEmpty) {
          projectToken = 'token_${projectId}_${DateTime.now().microsecondsSinceEpoch}';
          await dbClient.insert('sync_tasks', {'project_id': projectId, 'sync_token': projectToken});
        } else {
          projectToken = syncRecords.first['sync_token'] as String;
        }

        final projectMap = Map<String, dynamic>.from(project);
        projectMap['project_token'] = projectToken;
        projectsWithTokens.add(projectMap);
      }

      final payload = {
        "export_version": "2.0",
        "projects": projectsWithTokens,
        "tasks": allTasks,
      };

      final cleanUrl = ipAddress.replaceAll('http://', '').trim();
      
      // Точно такой же умный разбор URL для POST запроса
      Uri targetUri;
      if (cleanUrl.contains('/') || cleanUrl.contains('.php')) {
        targetUri = Uri.parse('http://$cleanUrl');
      } else {
        targetUri = Uri.parse('http://$cleanUrl/sync');
      }

      onLog("Отправка данных на $targetUri...");
      final request = await client.postUrl(targetUri);
      
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        onLog("Данные успешно синхронизированы с сервером!");
        return true;
      } else {
        onLog("Сервер вернул ошибку: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      onLog("Ошибка отправки: $e");
      return false;
    } finally {
      client.close();
    }
  }
}
