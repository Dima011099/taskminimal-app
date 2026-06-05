import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'dart:io';

import 'package:task_minimal/database_helper.dart';

class ProjectFileService {
  final DatabaseHelper _db;

  ProjectFileService(this._db);

  Future<void> exportProject(int id) async {
    final projectData = await _db.readProjectWhereID(id);
    if (projectData == null) return;

    // Вся работа с токенами уходит в DatabaseHelper
    final String projectToken = await _db.getOrCreateSyncToken(id);
    final tasksData = await _db.readAllTasksWhereProjectID(id);

    final Map<String, dynamic> exportPayload = {
      "export_version": "1.0",
      "project_token": projectToken,
      "project": {
        "name": projectData['name'],
        "created_at": projectData['created_at'],
        "update_at": projectData['update_at'],
      },
      "tasks": tasksData,
    };

    final bytes = utf8.encode(jsonEncode(exportPayload));

    final outputFile = await FilePicker.platform.saveFile(
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

  Future<String?> importProject() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final Map<String, dynamic> importPayload = jsonDecode(content);

    final String? projectToken = importPayload['project_token'];
    final Map<String, dynamic> projectData = importPayload['project'] ?? {};
    final String projectName = projectData['name'] ?? 'Импортированный проект';

    // Делегируем сложную SQL-логику импорта в DatabaseHelper
    await _db.importProjectData(
      token: projectToken,
      name: projectName,
      tasks: List<Map<String, dynamic>>.from(importPayload['tasks'] ?? []),
    );

    return projectName;
  }
}