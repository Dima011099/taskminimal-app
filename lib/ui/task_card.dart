import 'package:flutter/material.dart';
import 'package:task_minimal/models/task.dart';
import 'package:task_minimal/ui/widgets/ui_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool draggable;
  final VoidCallback onDelete;
  final Function(int, String) onUpdate;

 const TaskCard({
  super.key,
  required this.task,
  required this.draggable,
  required this.onDelete,
  required this.onUpdate
});

  @override
  Widget build(BuildContext context) {
   /* final card = _body();*/
    final card = TaskCardView(
      task: task,
      onDelete: onDelete,
      onUpdate: onUpdate,
    );

    if (!draggable) return card;

    return LongPressDraggable<int>(
      data: task.id,
      feedback: Material(child: SizedBox(width: 300, child: card)),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }


}