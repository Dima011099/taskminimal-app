import 'dart:io';
import 'dart:convert';

import 'package:task_minimal/database_helper.dart';

class LocalSyncServer {
  HttpServer? _server;
  final db = DatabaseHelper.instance;

  Future<void> startServer(Function(String log) onLog) async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      
      // Безопасный поиск IP: если Wi-Fi не подключен, предотвращаем краш
      if (interfaces.isEmpty || interfaces.first.addresses.isEmpty) {
        onLog("Ошибка: Устройство не подключено к Wi-Fi сети");
        return;
      }
      final wifiIp = interfaces.first.addresses.first.address;

      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      onLog("Сервер запущен! Подключитесь к: http://$wifiIp:8080");

      await for (HttpRequest request in _server!) {
        final path = request.uri.path;

        // ИСПРАВЛЕНИЕ 1: Сервер теперь одинаково успешно принимает и /sync, и /sync.php
        if (path == '/sync' || path == '/sync.php') {
          final dbClient = await db.database;

          // 1. Получаем абсолютно все проекты и все задачи из вашей БД
          final allProjects = await db.readAllProjectsWithDelete();
          final allTasks = await db.readAllTasksWithDelete();

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
              // Генерация токена. Если подключен пакет uuid, лучше использовать const Uuid().v4()
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
            "projects": projectsWithTokens,
            "tasks": allTasks,
          };

          // ИСПРАВЛЕНИЕ 2: Явно отключаем кэширование и закрываем соединение на уровне протокола
          request.response.headers
            ..contentType = ContentType.json
            ..add(HttpHeaders.cacheControlHeader, "no-cache, no-store, must-revalidate")
            ..add(HttpHeaders.pragmaHeader, "no-cache")
            ..add(HttpHeaders.connectionHeader, "close");

          request.response.write(jsonEncode(payload));
          await request.response.close();
            
          onLog("Вся база данных успешно передана по Wi-Fi!");
        } else {
          // Если постучались на левый роут
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      }
    } catch (e) {
      onLog("Ошибка сервера: $e");
    }
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }
}