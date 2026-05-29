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
      final cleanIp = ipAddress.replaceAll('http://', '').replaceAll('/sync', '').trim();
      final request = await client.getUrl(Uri.parse('http://$cleanIp/sync'));
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        onLog("Ошибка сервера: статус ${response.statusCode}");
        return false;
      }

      final content = await response.transform(utf8.decoder).join();

// КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Очищаем JSON-строку от скрытых символов, пробелов и BOM-байтов PHP
final cleanContent = content.trim().replaceAll(RegExp(r'^\uFEFF'), '');

// Декодируем очищенную строку
Map<String, dynamic> importPayload = jsonDecode(cleanContent);
     // Map<String, dynamic> importPayload = jsonDecode(content);

      List<dynamic> incomingProjects = importPayload['projects'] ?? [];
      List<dynamic> incomingTasks = importPayload['tasks'] ?? [];

      final dbClient = await db.database;

      // Запускаем транзакцию для всей базы сразу
      await dbClient.transaction((txn) async {
        // Карта для связи старых ID проектов (из файла) со свежими локальными ID (в этой БД)
        Map<int, int> projectIdMapping = {};

        // 1. СИНХРОНИЗИРУЕМ ВСЕ ПРОЕКТЫ
        for (var projItem in incomingProjects) {
          Map<String, dynamic> projectMap = Map<String, dynamic>.from(projItem);
          int oldProjectId = projectMap['id'] as int;
          String projectToken = projectMap['project_token'] as String;
          String projectName = projectMap['name'] ?? 'Проект';

          // Ищем, есть ли уже этот проект по токену
          final List<Map<String, dynamic>> existingSync = await txn.query(
            'sync_tasks',
            where: 'sync_token = ?',
            whereArgs: [projectToken],
          );

          int targetProjectId;

          if (existingSync.isNotEmpty) {
            // Проект уже существует, обновляем его
            targetProjectId = existingSync.first['project_id'] as int;
            await txn.update(
              'projects',
              {'name': projectName, 'update_at': DateTime.now().toIso8601String()},
              where: 'id = ?',
              whereArgs: [targetProjectId],
            );
            // Чистим его старые задачи перед записью новых
            await txn.delete('tasks', where: 'project_id = ?', whereArgs: [targetProjectId]);
          } else {
            // Проекта нет, создаем с нуля
            targetProjectId = await txn.insert('projects', {
              'name': projectName,
              'created_at': projectMap['created_at'] ?? DateTime.now().toIso8601String(),
              'update_at': DateTime.now().toIso8601String(),
            });

            // Фиксируем связь токена
            await txn.insert('sync_tasks', {
              'project_id': targetProjectId,
              'sync_token': projectToken,
            });
          }

          // Запоминаем, какой старый ID превратился в какой новый локальный ID
          projectIdMapping[oldProjectId] = targetProjectId;
        }

        // 2. СИНХРОНИЗИРУЕМ ВСЕ ЗАДАЧИ
        for (var taskItem in incomingTasks) {
          Map<String, dynamic> taskMap = Map<String, dynamic>.from(taskItem);
          int oldProjectIDForTask = taskMap['project_id'] as int;

          // Проверяем, пришел ли вместе с базой проект для этой задачи
          if (projectIdMapping.containsKey(oldProjectIDForTask)) {
            taskMap.remove('id'); // Стираем глобальный ID задачи
            taskMap['project_id'] = projectIdMapping[oldProjectIDForTask]; // Ставим правильный локальный ID проекта

            await txn.insert(
              'tasks',
              taskMap,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });

      onLog("Полная синхронизация базы завершена успешно!");
      return true;

    } catch (e) {
      onLog("Ошибка полной синхронизации: $e");
      return false;
    } child: {
      client.close();
    }
  }

   // --- НОВЫЙ УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ОТПРАВКИ (POST) ---
  Future<bool> sendDataToRemoteNode(String ipAddress, Function(String log) onLog) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      onLog("Подготовка данных для отправки...");
      final dbClient = await db.database;

      // 1. Собираем все проекты и задачи из локальной БД
      final allProjects = await db.readAllProjects();
      final allTasks = await db.readAllTasks();
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

      // 2. Формируем чистый URL для POST запроса к PHP
      String cleanUrl = ipAddress.replaceAll('http://', '').trim();
      if (!cleanUrl.contains('.php') && !cleanUrl.contains(':')) {
        cleanUrl = "$cleanUrl:8080/sync"; // Если это не PHP, шлем на стандартный Dart-сервер
      }

      onLog("Отправка данных на $cleanUrl...");
      final request = await client.postUrl(Uri.parse('http://$cleanUrl'));
      
      // Настраиваем заголовки
      request.headers.contentType = ContentType.json;
      
      // Пишем тело запроса и закрываем отправку
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

