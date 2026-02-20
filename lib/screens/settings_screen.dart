import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ جديد

import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart'; // ✅ جديد
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _u;
  late TextEditingController _p;
  late TextEditingController _a;
  String? _g;

  @override
  void initState() {
    super.initState();
    final s = Provider.of<SettingsProvider>(context, listen: false);
    _u = TextEditingController(text: s.username ?? "");
    _p = TextEditingController(text: s.password ?? "");
    _a = TextEditingController(text: s.age?.toString() ?? "");
    _g = s.gender;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final s = Provider.of<SettingsProvider>(context, listen: false);
    await s.updateUser(
      username: _u.text,
      password: _p.text,
      age: int.tryParse(_a.text),
      gender: _g,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.isArabic ? "تم حفظ التغييرات" : "Changes saved",
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout() async {
    final s = Provider.of<SettingsProvider>(context, listen: false);

    // ✅ منطق اللوق آوت القديم
    await s.logout();

    // ✅ امسح المستخدم الحالي من الشيرد بريفرنس
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');

    // ✅ فضّي المهام/أعد تحميلها كـ "ضيف" (أو بدون مستخدم)
    final tasksProvider =
        Provider.of<TasksProvider>(context, listen: false);
    await tasksProvider.reloadForCurrentUser();

    if (!mounted) return;

    // ✅ رجع لصفحة تسجيل الدخول وامسح كل الراوتس
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<SettingsProvider>(context);
    final isArabic = s.isArabic;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: skyBlue,
        title: Text(
          isArabic ? "الإعدادات" : "Settings",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [skyBlue, babyPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    // 🌐 اللغة
                    SwitchListTile(
                      title: Text(
                        isArabic ? "اللغة: العربية" : "Language: English",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isArabic
                            ? "اضغط للتبديل إلى الإنجليزية"
                            : "Tap to switch to Arabic",
                      ),
                      value: isArabic,
                      activeColor: babyPink,
                      onChanged: (value) {
                        s.setLanguage(value);
                      },
                    ),

                    const Divider(),
                    const SizedBox(height: 20),

                    // 👤 بيانات المستخدم
                    TextFormField(
                      controller: _u,
                      decoration: InputDecoration(
                        labelText: isArabic ? "اسم المستخدم" : "Username",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty
                              ? (isArabic ? "مطلوب" : "Required")
                              : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _p,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isArabic ? "كلمة المرور" : "Password",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty
                              ? (isArabic ? "مطلوب" : "Required")
                              : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _a,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isArabic ? "العمر" : "Age",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _g,
                      decoration: InputDecoration(
                        labelText: isArabic ? "الجنس" : "Gender",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "ذكر",
                          child: Text(isArabic ? "ذكر" : "Male"),
                        ),
                        DropdownMenuItem(
                          value: "أنثى",
                          child: Text(isArabic ? "أنثى" : "Female"),
                        ),
                      ],
                      onChanged: (v) => setState(() => _g = v),
                    ),

                    const SizedBox(height: 24),

                    // حفظ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: skyBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isArabic ? "حفظ الإعدادات" : "Save Settings",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // خروج
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isArabic ? "تسجيل الخروج" : "Logout",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
