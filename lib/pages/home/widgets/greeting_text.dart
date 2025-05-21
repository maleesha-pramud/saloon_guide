import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class GreetingText extends StatefulWidget {
  const GreetingText({super.key});

  @override
  State<GreetingText> createState() => _GreetingTextState();
}

class _GreetingTextState extends State<GreetingText> {
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataString = await _storage.read(key: 'user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        setState(() {
          userData = jsonDecode(userDataString) as Map<String, dynamic>;
        });
      } else {
        if (!mounted) return; // Guard against using context after async gap
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      // Handle the error gracefully - reset user data if needed
      setState(() {
        userData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format today's date as "Day of week, Month Day"
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hey,',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            SizedBox(width: 10),
            Text(
              userData != null ? userData!['name'] ?? 'User' : 'User',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(
              '👋',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          today,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}
