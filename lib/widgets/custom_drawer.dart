import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saloon_guide/constants/app_colors.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
        if (!mounted) return;
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
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  userData?['name'] ?? 'Guest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View Profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Booking History'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to booking history
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to favorites
            },
          ),
          userData?['role_id'] == 2
              ? ListTile(
                  leading: Icon(Icons.add_business),
                  title: Text('Create Saloon'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create-saloon');
                  },
                )
              : Container(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await _storage.deleteAll();
              if (!mounted) return;
              Navigator.pop(context); // Close the drawer first
              // Replace current route and remove all previous routes from stack
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false, // This prevents going back to previous pages
              );
            },
          ),
        ],
      ),
    );
  }
}
