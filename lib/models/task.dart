class Task {
  final String id;
  String title;
  String? description;
  DateTime? dateTime;
  bool isDone;

  /// 0 = منخفض (أخضر), 1 = متوسط (أصفر), 2 = عالي (أحمر)
  int priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dateTime,
    this.isDone = false,
    this.priority = 1, // ← افتراضي: متوسط
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'isDone': isDone,
      'priority': priority, // ← جديد
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int)
          : null,
      isDone: map['isDone'] as bool? ?? false,
      priority: map['priority'] as int? ?? 1, // ← مهم جداً لا يكسر المهام القديمة
    );
  }
}
