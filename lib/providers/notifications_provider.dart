import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsProvider {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// تهيئة الإشعارات
  Future<void> init() async {
    // إعدادات Android
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    // إعداد المناطق الزمنية
    tz.initializeTimeZones();
  }

  /// 1️⃣ إشعار فوري عند إضافة أو تعديل مهمة
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // id عشوائي
      title,
      body,
      platformDetails,
    );
  }

  /// 2️⃣ إشعار تذكير قبل موعد المهمة
  Future<void> scheduleTaskReminder({
    required String taskId, // ← id من موديل Task (String)
    required String title,
    required String body,
    required DateTime taskDateTime,
    Duration before = const Duration(minutes: 10),
  }) async {
    // تحويل id إلى int
    final int notificationId = taskId.hashCode;

    // وقت التذكير = الموعد - الوقت قبل المهمة
    final reminderTime = taskDateTime.subtract(before);

    // إذا الوقت أصبح في الماضي → لا ترسل إشعار
    if (reminderTime.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tasks_channel',
      'Tasks Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // 👇 بديل androidAllowWhileIdle القديم
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// 3️⃣ إلغاء تذكير مهمة
  Future<void> cancelReminder(String taskId) async {
    await _plugin.cancel(taskId.hashCode);
  }
}
