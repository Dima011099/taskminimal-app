import 'package:flutter/material.dart';
import 'package:task_minimal/models/task.dart';

class TaskCardView extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final Function(int, String) onUpdate;

  final TextEditingController input = TextEditingController();

  TaskCardView({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Убрали лишний белый фон, карточки лежат на общем холсте
      padding: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 14), // Четкие отступы 24px по сетке
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Позволяет троеточию стоять ровно на верхней линии
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ====== 1. ГЛАВНЫЙ ЗАГОЛОВОК ЗАДАЧИ (НАВЕРХУ) ======
                    Text(
                      task.title,
                      maxLines: 2, // Элегантный перенос, если заголовок слишком длинный
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w500, // Чистый Medium без перегрузки
                        color: Color(0xFF0F141C), // Фирменный глубокий антрацит
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 8), // Идеальный отступ до мета-строки

                    // ====== 2. НИЖНЯЯ СТРОКА МЕТА-ДАННЫХ ======
                    Row(
                      children: [
                        // Мягкий бейдж приоритета
                        _priority(task.priority),
                        const SizedBox(width: 8),
                        
                        // Лаконичная точка-разделитель из твоего SVG
                        const Text(
                          '·',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Дата дедлайна (Вместо тяжелой рамки календаря)
                        Text(
                          // Сюда можно прокинуть реальную дату из модели, пока оставим твою:
                          "24 Jan.",
                          style: const TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B), // Slate 500
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Статус задачи в конце строки
                        _status(task.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ====== 3. КНОПКА ОПЦИЙ (АККУРАТНОЕ СТРУКТУРНОЕ ТРОЕТОЧИЕ) ======
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                icon: const Icon(
                  Icons.more_vert_rounded, // Скругленное изящное троеточие
                  size: 20, 
                  color: Color(0xFF94A3B8), // Серый Slate 400
                ),
                onSelected: (String result) {
                  switch(result) {
                    case 'edit':
                      input.text = task.title;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Edit Task'),
                          content: TextField(controller: input, autofocus: true),
                          actions: [
                            TextButton(onPressed: Navigator.of(context).pop, child: const Text('Отмена')),
                            ElevatedButton(
                              onPressed: () {
                                onUpdate(task.id, input.text);       
                                input.clear();
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // ====== 4. ТНЧАЙШИЙ СИСТЕМНЫЙ РАЗДЕЛИТЕЛЬ ======
          const Divider(
            height: 1,
            thickness: 0.75, // Изящная толщина из твоего финального макета
            color: Color(0xFFE2E8F0), // Чистый Slate 200
          ),
        ],
      ),
    );
  }

  // Обновленный бейдж приоритета в едином b2b-стиле
  Widget _priority(int priority) {
    final bool isHigh = priority > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // Мягкие пастельные подложки без вырвиглазных цветов
        color: isHigh ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9), 
        borderRadius: BorderRadius.circular(8), // Мягкие скругленные углы rx=8
      ),
      child: Text(
        isHigh ? "High" : "Low", // Ушли от кричащего Caps Lock
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          color: isHigh ? const Color(0xFFDC2626) : const Color(0xFF475569), // Строгие контрастные тексты
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Обновленный статус задачи в Title Case
  Widget _status(TaskStatus status) {
    const labels = {
      TaskStatus.todo: "To Do",
      TaskStatus.inProgress: "In Progress",
      TaskStatus.done: "Done",
    };

    return Text(
      labels[status]!,
      style: const TextStyle(
        fontFamily: '.SF Pro Text',
        color: Color(0xFF94A3B8), // Мягкий Slate 400 для всех статусов, так как активный таб уже подсвечен в AppBar
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:task_minimal/models/task.dart';

class TaskCardView extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  //final VoidCallback onUpdate;
  final Function(int, String) onUpdate;

  final TextEditingController input = TextEditingController();

  TaskCardView({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Text(
                "TASK-${task.id}",
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monospace',
                ),
              ),
              const SizedBox(width: 12),
              _priority(task.priority),
              const Spacer(),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Color.from(red: 0.3, blue: 0.1, green: 0.15, alpha: .5)), // Иконка фильтра
                  onSelected: (String result) {
                    switch(result){
                      case 'edit':
                        input.text = task.title;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                          title: const Text('Edit Task'),
                          content: TextField(controller: input, autofocus: true),
                          actions: [
                            TextButton(onPressed: Navigator.of(context).pop, child: const Text('Отмена')),
                            ElevatedButton(
                            onPressed: () {
                            onUpdate(task.id, input.text);       
                            input.clear();
                            Navigator.pop(context);
                            },
                          child: const Text('Save'),
                        ),
                        ],
                      ),
                  );
                      break;
                      case 'delete':
                        onDelete();
                      break;
                    }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
              ],
            ),
            ],
          ),

          const SizedBox(height: 8),

          /// TITLE
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 12),

          /// FOOTER
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black45),
              const SizedBox(width: 4),
              const Text("24 Jan.", style: TextStyle(fontSize: 12, color: Colors.black45)),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 9,
                backgroundColor: Colors.blueGrey.shade100,
                child: const Text("A", style: TextStyle(fontSize: 9, color: Colors.white)),
              ),
              const Spacer(),
              _status(task.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priority(int priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priority > 0
            ? Colors.red.shade300
            : Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority > 0 ? "HIGH" : "LOW",
        style: TextStyle(
          color: priority > 0 ? Colors.red : Colors.black45,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _status(TaskStatus status) {
    const labels = {
      TaskStatus.todo: "TO DO",
      TaskStatus.inProgress: "IN PROGRESS",
      TaskStatus.done: "DONE",
    };

    final color = switch (status) {
      TaskStatus.todo => Colors.grey,
      TaskStatus.inProgress => Colors.blue,
      TaskStatus.done => Colors.green,
    };

    return Text(
      labels[status]!,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}*/