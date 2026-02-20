import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/task_form.dart';

class TaskDetailsScreen extends StatelessWidget {
  static const routeName = '/details';
  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year;
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y/$m/$d  $h:$min';
  }

  String _priorityText(int priority, bool isArabic) {
    switch (priority) {
      case 0:
        return isArabic ? "منخفض" : "Low";
      case 1:
        return isArabic ? "متوسط" : "Medium";
      case 2:
        return isArabic ? "عالٍ" : "High";
      default:
        return "-";
    }
  }

  Color _priorityColor(int priority) {
    switch (priority) {
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
    final tasksProvider = Provider.of<TasksProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    final t = tasksProvider.getById(taskId);

    if (t == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? "تفاصيل المهمة" : "Task Details"),
          backgroundColor: skyBlue,
        ),
        body: Center(
          child: Text(
            isArabic ? "المهمة غير موجودة" : "Task not found",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final statusText = t.isDone
        ? (isArabic ? "مكتملة" : "Completed")
        : (isArabic ? "غير مكتملة" : "In progress");

    final statusColor = t.isDone ? Colors.green : Colors.orange;

    final priorityColor = _priorityColor(t.priority);
    final priorityText = _priorityText(t.priority, isArabic);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "تفاصيل المهمة" : "Task Details"),
        backgroundColor: skyBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                builder: (_) => TaskForm(existingTask: t),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [skyBlue, babyPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: MediaQuery.of(context).size.width > 500
                  ? 450
                  : double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // الحالة Chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              t.isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.timelapse_rounded,
                              size: 18,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // الأهمية Chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 18,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (isArabic ? "الأهمية: " : "Priority: ") +
                                  priorityText,
                              style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // التاريخ والوقت إن وجد
                  if (t.dateTime != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (isArabic ? "الموعد: " : "Due: ") +
                              _formatDateTime(t.dateTime!),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // الوصف إن وُجد
                  if (t.description != null && t.description!.isNotEmpty) ...[
                    Text(
                      isArabic ? "الوصف" : "Description",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    Text(
                      isArabic
                          ? "لا يوجد وصف لهذه المهمة."
                          : "No description for this task.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
