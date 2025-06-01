import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/config/api_config.dart';
import 'package:saloon_guide/constants/app_fonts.dart';
import 'package:saloon_guide/pages/home/widgets/greeting_text.dart';
import 'package:saloon_guide/pages/home/widgets/nearby_saloons_section.dart';
import 'package:saloon_guide/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = const FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verifyAuthentication();
  }

  Future<void> _verifyAuthentication() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        _navigateToLogin();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.authCheck),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Auth verification response: $responseData');
      }

      if (response.statusCode == 200 && responseData['status'] == true) {
        // Store updated user data
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(responseData['data']),
        );

        setState(() {
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Authentication failed: ${responseData['message']}');
        }
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying authentication: $e');
      }
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text(
          'Saloon Guide',
          style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.babasNeue),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      endDrawer: CustomDrawer(),
      // We need to use a Builder to get the correct BuildContext that has Scaffold as an ancestor
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingText(),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(148, 158, 158, 158),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(17, 255, 255, 255),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 15),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/saloon-list');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 23,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'LATEST VISIT',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(height: 10),
                // LatestSaloonCard(saloonData: saloonData),
                SizedBox(height: 20),
                NearbySaloonsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
