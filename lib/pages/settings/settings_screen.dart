import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/pages/settings/edit_profile_screen.dart';
import 'package:saloon_guide/pages/settings/widgets/saloon_details_card.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  String? token;
  bool _isLoading = true;

  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataString = await _storage.read(key: 'user_data');
      token = await _storage.read(key: 'auth_token');
      if (userDataString != null && userDataString.isNotEmpty) {
        if (!mounted) return; // Ensure widget is still mounted before setState
        setState(() {
          userData = jsonDecode(userDataString) as Map<String, dynamic>;
          _isLoading = false;
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
      if (!mounted) return; // Ensure widget is still mounted before setState
      setState(() {
        userData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (userData != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditProfileScreen(userData: userData!, token: token!),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          userData = result;
        });
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _storage.deleteAll();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomBackButton(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 30),

                          // Profile section
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 100),
                                  child: Text(
                                    userData?['name'] ?? 'User',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.person,
                                          size: 50, color: Colors.white),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData?['email'] ??
                                                'email@example.com',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            userData?['phone'] ??
                                                'Not provided',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _navigateToEditProfile,
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Salon section - only for salon owners
                          if (userData != null &&
                              userData!['role_id'] == 2) ...[
                            SaloonDetailsCard(
                                userData: userData!, token: token!),
                          ],

                          SizedBox(height: 30),
                          Text(
                            'PREFERENCES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 15),

                          // Notifications
                          _buildSettingTile(
                            title: 'Notifications',
                            subtitle: 'Enable push notifications',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeColor: AppColors.primaryDark,
                            ),
                          ),

                          // Dark Mode
                          _buildSettingTile(
                            title: 'Dark Mode',
                            subtitle: 'Enable dark theme',
                            trailing: Switch(
                              value: _darkModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _darkModeEnabled = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Theme changing will be available soon')));
                              },
                              activeColor: AppColors.primaryDark,
                            ),
                          ),

                          // Language
                          _buildSettingTile(
                            title: 'Language',
                            subtitle: _selectedLanguage,
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Select Language'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _languages.length,
                                      itemBuilder: (context, index) {
                                        return RadioListTile<String>(
                                          title: Text(_languages[index]),
                                          value: _languages[index],
                                          groupValue: _selectedLanguage,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedLanguage = value!;
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 30),
                          Text(
                            'ACCOUNT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 15),

                          // Privacy Policy
                          _buildSettingTile(
                            title: 'Privacy Policy',
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Privacy Policy will be added soon')));
                            },
                          ),

                          // Terms of Service
                          _buildSettingTile(
                            title: 'Terms of Service',
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Terms of Service will be added soon')));
                            },
                          ),

                          // About
                          _buildSettingTile(
                            title: 'About',
                            subtitle: 'App version 1.0.0',
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('About section coming soon')));
                            },
                          ),

                          // Logout
                          _buildSettingTile(
                            title: 'Logout',
                            titleColor: Colors.red,
                            trailing: Icon(Icons.logout, color: Colors.red),
                            onTap: _logout,
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
