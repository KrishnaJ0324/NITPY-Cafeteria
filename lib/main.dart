import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:admin_mess_app/onboarding/login.dart';
import 'package:admin_mess_app/onboarding/start_up_screen.dart';
import 'package:admin_mess_app/onboarding/register.dart';
import 'package:admin_mess_app/studentSection/student_home_page.dart';
import 'package:admin_mess_app/adminSection/admin_homepage.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final bool isSignedIn = prefs.getBool('isSignedIn') ?? false;
  final String? role = prefs.getString('userRole');

  // Decide initial route based on login state
  String initialRoute;
  if (isSignedIn && role == 'student') {
    initialRoute = '/studentHomePage';
  } else if (isSignedIn && role == 'admin') {
    initialRoute = '/adminHomePage';
  } else {
    initialRoute = '/';
  }

  await Future.delayed(const Duration(milliseconds: 100));
  FlutterNativeSplash.remove();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const StartUpScreen(),
        '/register': (context) => const Register(),
        '/login': (context) => const Login(),
        '/studentHomePage': (context) => const StudentHomePage(),
        '/adminHomePage': (context) => const AdminHomePage(),
      },
    );
  }
}
//python -m uvicorn main:app --reload --host 0.0.0.0 --port 5000



