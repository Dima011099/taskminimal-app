import 'package:flutter/material.dart';
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
