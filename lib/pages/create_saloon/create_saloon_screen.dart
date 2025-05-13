import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/custom_text_field.dart';

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

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final String formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

        if (isOpeningTime) {
          _openingTimeController.text = formattedTime;
        } else {
          _closingTimeController.text = formattedTime;
        }
      });
    }
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
        Uri.parse('http://localhost:3000/api/v1/saloons'),
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
    } catch (error) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              CustomBackButton(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Saloon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Form fields
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Saloon Name',
                        hintText: 'Elegant Cuts Salon',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter saloon name';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText:
                            'Premier hair salon with professional stylists',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: _addressController,
                        labelText: 'Address',
                        hintText: '123 Main St, City, Country',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: '0701234567',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'contact@elegantcuts.com',
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

                      CustomTextField(
                        controller: _websiteController,
                        labelText: 'Website (Optional)',
                        hintText: 'https://elegantcuts.com',
                        keyboardType: TextInputType.url,
                      ),

                      // Time selection fields
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, true),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: _openingTimeController,
                                  labelText: 'Opening Time',
                                  hintText: '09:00',
                                  suffixIcon: Icon(Icons.access_time),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, false),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: _closingTimeController,
                                  labelText: 'Closing Time',
                                  hintText: '17:00',
                                  suffixIcon: Icon(Icons.access_time),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Success or error messages
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      if (_successMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _successMessage,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      SizedBox(height: 30),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.black),
                          ),
                          onPressed: _isLoading ? null : _createSaloon,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  'Create Saloon',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
