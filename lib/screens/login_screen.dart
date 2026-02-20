import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart'; // ✅ جديد
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final s = Provider.of<SettingsProvider>(context, listen: false);
  final inputUser = _u.text.trim();
  final inputPass = _p.text.trim();

  final ok = await s.login(inputUser, inputPass);
  if (!mounted) return;

  if (ok) {
    // ✅ هنا فقط نطلب من TasksProvider يعيد تحميل مهام المستخدم الحالي
    final tasksProvider =
        Provider.of<TasksProvider>(context, listen: false);
    await tasksProvider.reloadForCurrentUser();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.isArabic ? "بيانات الدخول غير صحيحة" : "Invalid login data",
        ),
      ),
    );
  }
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
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ... (الباقي نفسه بدون تغيير)
                    // اللوقو
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
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

                    const SizedBox(height: 20),

                    Text(
                      isArabic ? "مرحباً بك!" : "Welcome!",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      isArabic
                          ? "سعداء بعودتك، قم بتسجيل الدخول"
                          : "Glad to see you again, please login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _u,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: isArabic ? 'اسم المستخدم' : 'Username',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _p,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: isArabic ? 'كلمة المرور' : 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              skyBlue,
                              babyPink,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'دخول' : 'Login',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterScreen.routeName);
                      },
                      child: Text(
                        isArabic ? "إنشاء حساب جديد" : "Create a new account",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
