import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/custom_form_text_field.dart';
import 'package:saloon_guide/config/api_config.dart';
import 'package:saloon_guide/models/service/service.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDeleting = false;
  String _errorMessage = '';
  String _successMessage = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  Service? _service;
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
      _service = args['service'];
      _saloonId = args['saloonId'];
      _token = args['token'];
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    if (_service != null) {
      _nameController.text = _service!.name;
      _descriptionController.text = _service!.description;
      _priceController.text = _service!.price.toString();
      _durationController.text = _service!.duration.toString();
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

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_service == null || _saloonId == null || _token == null) {
      setState(() {
        _errorMessage = 'Invalid service or authentication data';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await http.put(
        Uri.parse(ApiConfig.updateServiceUrl(_saloonId!, _service!.id)),
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
        print('Update service response: $responseData');
      }

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          _successMessage =
              responseData['message'] ?? 'Service updated successfully';
        });

        // Navigate back after delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to update service';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating service: $e');
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

  Future<void> _deleteService() async {
    if (_service == null || _saloonId == null || _token == null) {
      setState(() {
        _errorMessage = 'Invalid service or authentication data';
      });
      return;
    }

    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryLight,
        title: Text('Delete Service', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${_service!.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteServiceUrl(_saloonId!, _service!.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Delete service response: $responseData');
      }

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          _successMessage =
              responseData['message'] ?? 'Service deleted successfully';
        });

        // Navigate back after delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to delete service';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting service: $e');
      }
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isDeleting = false;
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
                      'Edit Service',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Update your service details below',
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
                                  onPressed: (_isLoading || _isDeleting)
                                      ? null
                                      : _deleteService,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: _isDeleting
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.red),
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: (_isLoading || _isDeleting)
                                      ? null
                                      : _updateService,
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
                                          'Update Service',
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
