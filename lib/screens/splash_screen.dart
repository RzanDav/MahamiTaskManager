

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
// import 'login_screen.dart';
import 'onboarding_screen.dart'; 

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // أنيميشن هادي وراقي
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _go();
    });
  }

  Future<void> _go() async {
    // ننتظر شوي عشان السبلاش يظهر
    await Future.delayed(const Duration(seconds: 3));

    // // نقرأ هل المستخدم شاف الأونبوردنغ قبل كذا
    // final prefs = await SharedPreferences.getInstance();
    // final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    // if (seenOnboarding) {
    //   // إذا شافها من قبل → نروح للّوقن مباشرة
    //   Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    // } else {
      // أول مرة → نفتح شاشة الأونبوردنغ
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;
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
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // لوقو داخل دائرة بيضاء
                Container(
                  width: size.width * 0.32,
                  height: size.width * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.90),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // اسم التطبيق
                Text(
                  isArabic ? "مهامي" : "Mahami",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // جملة بسيطة راقية
                Text(
                  isArabic
                      ? "يوم جديد… إنجاز جديد ✨"
                      : "A fresh start... a new goal ✨",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),

                const SizedBox(height: 36),

                // شريط تحميل هادي
                SizedBox(
                  width: size.width * 0.55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor:  Colors.white.withOpacity(0.30),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
