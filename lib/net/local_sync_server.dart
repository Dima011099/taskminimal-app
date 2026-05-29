import 'dart:io';
import 'dart:convert';

import 'package:task_minimal/database_helper.dart';

class LocalSyncServer {
  HttpServer? _server;
  final db = DatabaseHelper.instance;

  Future<void> startServer(Function(String log) onLog) async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      final wifiIp = interfaces.first.addresses.first.address;

      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      onLog("Сервер запущен! Подключитесь к: http://$wifiIp:8080");

      await for (HttpRequest request in _server!) {
        if (request.uri.path == '/sync') {
          final dbClient = await db.database;

          // 1. Получаем абсолютно все проекты и все задачи из вашей БД
          final allProjects = await db.readAllProjects();
          final allTasks = await db.readAllTasks();

          // 2. Формируем карту токенов для каждого проекта, чтобы избежать дубликатов
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
              await dbClient.insert('sync_tasks', {
                'project_id': projectId,
                'sync_token': projectToken,
              });
            } else {
              projectToken = syncRecords.first['sync_token'] as String;
            }

            // Создаем копию данных проекта и подмешиваем туда его глобальный токен
            final projectMap = Map<String, dynamic>.from(project);
            projectMap['project_token'] = projectToken;
            projectsWithTokens.add(projectMap);
          }

          // 3. Формируем единый глобальный payload всей базы данных
          final payload = {
            "export_version": "2.0",
            "exported_at": DateTime.now().toIso8601String(),
            "projects": projectsWithTokens, // Список всех проектов с их токенами
            "tasks": allTasks,             // Список вообще всех задач
          };

          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode(payload))
            ..close();
            
          onLog("Вся база данных успешно передана по Wi-Fi!");
        } else {
          request.response..statusCode = HttpStatus.notFound..close();
        }
      }
    } catch (e) {
      onLog("Ошибка сервера: $e");
    }
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
  }
}