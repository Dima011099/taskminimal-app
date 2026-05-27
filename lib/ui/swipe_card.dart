import 'package:flutter/material.dart';
import 'package:task_minimal/models/task.dart';
// Импортируем нашу обновленную карточку (TaskCardView)
import 'package:task_minimal/ui/widgets/ui_card.dart'; 

class SwipeCard extends StatelessWidget {
  final Task task;
  final void Function(int, TaskStatus) onMove;
  final void Function(int) onDelete;
  final Function(int, String) onUpdate;

  const SwipeCard({
    super.key,
    required this.task,
    required this.onMove,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final card = TaskCardView(
      task: task,
      onDelete: () => onDelete(task.id),
      onUpdate: onUpdate,
    );

    return Padding(
      // Нулевые отступы, так как идеальные паддинги 24px уже зашиты внутри TaskCardView
      padding: EdgeInsets.zero, 
      child: Dismissible(
        key: ValueKey('task_${task.id}_${task.status}'),
        direction: DismissDirection.horizontal,

        background: _leftBackground(),
        secondaryBackground: _rightBackground(),

        confirmDismiss: (direction) async {
          final newStatus = _nextStatus(direction);
          if (newStatus != null) {
            onMove(task.id, newStatus);
          }
          return false; // Возвращаем false, чтобы карточка плавно отпружинила назад, а не исчезала физически
        },

        child: card,
      ),
    );
  }

  // ---------- ЛОГИКА ПЕРЕКЛЮЧЕНИЯ ЭКРАНОВ ----------

  TaskStatus? _nextStatus(DismissDirection dir) {
    if (dir == DismissDirection.startToEnd) {
      if (task.status == TaskStatus.todo) return TaskStatus.inProgress;
      if (task.status == TaskStatus.inProgress) return TaskStatus.done;
    }

    if (dir == DismissDirection.endToStart) {
      if (task.status == TaskStatus.inProgress) return TaskStatus.todo;
      if (task.status == TaskStatus.done) return TaskStatus.inProgress;
    }

    return null;
  }

  // ---------- ПРЕМИАЛЬНЫЕ МИНИМАЛИСТИЧНЫЕ ФОНЫ ----------

  Widget _leftBackground() {
    if (task.status == TaskStatus.todo) {
      return _swipeBg(Icons.play_arrow_rounded, "In Progress", const Color(0xFFD97706), Alignment.centerLeft); // Спокойный янтарный
    }
    if (task.status == TaskStatus.inProgress) {
      return _swipeBg(Icons.check_circle_outline_rounded, "Done", const Color(0xFF16A34A), Alignment.centerLeft); // Благородный зеленый
    }
    return const SizedBox();
  }

  Widget _rightBackground() {
    if (task.status == TaskStatus.inProgress) {
      return _swipeBg(Icons.keyboard_return_rounded, "To Do", const Color(0xFF2563EB), Alignment.centerRight); // Фирменный кобальт
    }
    if (task.status == TaskStatus.done) {
      return _swipeBg(Icons.refresh_rounded, "Reopen", const Color(0xFF64748B), Alignment.centerRight); // Системный Slate-серый
    }
    return const SizedBox();
  }

  // ====== СТИЛИЗАЦИЯ ПОДЛОЖКИ СВАЙПА В СТИЛЕ СИСТЕМЫ MINIMAL ======
  Widget _swipeBg(
    IconData icon,
    String text,
    Color color,
    Alignment align,
  ) {
    return Container(
      alignment: align,
      // Боковые отступы 24px идеально рифмуются с началом текста в TaskCardView
      padding: const EdgeInsets.symmetric(horizontal: 24), 
      decoration: const BoxDecoration(
        color: Colors.transparent, // Полностью прозрачный фон без грязных блеклых прямоугольников
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: align == Alignment.centerLeft
            ? [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  text, 
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    color: color, 
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Убрали жирный топорный Bold
                    letterSpacing: -0.1,
                  ),
                ),
              ]
            : [
                Text(
                  text, 
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    color: color, 
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 18),
              ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:task_minimal/ui/widgets/ui_card.dart';
import '../models/task.dart';

class SwipeCard extends StatelessWidget {
  final Task task;
  final void Function(int, TaskStatus) onMove;
  final void Function(int) onDelete;
  final Function(int, String) onUpdate;

  const SwipeCard({
    super.key,
    required this.task,
    required this.onMove,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final card = TaskCardView(
      task: task,
      onDelete: () => onDelete(task.id),
      onUpdate: onUpdate,
    );


  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Dismissible(
        key: ValueKey('task_${task.id}_${task.status}'),
        direction: DismissDirection.horizontal,

        background: _leftBackground(),
        secondaryBackground: _rightBackground(),

        confirmDismiss: (direction) async {
          final newStatus = _nextStatus(direction);
          if (newStatus != null) {
            onMove(task.id, newStatus);
          }
          return false;
        },

        child: card,
      ),
    );
  }

  // ---------- ЛОГИКА ----------

  TaskStatus? _nextStatus(DismissDirection dir) {
    if (dir == DismissDirection.startToEnd) {
      if (task.status == TaskStatus.todo) return TaskStatus.inProgress;
      if (task.status == TaskStatus.inProgress) return TaskStatus.done;
    }

    if (dir == DismissDirection.endToStart) {
      if (task.status == TaskStatus.inProgress) return TaskStatus.todo;
      if (task.status == TaskStatus.done) return TaskStatus.inProgress;
    }

    return null;
  }

  // ---------- ФОНЫ ----------

  Widget _leftBackground() {
    if (task.status == TaskStatus.todo) {
      return _swipeBg(Icons.play_arrow, "IN PROGRESS", Colors.orange, Alignment.centerLeft);
    }
    if (task.status == TaskStatus.inProgress) {
      return _swipeBg(Icons.check, "DONE", Colors.green, Alignment.centerLeft);
    }
    return const SizedBox();
  }

  Widget _rightBackground() {
    if (task.status == TaskStatus.inProgress) {
      return _swipeBg(Icons.assignment_return, "TO DO", Colors.grey, Alignment.centerRight);
    }
    if (task.status == TaskStatus.done) {
      return _swipeBg(Icons.replay, "IN PROGRESS", Colors.orange, Alignment.centerRight);
    }
    return const SizedBox();
  }

  Widget _swipeBg(
    IconData icon,
    String text,
    Color color,
    Alignment align,
  ) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}*/