import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/custom_form_text_field.dart';
import 'package:saloon_guide/widgets/custom_form_time_field.dart';
import 'package:saloon_guide/config/api_config.dart';

class EditSaloonScreen extends StatefulWidget {
  const EditSaloonScreen({Key? key}) : super(key: key);

  @override
  State<EditSaloonScreen> createState() => _EditSaloonScreenState();
}

class _EditSaloonScreenState extends State<EditSaloonScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();

  Map<String, dynamic>? _saloonData;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  String _successMessage = ''; // Added success message variable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only populate form fields if it hasn't been done already
    if (_nameController.text.isEmpty) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _saloonData = args['saloonData'];
        _token = args['token'];
        _populateFormFields();
      }
    }
  }

  void _populateFormFields() {
    if (_saloonData != null) {
      _nameController.text = _saloonData!['name'] ?? '';
      _descriptionController.text = _saloonData!['description'] ?? '';
      _addressController.text = _saloonData!['address'] ?? '';
      _phoneController.text = _saloonData!['phone'] ?? '';
      _emailController.text = _saloonData!['email'] ?? '';
      _websiteController.text = _saloonData!['website'] ?? '';

      // Format opening time to remove seconds
      String openingTime = _saloonData!['opening_time'] ?? '';
      if (openingTime.isNotEmpty && openingTime.length >= 5) {
        _openingTimeController.text =
            openingTime.substring(0, 5); // Take only HH:MM part
      } else {
        _openingTimeController.text = openingTime;
      }

      // Format closing time to remove seconds
      String closingTime = _saloonData!['closing_time'] ?? '';
      if (closingTime.isNotEmpty && closingTime.length >= 5) {
        _closingTimeController.text =
            closingTime.substring(0, 5); // Take only HH:MM part
      } else {
        _closingTimeController.text = closingTime;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Add listeners to monitor time field changes
    _openingTimeController.addListener(() {
      print('Opening time changed to: ${_openingTimeController.text}');
    });

    _closingTimeController.addListener(() {
      print('Closing time changed to: ${_closingTimeController.text}');
    });
  }

  // Make sure to update dispose to remove listeners
  @override
  void dispose() {
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

  Future<void> _updateSaloon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = ''; // Reset success message
    });

    // Validate time format before sending request
    if (!_validateTimeFormat(_openingTimeController.text) ||
        !_validateTimeFormat(_closingTimeController.text)) {
      setState(() {
        _errorMessage =
            "Opening and closing times must be in HH:MM format (24-hour)";
        _isLoading = false;
      });
      return;
    }

    // Debug prints to verify values before sending
    print('Sending opening time: ${_openingTimeController.text}');
    print('Sending closing time: ${_closingTimeController.text}');

    try {
      final requestBody = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
        'opening_time': _openingTimeController.text,
        'closing_time': _closingTimeController.text,
      };

      print('Request body: $requestBody');

      final response = await http.put(
        Uri.parse(ApiConfig.getSaloonUrl(_saloonData!['id'])),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print('Response: $responseData');

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          _successMessage =
              responseData['data']?['message'] ?? 'Salon updated successfully';
          _isLoading = false;
        });

        // Delay before navigating back
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(
              context, true); // Return true to indicate successful update
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ??
              (responseData['data'] != null
                  ? responseData['data']['message']
                  : null) ??
              'Failed to update salon details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  // Helper method to validate time format
  bool _validateTimeFormat(String time) {
    // Check if the string is empty
    if (time.isEmpty) {
      return false;
    }

    // Regular expression for HH:MM format (24-hour)
    final RegExp timeRegExp = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    return timeRegExp.hasMatch(time);
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
                      'Edit Salon Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
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
                          color: Colors.green.withOpacity(0.2),
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
                          ),
                          CustomFormTextField(
                            label: 'Address',
                            controller: _addressController,
                          ),
                          CustomFormTextField(
                            label: 'Phone',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          CustomFormTextField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          CustomFormTextField(
                            label: 'Website',
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
                              onPressed: _isLoading ? null : _updateSaloon,
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
                                      'Update Salon',
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
