import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seenOnboarding", true);
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<SettingsProvider>(context);
    final isArabic = s.isArabic;

    const skyBlue = Color(0xFF66CCFF);
    const babyPink = Color(0xFFFFA1D5);

    final pages = [
      _buildPage(
        image: "assets/2.png",
        titleAR: "اتّبع خطتك… لا مزاجك.",
        titleEN: "Follow your plan, not your mood.",
        subAR: "الاستمرارية أساس التقدّم.\nخطوات صغيرة وثابتة تصنع تغييراً حقيقياً.",
        subEN: "Consistency builds progress.\nSmall, steady steps create real change.",
        isArabic: isArabic,
      ),
      _buildPage(
        image: "assets/3.png",
        titleAR: "الوقت كالسيف ان لم تقطعه قطعك",
        titleEN: "Either you run the day, or the day runs you.",
        subAR: "كن واعياً بوقتك.\nحدّد أولوياتك وسيطر على يومك.",
        subEN: "Be intentional.\nSet your priorities and take control of your time.",
        isArabic: isArabic,
      ),
      _buildPage(
        image: "assets/1.png",
        titleAR: "مهامك تعكس أهدافك.",
        titleEN: "Your tasks reflect your goals.",
        subAR: "ركّز على ما يهم، وتقدّم نحو الشخص\nالذي تطمح أن تكونه.",
        subEN: "Focus on what matters and move closer\nto the person you aim to be.",
        isArabic: isArabic,
      ),
    ];

    return Scaffold(
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
              // زر تخطي
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    isArabic ? "تخطي" : "Skip",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                  },
                  itemBuilder: (_, i) => pages[i],
                ),
              ),

              const SizedBox(height: 20),

              // الدوائر
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 9,
                    width: _index == i ? 22 : 9,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _index == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // زر التالي / ابدأ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
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
                      onPressed: () {
                        if (_index == pages.length - 1) {
                          _finish();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _index == pages.length - 1
                            ? (isArabic ? "ابدأ الآن" : "Get Started")
                            : (isArabic ? "التالي" : "Next"),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String image,
    required String titleAR,
    required String titleEN,
    required String subAR,
    required String subEN,
    required bool isArabic,
  }) {
    final title = isArabic ? titleAR : titleEN;
    final subtitle = isArabic ? subAR : subEN;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.40), // نفس اللوقن
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
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
