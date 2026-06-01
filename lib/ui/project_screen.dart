import 'package:flutter/material.dart';
import 'package:task_minimal/ui/task_column.dart';
import '../controllers/task_controller.dart';
import '../database_helper.dart';
import '../models/task.dart';

class ProjectScreen extends StatefulWidget {
  final int projectID;

  const ProjectScreen({
    super.key,
    required this.projectID,
    });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late final TaskController controller;
  final TextEditingController input = TextEditingController();

  bool get isMobile => MediaQuery.of(context).size.width < 900;

  @override
  void initState() {
    super.initState();
    controller = TaskController(DatabaseHelper.instance)
      ..projectID = widget.projectID
      ..load();
  }

  @override
void didUpdateWidget(covariant ProjectScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.projectID != oldWidget.projectID) {
    controller.projectID = widget.projectID;
    controller.load(); // Перезагружаем данные при смене ID
  }
}

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return isMobile ? _mobile() : _desktop();
      },
    );
  }

  Widget _desktop() {
    return Scaffold(
      appBar: AppBar(title: const Text('Base Project'), backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: TaskStatus.values.map((status) {
            return Expanded(
              child: TaskColumn(
                status: status,
                tasks: controller.byStatus(status),
                onMove: controller.move,
                onDelete: controller.delete,
                onUpdate: controller.updateTask,
                draggable: true,
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _fab(),
    );
  }

  Widget _mobile() {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: const Color(0xFFFBFCFE), // Мягкий фоновый оттенок экрана из макета
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Исключает появление дефолтных серых теней при скролле
        toolbarHeight: 64, // Оптимальная высота под изящную шапку
        titleSpacing: 0,
        
        // 1. ИКОНКА НАЗАД (Изящный контур 1.2px)
        leading: Center(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded, 
              color: Color(0xFF0F141C), 
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
        // 2. УТОНЧЕННЫЙ ЗАГОЛОВОК ПРОЕКТА (Medium 15px, графитовый оттенок)
        title: const Text(
          'Задачи'
        ,
          style: TextStyle(
            fontFamily: '.SF Pro Text', // Системный шрифт iOS/Android
            fontSize: 18,
            fontWeight: FontWeight.w600, // Medium вместо тяжелого Bold
            color: Color(0xFF1E293B), // Глубокий мягкий графит slate-800
            letterSpacing: -0.3,
          ),
        ),
        
        // 3. СОВРЕМЕННАЯ ИКОНКА СЛАЙДЕРОВ-ФИЛЬТРОВ
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0), // Выравнивание правого края строго 24px от границы экрана
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              icon: const Icon(
                Icons.tune_rounded, // Технологичные b2b ползунки вместо старой пирамидки
                color: Color(0xFF0F141C),
                size: 22,
              ),
              onSelected: (String result) {
                // Логика фильтрации
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'date', child: Text('Date')),
                const PopupMenuItem<String>(value: 'low', child: Text('Low')),
                const PopupMenuItem<String>(value: 'hight', child: Text('High')),
              ],
            ),
          ),
        ],
        
        // 4. ТАБ-БАР (Эстетика Linear без кричащего капса, высота 32px)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E8F0), // Тончайшая серая подложка из макета
                  width: 0.5,
                ),
              ),
            ),
            child: const TabBar(
              dividerColor: Colors.transparent, // Отключаем дефолтный разделитель Flutter
              indicatorColor: Color(0xFF2563EB), // Фирменный синий кобальт
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label, // Полоска стягивается строго под размер текста To Do
              labelColor: Color(0xFF2563EB),
              unselectedLabelColor: Color(0xFF94A3B8), // Приглушенный Slate-серый
              labelStyle: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w600, // Semibold для активного таба
                letterSpacing: -0.1,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w500, // Medium для неактивных
                letterSpacing: -0.1,
              ),
              tabs: [
                Tab(text: 'To Do'),
                Tab(text: 'In Progress'),
                Tab(text: 'Done'),
              ],
            ),
          ),
        ),
      ),
      
      // Контент списков задач
      body: TabBarView(
        children: TaskStatus.values.map((status) {
          return TaskColumn(
            status: status,
            tasks: controller.byStatus(status),
            onMove: controller.move,
            onDelete: controller.delete,
            onUpdate: controller.updateTask,
            draggable: false,
          );
        }).toList(),
      ),
      
      // ====== ПРАВИЛЬНОЕ ЦЕНТРИРОВАНИЕ НАШЕЙ СИНЕЙ КАПСУЛЫ ======
      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Выравнивает капсулу строго по центру нижней трети экрана
    ),
  );
}



      Widget _fab() {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Новая задача',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F141C),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: input,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Название задачи...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        input.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Отмена', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (input.text.isNotEmpty) {
                          controller.add(input.text);
                          input.clear();
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Создать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    child: Container(
      width: 300, // Строгая ширина по сетке из макета
      height: 50, // Изящная b2b высота
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // Фирменный кобальт
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2), // Мягкая неоновая тень fabShadow
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Быстрый календарь
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
          ),
          // Тонкий вертикальный разделитель
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Container(width: 0.75, color: Colors.white.withOpacity(0.3)),
          ),
          
          // 2. Иконка плюс и текст
          const Icon(Icons.add_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          const Text(
            'Новая задача',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          
          const Spacer(),
          
          // 3. Круглый маркер приоритета
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
          ),
          // Второй вертикальный разделитель
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Container(width: 0.75, color: Colors.white.withOpacity(0.3)),
          ),
          
          // 4. Окошко хоткея 'N'
          Padding(
            padding: const EdgeInsets.only(right: 11),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8), // Тонированный синий внутри
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF93C5FD),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
