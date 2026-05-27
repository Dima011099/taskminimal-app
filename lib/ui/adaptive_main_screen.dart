import 'package:flutter/material.dart';
import 'package:task_minimal/controllers/task_controller.dart';
import 'package:task_minimal/models/task.dart';
import 'package:task_minimal/ui/project_screen.dart';
import 'package:task_minimal/ui/widgets/empty_task_widget.dart';
import 'package:task_minimal/ui/widgets/minimal_tab_bar.dart';
import 'package:task_minimal/ui/widgets/project_list.dart';

import '../database_helper.dart';

class AdaptiveMainScreen extends StatefulWidget {
  const AdaptiveMainScreen({super.key});

  @override
  State<AdaptiveMainScreen> createState() => _AdaptiveMainScreenState();
}

class _AdaptiveMainScreenState extends State<AdaptiveMainScreen> {
  Project? _selectedProject;

   final TextEditingController input = TextEditingController();

  late final TaskController controller;

  bool get isMobile => MediaQuery.of(context).size.width < 900;

    @override
  void initState() {
    super.initState();
    controller = TaskController(DatabaseHelper.instance)..loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 72,
        actionsPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title:       Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0), // Отступ 24px строго по вашей сетке
    child: Row(
      children: [
        // ====== ТОТ САМЫЙ МИНИ-ЛОГОТИП ======
        SizedBox(
          width: 30,
          height: 26,
          child: Stack(
            children: [
              // Первый кубик (slateBase — антрацит)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 13,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141C),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Второй кубик (brandBlue — синий)
              Positioned(
                left: 16,
                top: 0,
                child: Container(
                  width: 13,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Третий кубик (вертикальный антрацит)
              Positioned(
                left: 12,
                top: 9,
                child: Container(
                  width: 5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141C),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6), // Идеальный отступ между логотипом и текстом (6px из SVG)
        
        // ====== ОБНОВЛЕННЫЙ ТЕКСТ ======
        const Text(
          'Minimal',
          style: TextStyle(
            fontFamily: '.SF Pro Text', // Системный шрифт Apple
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F141C), // Фирменный глубокий антрацит
            letterSpacing: -0.5, // Отрицательный трекинг из вашей дизайн-системы
          ),
        ),
      ],
    ),
  ),
        backgroundColor: Colors.white,
         actions: [
   

   IconButton(
    icon: const Icon(Icons.settings),
    onPressed: () {
    },
  ),
],
      
        ),
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, constraints) {
          if (!isMobile) {
            // ДЕСКТОП: 2 или 3 колонки
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: ProjectList(onProjectSelected: (p) => setState(() => _selectedProject = p), controller: controller, 
                  onProjectDeleted: (deletedId) {
                    if (_selectedProject?.id == deletedId) {
                      setState(() => _selectedProject = null);
                    }
                  },
                  onProjectUpdate: controller.updateProject,
                  onExport: controller.exportJson,               
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _selectedProject != null
                      ? ProjectScreen(projectID: _selectedProject!.id,) //TaskView(project: _selectedProject!)
                      : const Center(child: EmptyTasksWidget()),
                ),
              ],
            );
          } else {
            // МОБИЛЬНЫЕ: Список с переходом
            return ProjectList(controller: controller,
            onProjectDeleted:  (deletedId) {
                    if (_selectedProject?.id == deletedId) {
                      setState(() => _selectedProject = null);
                    }
                  },                
              onProjectSelected: (p) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                  ProjectScreen(projectID: p.id,)
                  )  
                );
              },
              onProjectUpdate: controller.updateProject,
              onExport: controller.exportJson,
            );
          }
        },
      ),
        bottomNavigationBar: new MinimalTabBar(
    onProfilePressed: () => print("Профиль нажат"),
    onFolderPressed: () => print("Папка нажата"),
    onSyncPressed: () => print("Синхронизация"),
    onExportPressed: () => controller.importAsNewProject('Import Project'),
    onAddPressed: () => _addProject(),
  ),
    );
  }

  Future _addProject(){
    return showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Create a new project'),
            content: TextField(controller: input, autofocus: true),
            actions: [
              TextButton(onPressed: Navigator.of(context).pop, child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () {
                  controller.addProject(input.text);
                  input.clear();
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
  }

  
}