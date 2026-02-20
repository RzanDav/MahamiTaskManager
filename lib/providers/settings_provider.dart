import 'dart:convert'; // ✅ مهم
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // 🔹 مفاتيح التخزين
  static const String _keyUsers = 'users_list';            // ✅ قائمة المستخدمين
  static const String _keyCurrentUserId = 'currentUserId'; // ✅ المستخدم الحالي (username)
  static const String _keyIsArabic = 'is_arabic';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // (هذي للموافقة مع الكود القديم، تمثل "المستخدم الحالي")
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyAge = 'age';
  static const String _keyGender = 'gender';

  // 🔹 المتغيرات
  List<Map<String, dynamic>> _users = []; // ✅ كل المستخدمين
  String? _currentUserId;                // ✅ اسم المستخدم الحالي (لو داخل)
  String? _username;                     // بيانات المستخدم الحالي فقط
  String? _password;
  int? _age;
  String? _gender;
  bool _isArabic = true;
  bool _isLoggedIn = false;

  SettingsProvider() {
    _loadSettings();
  }

  // 🔹 Getters
  String? get username => _username;
  String? get password => _password;
  int? get age => _age;
  String? get gender => _gender;
  bool get isArabic => _isArabic;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;

  // 🔹 تحميل جميع الإعدادات
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 🧾 تحميل قائمة المستخدمين
    final usersJson = prefs.getString(_keyUsers);
    if (usersJson != null) {
      final List decoded = jsonDecode(usersJson) as List<dynamic>;
      _users = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _users = [];
    }

    _isArabic = prefs.getBool(_keyIsArabic) ?? true;
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _currentUserId = prefs.getString(_keyCurrentUserId);

    // لو فيه مستخدم مسجّل دخول، حمّل بياناته
    if (_isLoggedIn && _currentUserId != null) {
      final user = _users.cast<Map<String, dynamic>?>().firstWhere(
            (u) => u?['username'] == _currentUserId,
            orElse: () => null,
          );
      if (user != null) {
        _username = user['username'];
        _password = user['password'];
        _age = user['age'];
        _gender = user['gender'];
      }
    }

    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsers, jsonEncode(_users));
  }

  // 🔹 تغيير اللغة
  Future<void> setLanguage(bool isArabic) async {
    _isArabic = isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsArabic, isArabic);
    notifyListeners();
  }

  // 🔹 إنشاء / تحديث مستخدم (تستخدمها صفحة التسجيل والإعدادات)
  Future<void> updateUser({
    required String username,
    required String password,
    int? age,
    String? gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // هل يوجد مستخدم بنفس هذا الاسم؟
    final index =
        _users.indexWhere((u) => u['username']?.toString() == username);

    final userData = <String, dynamic>{
      'username': username,
      'password': password,
      'age': age,
      'gender': gender,
    };

    if (index == -1) {
      // 🟢 مستخدم جديد → نضيفه للقائمة
      _users.add(userData);
    } else {
      // 🟡 تعديل بيانات مستخدم موجود
      _users[index] = userData;
    }

    await _saveUsers();

    // لو هذا هو المستخدم الحالي (أو ما فيه مستخدم حالي)، حدّث المتغيرات
    if (_currentUserId == null || _currentUserId == username) {
      _currentUserId = username;
      _username = username;
      _password = password;
      _age = age;
      _gender = gender;

      await prefs.setString(_keyCurrentUserId, username);
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyPassword, password);
      if (age != null) await prefs.setInt(_keyAge, age);
      if (gender != null) await prefs.setString(_keyGender, gender);
    }

    notifyListeners();
  }

  // 🔹 تسجيل الدخول
  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // نبحث عن مستخدم يطابق الاسم وكلمة المرور
    final user = _users.cast<Map<String, dynamic>?>().firstWhere(
          (u) =>
              u?['username'] == username &&
              u?['password'] == password,
          orElse: () => null,
        );

    if (user == null) {
      // ما فيه مستخدم بهذي البيانات
      _isLoggedIn = false;
      await prefs.setBool(_keyIsLoggedIn, false);
      notifyListeners();
      return false;
    }

    // 🟢 نجاح تسجيل الدخول
    _isLoggedIn = true;
    _currentUserId = username;

    _username = user['username'];
    _password = user['password'];
    _age = user['age'];
    _gender = user['gender'];

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUserId, username);

    // تخزين بيانات المستخدم الحالي (للتوافق مع الكود القديم)
    await prefs.setString(_keyUsername, _username!);
    await prefs.setString(_keyPassword, _password!);
    if (_age != null) await prefs.setInt(_keyAge, _age!);
    if (_gender != null) await prefs.setString(_keyGender, _gender!);

    notifyListeners();
    return true;
  }

  // 🔹 تسجيل خروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = false;
    _currentUserId = null;
    _username = null;
    _password = null;
    _age = null;
    _gender = null;

    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUserId);

    // لاحظ: ما نحذف قائمة المستخدمين (_keyUsers)
    // عشان تبقى الحسابات محفوظة في الجهاز

    notifyListeners();
  }
}
