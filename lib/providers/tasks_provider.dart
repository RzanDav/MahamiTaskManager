import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _tasks = [];

  TasksProvider() {
    _loadTasks(); // يحمل على حسب currentUserId لو موجود
  }

  // يحصل على المفتاح بناءً على المستخدم الحالي
  Future<String> _getStorageKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');

    if (userId == null || userId.isEmpty) {
      return 'tasks_list_guest';
    }

    return 'tasks_list_$userId';
  }

  // قراءة القوائم
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get inProgressTasks =>
      _tasks.where((t) => !t.isDone).toList();
  List<Task> get completedTasks =>
      _tasks.where((t) => t.isDone).toList();

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getStorageKey();

    final data = prefs.getString(key);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
      _tasks = decoded
          .map((e) => Task.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      _tasks = [];
    }
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getStorageKey();

    final encoded = jsonEncode(
      _tasks.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(key, encoded);
  }

  // نناديها لما يتغير المستخدم (بعد اللوقن أو في الهوم)
  Future<void> reloadForCurrentUser() async {
    await _loadTasks();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      _saveTasks();
      notifyListeners();
    }
  }

  Task? getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
