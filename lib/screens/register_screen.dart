import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart'; 
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();
  final _a = TextEditingController();
  String? _g;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;

    final s = Provider.of<SettingsProvider>(context, listen: false);
    final username = _u.text.trim();
    final password = _p.text.trim();

    await s.updateUser(
      username: username,
      password: password,
      age: int.tryParse(_a.text.trim().isEmpty ? '0' : _a.text.trim()),
      gender: _g,
    );

    // ✅ بعد ما نسجل المستخدم، نسوي له login
    final ok = await s.login(username, password);

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.isArabic
                ? "حدث خطأ في تسجيل الدخول بعد إنشاء الحساب"
                : "Login failed after registration",
          ),
        ),
      );
      return;
    }

    // ✅ نحدّث مهام المستخدم الحالي
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    await tasksProvider.reloadForCurrentUser();

    if (!mounted) return;

    // ✅ ننتقل للهوم
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<SettingsProvider>(context);
    final isArabic = s.isArabic;
    final size = MediaQuery.of(context).size;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              skyBlue,
              babyPink,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: size.width > 500 ? 430 : double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.40),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // اللوقو
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // عنوان الشاشة
                    Text(
                      isArabic ? "إنشاء حساب جديد" : "Create Account",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic
                          ? "انضم لعالم المهام المنظمة ✨"
                          : "Join the world of organized tasks ✨",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // اسم المستخدم
                    TextFormField(
                      controller: _u,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: isArabic ? "اسم المستخدم" : "Username",
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

                    // كلمة المرور
                    TextFormField(
                      controller: _p,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: isArabic ? "كلمة المرور" : "Password",
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

                    // العمر (اختياري)
                    TextFormField(
                      controller: _a,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.cake_outlined),
                        labelText:
                            isArabic ? "العمر (اختياري)" : "Age (optional)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الجنس
                    DropdownButtonFormField<String>(
                      value: _g,
                      items: [
                        DropdownMenuItem<String>(
                          value: "ذكر",
                          child: Text(isArabic ? "ذكر" : "Male"),
                        ),
                        DropdownMenuItem<String>(
                          value: "أنثى",
                          child: Text(isArabic ? "أنثى" : "Female"),
                        ),
                      ],
                      onChanged: (String? v) {
                        setState(() {
                          _g = v;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.wc_outlined),
                        labelText:
                            isArabic ? "الجنس (اختياري)" : "Gender (optional)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // زر إنشاء حساب
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
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            isArabic ? "إنشاء الحساب" : "Create Account",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        );
                      },
                      child: Text(
                        isArabic
                            ? "لديك حساب بالفعل؟ تسجيل الدخول"
                            : "Already have an account? Login",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
