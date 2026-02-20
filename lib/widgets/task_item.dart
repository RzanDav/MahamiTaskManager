import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../providers/notifications_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year;
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y/$m/$d  $h:$min';
  }

  Color _priorityColor() {
    switch (task.priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.amber;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<TasksProvider>(context, listen: false);

    final borderColor = _priorityColor();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) async {
            final wasDone = task.isDone;

            // نغير الحالة
            p.toggleTask(task.id);

            // لو أصبحت مكتملة → ن cancel التذكير
            if (!wasDone) {
              final notificationsProvider =
                  Provider.of<NotificationsProvider>(context, listen: false);
              await notificationsProvider.cancelReminder(task.id);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration:
                task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!),
            if (task.dateTime != null)
              Text(
                _formatDateTime(task.dateTime!),
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => p.deleteTask(task.id),
        ),
      ),
    );
  }
}
