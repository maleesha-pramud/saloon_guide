import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saloon_guide/pages/home/home_screen.dart';
import 'package:saloon_guide/pages/login/login_screen.dart';
// import 'package:saloon_guide/pages/complete/complete_screen.dart';
// import 'package:saloon_guide/pages/saloon_list/saloon_list_screen.dart';
// import 'package:saloon_guide/pages/signup/signup_screen.dart';
// import 'package:saloon_guide/pages/single_saloon/single_saloon_screen.dart';

void main() {
  // Ensure Flutter is properly initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    print('MainApp initState called');
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      print('Token: $token');
      setState(() {
        _isAuthenticated = token != null;
      });
    } catch (e) {
      print('Error reading token: $e');
      // If there's an error reading the token, assume not authenticated
      setState(() {
        _isAuthenticated = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isAuthenticated
              ? HomeScreen()
              : LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        // '/signup': (context) => SignupScreen(),
        // '/saloon-list': (context) => SaloonListScreen(),
        '/home': (context) => HomeScreen(),
        // '/saloon': (context) => SingleSaloonScreen(),
        // '/complete': (context) => CompleteScreen(),
      },
    );
  }
}
