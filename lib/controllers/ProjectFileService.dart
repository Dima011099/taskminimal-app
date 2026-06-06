import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'dart:io';

import 'package:task_minimal/database_helper.dart';


/// A service responsible for exporting and importing project data 
/// via JSON files using system file pickers.
class ProjectFileService {
  final DatabaseHelper _db;

  ProjectFileService(this._db);

  /// Exports a project and its associated tasks into a single JSON file.
  /// 
  /// Generates a backup payload containing metadata, project details, 
  /// and a synchronization token managed by [DatabaseHelper].
  Future<void> exportProject(int id) async {
    final projectData = await _db.readProjectWhereID(id);
    if (projectData == null) return;

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

    // Opens a system dialog to let the user choose the destination path.
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

  /// Imports a project from a user-selected JSON file.
  /// 
  /// Decodes the backup payload, extracts the project metadata, 
  /// and delegates the SQL insertion logic to [DatabaseHelper].
  /// 
  /// Returns the imported project's name, or `null` if the operation was canceled.
  Future<String?> importProject() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    // Early return if the file picker dialog was canceled or intercepted.
    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final Map<String, dynamic> importPayload = jsonDecode(content);

    final String? projectToken = importPayload['project_token'];
    final Map<String, dynamic> projectData = importPayload['project'] ?? {};
    final String projectName = projectData['name'] ?? 'Импортированный проект';

    await _db.importProjectData(
      token: projectToken,
      name: projectName,
      tasks: List<Map<String, dynamic>>.from(importPayload['tasks'] ?? []),
    );

    return projectName;
  }
}