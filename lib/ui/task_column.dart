import 'package:flutter/material.dart';
import 'package:task_minimal/ui/task_list.dart';
import '../models/task.dart';

class TaskColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final void Function(int, TaskStatus) onMove;
  final void Function(int) onDelete;
  final Function(int, String) onUpdate;
  final bool draggable;

  const TaskColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.onMove,
    required this.onDelete,
    required this.onUpdate,
    required this.draggable,
  });

  bool isMobileLayout(BuildContext context) {
  return MediaQuery.of(context).size.width < 900;
}


  @override
  Widget build(BuildContext context) {

    return 
    Column(
      children: [
if(!isMobileLayout(context)) Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orangeAccent, // Цвет зависит от статуса
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          // Счетчик задач
          Text(
            '${tasks.length}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
      const Divider(height: 24, thickness: 1), // Разделитель под заголовком
    ],
  ),
)

,
      Expanded(
        child:
    DragTarget<int>(
      onAcceptWithDetails: (details) {
        onMove(details.data, status);
      },
      builder: (_, candidate, _) {
        return Container(
          margin: (isMobileLayout(context)) ? EdgeInsets.all(0) : EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty ? Colors.blue.withAlpha(10) : Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: TaskList(
            tasks: tasks,
            draggable: draggable,
            onMove: onMove,
            onDelete: onDelete,
            onUpdate: onUpdate,
          ),
        );
      },
    ),),
    ]);
  }
}
