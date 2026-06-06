import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:task_minimal/controllers/ProjectFileService.dart';
import 'package:task_minimal/database_helper.dart';
import 'package:task_minimal/controllers/task_controller.dart';
import 'package:task_minimal/ui/adaptive_main_screen.dart';

/// The entry point of the application.
/// 
/// Handles platform-specific database initializations and sets up 
/// the core dependency injection container before launching the UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configures FFI factories required for sqflite on desktop and web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final dbHelper = DatabaseHelper.instance; 
  await dbHelper.database; 

  final fileService = ProjectFileService(dbHelper);
  final taskController = TaskController(dbHelper, fileService);

  runApp(
    ChangeNotifierProvider<TaskController>.value(
      value: taskController,
      child: const TaskMinimal(),
    ),
  );
}

/// The root widget of the Task Minimal application.
/// 
/// Configures global material settings and displays the adaptive main layout.
class TaskMinimal extends StatelessWidget {
  const TaskMinimal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdaptiveMainScreen(),
    );
  }
}