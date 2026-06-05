/*import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:task_minimal/ui/adaptive_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация sqflite для десктопа
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  } else {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const TaskMininal());
}

class TaskMininal extends StatelessWidget {
  const TaskMininal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      home: const AdaptiveMainScreen(),
    );
  }
}
*/
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 1. Инициализируем саму БД (код инициализации sqflite ffi из первого шага)
  final dbHelper = DatabaseHelper.instance; // Если у вас есть явный метод async инициализации
  await dbHelper.database; 
  // 2. Создаем файловый сервис и передаем ему БД
  final fileService = ProjectFileService(dbHelper);

  final taskController = TaskController(dbHelper, fileService);
  //await taskController.loadProjects(); 

  runApp(
    // Передаем уже полностью готовый, «живой» контроллер через .value
    ChangeNotifierProvider<TaskController>.value(
      value: taskController,
      child: const TaskMinimal(),
    ),
  );
}

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