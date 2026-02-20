import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/task_form.dart';
import 'settings_screen.dart';
import 'task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    // ✅ تأكد تحميل المهام الخاصة بالمستخدم الحالي
    Future.microtask(() {
      final tasksProvider =
          Provider.of<TasksProvider>(context, listen: false);
      tasksProvider.reloadForCurrentUser();
    });
  }

  void _openAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    final inProgress = tasksProvider.inProgressTasks;
    final doneTasks = tasksProvider.completedTasks;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [skyBlue, babyPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 🌟 AppBar مودرن بدون AppBar الحقيقي
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.80),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset('assets/logo.png'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? "ابدأ يومك بقوة" : "Make Today Count",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          SettingsScreen.routeName,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🌈 Tabs مودرن
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.white,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ),
                    ),
                    tabs: [
                      Tab(
                        text: isArabic ? 'قيد التنفيذ' : 'In Progress',
                      ),
                      Tab(
                        text: isArabic ? 'مكتملة' : 'Completed',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🌟 المحتوى
                Expanded(
                  child: TabBarView(
                    children: [
                      // 🟡 المهام قيد التنفيذ
                      _buildTaskList(
                        isArabic: isArabic,
                        tasks: inProgress,
                        emptyText: isArabic
                            ? 'لا توجد مهام قيد التنفيذ'
                            : 'No tasks in progress',
                        context: context,
                      ),

                      // 🟢 المهام المكتملة
                      _buildTaskList(
                        isArabic: isArabic,
                        tasks: doneTasks,
                        emptyText: isArabic
                            ? 'لا توجد مهام مكتملة'
                            : 'No completed tasks',
                        context: context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ➕ زر الإضافة العصري
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [skyBlue, babyPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => _openAddTask(context),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList({
    required bool isArabic,
    required List tasks,
    required String emptyText,
    required BuildContext context,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final task = tasks[i];

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white30),
              ),
              child: TaskItem(
                task: task,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    TaskDetailsScreen.routeName,
                    arguments: task.id,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
