import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saloon_guide/pages/home/home_screen.dart';
import 'package:saloon_guide/pages/login/login_screen.dart';
// import 'package:saloon_guide/pages/complete/complete_screen.dart';
import 'package:saloon_guide/pages/saloon_list/saloon_list_screen.dart';
import 'package:saloon_guide/pages/register/register_screen.dart';
import 'package:saloon_guide/pages/create_saloon/create_saloon_screen.dart';
import 'package:saloon_guide/pages/settings/settings_screen.dart';
// import 'package:saloon_guide/pages/single_saloon/single_saloon_screen.dart';
import 'package:saloon_guide/pages/saloon/edit_saloon_screen.dart';

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
    if (kDebugMode) {
      print('MainApp initState called');
    }
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (kDebugMode) {
        print('Token: $token');
      }
      setState(() {
        _isAuthenticated = token != null;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error reading token: $e');
      }
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
        '/register': (context) => RegisterScreen(),
        '/saloon-list': (context) => SaloonListScreen(),
        '/home': (context) => HomeScreen(),
        '/create-saloon': (context) => CreateSaloonScreen(),
        '/settings': (context) => SettingsScreen(),
        '/edit-saloon': (context) => const EditSaloonScreen(),
        // '/saloon': (context) => SingleSaloonScreen(),
        // '/complete': (context) => CompleteScreen(),
      },
    );
  }
}
