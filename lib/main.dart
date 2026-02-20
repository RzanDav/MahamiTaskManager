import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/tasks_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/notifications_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/onboarding_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 تهيئة النوتيفيكيشن بروفايدر
  final notificationsProvider = NotificationsProvider();
  await notificationsProvider.init();

  runApp(MyApp(notificationsProvider: notificationsProvider));
}

class MyApp extends StatelessWidget {
  final NotificationsProvider notificationsProvider;

  const MyApp({super.key, required this.notificationsProvider});

  ThemeData _buildLightTheme() {
    const Color skyBlue = Color(0xFF66CCFF);
    const Color babyPink = Color(0xFFFFA1D5);

    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,

      // خطوط
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // أزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: babyPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: babyPink,
        foregroundColor: Colors.white,
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        indicatorColor: Colors.white,
      ),

      // الحقول
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: skyBlue, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        // 👇 بروفايدر الإشعارات
        Provider<NotificationsProvider>.value(
          value: notificationsProvider,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'مهامي',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            themeMode: ThemeMode.light,

            // نبدأ بالسبلاش
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              OnboardingScreen.routeName: (_) => const OnboardingScreen(), // 👈 جديد
              LoginScreen.routeName: (_) => const LoginScreen(),
              RegisterScreen.routeName: (_) => const RegisterScreen(),
              HomeScreen.routeName: (_) => const HomeScreen(),
              SettingsScreen.routeName: (_) => const SettingsScreen(),
            },
            onGenerateRoute: (settingsRoute) {
              if (settingsRoute.name == TaskDetailsScreen.routeName) {
                final taskId = settingsRoute.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => TaskDetailsScreen(taskId: taskId),
                );
              }
              return null;
            },

            // اتجاه اللغة: عربي RTL، إنجليزي LTR
            builder: (context, child) {
              return Directionality(
                textDirection:
                    settings.isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
