import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/custom_form_text_field.dart';
import 'package:saloon_guide/widgets/custom_form_time_field.dart';
import 'package:saloon_guide/config/api_config.dart';

class CreateSaloonScreen extends StatefulWidget {
  const CreateSaloonScreen({super.key});

  @override
  State<CreateSaloonScreen> createState() => _CreateSaloonScreenState();
}

class _CreateSaloonScreenState extends State<CreateSaloonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _openingTimeController =
      TextEditingController(text: '09:00');
  final TextEditingController _closingTimeController =
      TextEditingController(text: '17:00');

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  // Helper method to validate time format
  bool _validateTimeFormat(String time) {
    if (time.isEmpty) {
      return false;
    }
    final RegExp timeRegExp = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    return timeRegExp.hasMatch(time);
  }

  Future<void> _createSaloon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse(ApiConfig.createSaloonUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'website': _websiteController.text,
          'opening_time': _openingTimeController.text,
          'closing_time': _closingTimeController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      print('responseData: $responseData');

      if (response.statusCode == 201 && responseData['status'] == true) {
        setState(() {
          _successMessage =
              responseData['data']['message'] ?? 'Saloon created successfully';
        });

        // Clear form after successful creation
        _nameController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _phoneController.clear();
        _emailController.clear();
        _websiteController.clear();
        _openingTimeController.text = '09:00';
        _closingTimeController.text = '17:00';

        // Optional: Navigate back or to a confirmation page
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to create saloon';
        });
      }

      // Add a 1-second delay
      // await Future.delayed(const Duration(seconds: 1));

      // Safely scroll to top if controller is attached
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _errorMessage = 'Network error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBackButton(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Salon',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage,
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFormTextField(
                            label: 'Salon Name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter salon name';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Description',
                            controller: _descriptionController,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Address',
                            controller: _addressController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter address';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Phone',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Website (Optional)',
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                          ),
                          CustomFormTimeField(
                            label: 'Opening Time',
                            controller: _openingTimeController,
                            validateTimeFormat: _validateTimeFormat,
                          ),
                          CustomFormTimeField(
                            label: 'Closing Time',
                            controller: _closingTimeController,
                            validateTimeFormat: _validateTimeFormat,
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createSaloon,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primaryDark),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(vertical: 15)),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Create Salon',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
