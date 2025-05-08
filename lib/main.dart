import 'package:flutter/material.dart';
import 'package:saloon_guide/pages/complete/complete_screen.dart';
import 'package:saloon_guide/pages/home/home_screen.dart';
import 'package:saloon_guide/pages/login/login_screen.dart';
import 'package:saloon_guide/pages/saloon_list/saloon_list_screen.dart';
import 'package:saloon_guide/pages/signup/signup_screen.dart';
import 'package:saloon_guide/pages/single_saloon/single_saloon_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/saloon-list': (context) => SaloonListScreen(),
        '/saloon': (context) => SingleSaloonScreen(),
        '/complete': (context) => CompleteScreen(),
      },
    );
  }
}
