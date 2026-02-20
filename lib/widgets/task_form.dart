import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notifications_provider.dart'; // 👈 تم إضافة هذا

class TaskForm extends StatefulWidget {
  final Task? existingTask;
  const TaskForm({super.key, this.existingTask});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _form = GlobalKey<FormState>();
  final _t = TextEditingController();
  final _d = TextEditingController();
  DateTime? _selectedDateTime;

  int _priority = 1; // 0 = منخفض, 1 = متوسط, 2 = عالي

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _t.text = widget.existingTask!.title;
      _d.text = widget.existingTask!.description ?? "";
      _selectedDateTime = widget.existingTask!.dateTime;
      _priority = widget.existingTask!.priority;
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDateTime ?? now,
    );
    if (!mounted) return;
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );
    if (!mounted) return;
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year;
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y/$m/$d  $h:$min';
  }

  void _save() {
    if (!_form.currentState!.validate()) return;

    final tasksProvider =
        Provider.of<TasksProvider>(context, listen: false);

    // نجيب الإعدادات عشان نضبط لغة نص الإشعارات
    final settings =
        Provider.of<SettingsProvider>(context, listen: false);
    final isArabic = settings.isArabic;

    // بروفايدر الإشعارات
    final notificationsProvider =
        Provider.of<NotificationsProvider>(context, listen: false);

    if (widget.existingTask == null) {
      // 🆕 إضافة مهمة جديدة
      final newTask = Task(
        id: const Uuid().v4(),
        title: _t.text,
        description: _d.text,
        dateTime: _selectedDateTime,
        priority: _priority,
      );

      tasksProvider.addTask(newTask);

      // 🔔 إشعار فوري عند الإضافة
      notificationsProvider.showInstantNotification(
        title: isArabic ? 'تم إضافة مهمة جديدة' : 'New task added',
        body: newTask.title,
      );

      // ⏰ تذكير قبل الموعد (لو فيه تاريخ)
      if (newTask.dateTime != null) {
        notificationsProvider.scheduleTaskReminder(
          taskId: newTask.id,
          title: isArabic ? 'تذكير بالمهمة' : 'Task reminder',
          body: newTask.title,
          taskDateTime: newTask.dateTime!,
          // تقدر تغيرها لساعة أو يوم مثلاً
          before: const Duration(minutes: 10),
        );
      }
    } else {
      // ✏️ تعديل مهمة موجودة
      final updatedTask = Task(
        id: widget.existingTask!.id,
        title: _t.text,
        description: _d.text,
        isDone: widget.existingTask!.isDone,
        dateTime: _selectedDateTime,
        priority: _priority,
      );

      tasksProvider.updateTask(updatedTask);

      // 🔔 إشعار فوري عند التعديل
      notificationsProvider.showInstantNotification(
        title: isArabic ? 'تم تعديل مهمة' : 'Task updated',
        body: updatedTask.title,
      );

      // ⏰ إلغاء أي تذكير قديم مرتبط بهذه المهمة ثم إنشاء واحد جديد (لو فيه موعد)
      notificationsProvider.cancelReminder(updatedTask.id);
      if (updatedTask.dateTime != null) {
        notificationsProvider.scheduleTaskReminder(
          taskId: updatedTask.id,
          title: isArabic ? 'تذكير بالمهمة' : 'Task reminder',
          body: updatedTask.title,
          taskDateTime: updatedTask.dateTime!,
          before: const Duration(minutes: 10),
        );
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.existingTask == null
                        ? (isArabic
                            ? "إضافة مهمة جديدة"
                            : "Add New Task")
                        : (isArabic ? "تعديل مهمة" : "Edit Task"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // عنوان المهمة
                  TextFormField(
                    controller: _t,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.title_rounded),
                      labelText: isArabic ? "العنوان" : "Title",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? (isArabic ? "مطلوب" : "Required")
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // الوصف
                  TextFormField(
                    controller: _d,
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.description_rounded),
                      labelText: isArabic
                          ? "الوصف (اختياري)"
                          : "Description (optional)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // الأهمية
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isArabic ? "الأهمية" : "Priority",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriorityChip(
                        label: isArabic ? "منخفض" : "Low",
                        color: Colors.green,
                        value: 0,
                      ),
                      _buildPriorityChip(
                        label: isArabic ? "متوسط" : "Medium",
                        color: Colors.amber,
                        value: 1,
                      ),
                      _buildPriorityChip(
                        label: isArabic ? "عالٍ" : "High",
                        color: Colors.red,
                        value: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // التاريخ والوقت
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? (isArabic
                                  ? "لا يوجد موعد محدد"
                                  : "No due date set")
                              : ((isArabic ? "الموعد: " : "Due: ") +
                                  _formatDateTime(
                                      _selectedDateTime!)),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateTime,
                        child: Text(
                          isArabic ? "اختيار" : "Pick",
                          style: const TextStyle(
                              color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [skyBlue, babyPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isArabic ? "حفظ" : "Save",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip({
    required String label,
    required Color color,
    required int value,
  }) {
    final isSelected = _priority == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) {
        setState(() {
          _priority = value;
        });
      },
    );
  }
}
