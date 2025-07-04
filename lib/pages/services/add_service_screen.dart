import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/custom_form_text_field.dart';
import 'package:saloon_guide/config/api_config.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  int? _saloonId;
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _saloonId = args['saloonId'];
      _token = args['token'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _addService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_saloonId == null || _token == null) {
      setState(() {
        _errorMessage = 'Invalid salon or authentication data';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addServiceUrl(_saloonId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'duration': int.parse(_durationController.text.trim()),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Add service response: $responseData');
      }

      if (response.statusCode == 201 && responseData['status'] == true) {
        setState(() {
          _successMessage =
              responseData['message'] ?? 'Service added successfully';
        });

        // Clear form after successful creation
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _durationController.clear();

        // Navigate back after delay - go to settings/home instead of previous screen
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            // Navigate to settings screen to show the updated salon details
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/settings',
              (route) => route.settings.name == '/home',
            );
          }
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to add service';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding service: $e');
      }
      setState(() {
        _errorMessage = 'Network error: $e';
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
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Service',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Add your first service to complete your salon setup',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
                        children: [
                          CustomFormTextField(
                            label: 'Service Name',
                            controller: _nameController,
                            prefixIcon: Icon(Icons.content_cut),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter service name';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Description',
                            controller: _descriptionController,
                            maxLines: 3,
                            prefixIcon: Icon(Icons.description),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter service description';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Price (USD)',
                            controller: _priceController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icon(Icons.attach_money),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter service price';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                          CustomFormTextField(
                            label: 'Duration (minutes)',
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icon(Icons.schedule),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter service duration';
                              }
                              final duration = int.tryParse(value);
                              if (duration == null || duration <= 0) {
                                return 'Please enter a valid duration in minutes';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          // Skip adding service and go to settings
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/settings',
                                            (route) =>
                                                route.settings.name == '/home',
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.white70),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: Text(
                                    'Skip for Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _addService,
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        AppColors.primaryDark),
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.symmetric(vertical: 15)),
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          'Add Service',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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
