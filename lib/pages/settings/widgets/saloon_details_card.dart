import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/config/api_config.dart';
import 'package:saloon_guide/models/service/service.dart';

class SaloonDetailsCard extends StatefulWidget {
  const SaloonDetailsCard({super.key, required this.userData, this.token});
  final String? token;
  final Map<String, dynamic> userData;

  @override
  State<SaloonDetailsCard> createState() => _SaloonDetailsCardState();
}

class _SaloonDetailsCardState extends State<SaloonDetailsCard> {
  Map<String, dynamic>? saloonData;
  bool _isSaloonLoading = false;
  String? _saloonError;

  @override
  void initState() {
    super.initState();
    // If user is a salon owner (role_id = 2 or role = 'owner'), fetch their salon details
    if (widget.userData['role_id'] == 2 || widget.userData['role'] == 'owner') {
      _loadSaloonDetails(widget.userData['id']);
    }
  }

  Future<void> _loadSaloonDetails(int ownerId) async {
    setState(() {
      _isSaloonLoading = true;
      _saloonError = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getSaloonsByOwnerUrl(ownerId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response data: $responseData');
      }

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          saloonData = responseData['data'];
          _isSaloonLoading = false;
        });
      } else if (responseData['message'] == "No salon found for owner") {
        setState(() {
          saloonData = null; // This will trigger the "create salon" prompt
          _isSaloonLoading = false;
          _saloonError = null; // Clear any previous error
        });
      } else {
        setState(() {
          _saloonError =
              responseData['message'] ?? 'Failed to load salon details';
          _isSaloonLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading salon data: $e');
      }
      setState(() {
        _saloonError = 'Network error: $e';
        _isSaloonLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY SALOON',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            if (saloonData != null)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit-saloon',
                    arguments: {
                      'saloonData': saloonData,
                      'token': widget.token,
                    },
                  ).then((updated) {
                    if (updated == true) {
                      _loadSaloonDetails(widget.userData['id']);
                    }
                  });
                },
                child: Text(
                  'Edit Saloon',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 15),
        _isSaloonLoading
            ? Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _saloonError != null
                ? _buildSaloonErrorSection()
                : saloonData != null
                    ? _buildSaloonDetailsSection()
                    : _buildCreateSaloonPrompt(),
      ],
    );
  }

  Widget _buildSaloonDetailsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            saloonData!['name'] ?? 'Your Salon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          _buildSaloonInfoRow(Icons.description,
              saloonData!['description'] ?? 'No description'),
          SizedBox(height: 8),
          _buildSaloonInfoRow(
              Icons.location_on, saloonData!['address'] ?? 'No address'),
          SizedBox(height: 8),
          _buildSaloonInfoRow(
              Icons.phone, saloonData!['phone'] ?? 'No phone number'),
          SizedBox(height: 8),
          _buildSaloonInfoRow(Icons.email, saloonData!['email'] ?? 'No email'),
          SizedBox(height: 8),
          _buildSaloonInfoRow(Icons.access_time,
              'Open: ${saloonData!['opening_time'] ?? 'N/A'} - ${saloonData!['closing_time'] ?? 'N/A'}'),
          if ((saloonData!['services'] as List?)?.isNotEmpty ?? false) ...[
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services (${(saloonData!['services'] as List).length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add-service',
                      arguments: {
                        'saloonId': saloonData!['id'],
                        'token': widget.token,
                      },
                    ).then((result) {
                      if (result == true) {
                        _loadSaloonDetails(widget.userData['id']);
                      }
                    });
                  },
                  child: Text(
                    'Add Service',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...(saloonData!['services'] as List).map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: InkWell(
                    onTap: () {
                      final serviceModel = Service.fromJson(service);
                      Navigator.pushNamed(
                        context,
                        '/edit-service',
                        arguments: {
                          'service': serviceModel,
                          'saloonId': saloonData!['id'],
                          'token': widget.token,
                        },
                      ).then((result) {
                        if (result == true) {
                          _loadSaloonDetails(widget.userData['id']);
                        }
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'] ?? 'Service',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${service['duration'] ?? 0} minutes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '\$${service['price'] ?? '0'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ] else ...[
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No services added yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add-service',
                      arguments: {
                        'saloonId': saloonData!['id'],
                        'token': widget.token,
                      },
                    ).then((result) {
                      if (result == true) {
                        _loadSaloonDetails(widget.userData['id']);
                      }
                    });
                  },
                  child: Text(
                    'Add Service',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaloonInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildSaloonErrorSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            'Could not load salon details',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            _saloonError ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              _loadSaloonDetails(widget.userData['id']);
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateSaloonPrompt() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.store, color: AppColors.primaryDark, size: 40),
          SizedBox(height: 10),
          Text(
            'You haven\'t created a salon yet',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/create-saloon');
              },
              child: Text(
                'Create Salon',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
