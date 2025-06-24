import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/config/api_config.dart';
import 'package:saloon_guide/pages/single_saloon/models/toggle_buttons_model.dart';
import 'package:intl/intl.dart';

// import 'package:saloon_guide/pages/single_saloon/widgets/blured_title_bar.dart';
import 'package:saloon_guide/pages/single_saloon/widgets/date_selection.dart';
import 'package:saloon_guide/pages/single_saloon/widgets/single_toggle_button.dart';
import 'package:saloon_guide/pages/single_saloon/widgets/time_selection.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';
import 'package:saloon_guide/widgets/like_button.dart';

class SingleSaloonScreen extends StatefulWidget {
  const SingleSaloonScreen({super.key});

  @override
  State<SingleSaloonScreen> createState() => _SingleSaloonScreenState();
}

class _SingleSaloonScreenState extends State<SingleSaloonScreen> {
  final _storage = const FlutterSecureStorage();

  // Salon data variables
  Map<String, dynamic>? _saloonData;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int? _saloonId;
  List<ToggleButtonsModel> toggleButtonsData = [
    ToggleButtonsModel(
      title: 'Services',
      isSelected: true,
    ),
    ToggleButtonsModel(
      title: 'Booking',
      isSelected: false,
    ),
    ToggleButtonsModel(
      title: 'Reviews',
      isSelected: false,
    ),
  ];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<int> _selectedServiceIds = [];

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
    if (args != null && args['saloonId'] != null) {
      _saloonId = args['saloonId'];
      _fetchSaloonData();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Salon ID not provided';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSaloonData() async {
    if (_saloonId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse(ApiConfig.getSaloonUrl(_saloonId!)),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Salon data response: $responseData');
      }

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          _saloonData = responseData['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              responseData['message'] ?? 'Failed to load salon details';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching salon data: $e');
      }
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  void _handleToggleButtonSelected(int index) {
    setState(() {
      for (int i = 0; i < toggleButtonsData.length; i++) {
        toggleButtonsData[i].isSelected = i == index;
      }
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _handleServiceSelected(int serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  List<dynamic> _getServices() {
    return _saloonData?['services'] ?? [];
  }

  double _getTotalPrice() {
    double total = 0.0;
    final services = _getServices();
    for (int serviceId in _selectedServiceIds) {
      final service = services.firstWhere(
        (service) => service['id'] == serviceId,
        orElse: () => null,
      );
      if (service != null) {
        final price = service['price'];
        if (price is String) {
          total += double.tryParse(price) ?? 0.0;
        } else if (price is num) {
          total += price.toDouble();
        }
      }
    }
    return total;
  }

  String _getFormattedDate() {
    return _selectedDate != null
        ? DateFormat('EEEE, MMMM d').format(_selectedDate!)
        : 'Select a date';
  }

  String _getFormattedTime() {
    return _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Select a time';
  }

  String _getSaloonName() {
    return _saloonData?['name'] ?? 'Loading...';
  }

  String _getSaloonOpeningHours() {
    if (_saloonData == null) return 'Loading...';
    final openingTime = _saloonData!['opening_time'] ?? '';
    final closingTime = _saloonData!['closing_time'] ?? '';

    if (openingTime.isNotEmpty && closingTime.isNotEmpty) {
      // Format times to remove seconds if present
      final formattedOpening =
          openingTime.length >= 5 ? openingTime.substring(0, 5) : openingTime;
      final formattedClosing =
          closingTime.length >= 5 ? closingTime.substring(0, 5) : closingTime;
      return 'Open: $formattedOpening - $formattedClosing';
    }
    return 'Hours not available';
  }

  Future<void> _bookAppointment() async {
    if (_selectedServiceIds.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'auth_token');

      // Combine date and time into a proper DateTime
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final requestBody = {
        'saloon_id': _saloonId,
        'service_ids': _selectedServiceIds,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'notes': 'Booked through mobile app',
      };

      if (kDebugMode) {
        print('Booking request: $requestBody');
      }
      final response = await http.post(
        Uri.parse(ApiConfig.appointmentsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Booking response: $responseData');
      }

      if (response.statusCode == 201 && responseData['status'] == true) {
        // Booking successful, navigate to complete screen
        Navigator.pushReplacementNamed(context, '/complete');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(responseData['message'] ?? 'Failed to book appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error booking appointment: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: Failed to book appointment'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load salon',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSaloonData,
                        child: Text('Try Again'),
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/tempory/1.jpg',
                  width: double.infinity,
                  height: 270,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // Updated BluredTitleBar with dynamic data
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSaloonName(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 2),
                            const Text(
                              '5.0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Row(
                              children: [
                                const Text(
                                  '(500)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  _getSaloonOpeningHours(),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Back button positioned at the top
            Positioned(
              top: 15,
              left: 0,
              child: CustomBackButton(),
            ),

            LikeButton(
              topPosition: 160,
              rightPosition: 0,
            ),

            // Main content
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              bottom:
                  160, // Add bottom constraint to leave space for bottom widget
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (int i = 0; i < toggleButtonsData.length; i++)
                            SingleToggleButton(
                              title: toggleButtonsData[i].title,
                              isSelected: toggleButtonsData[i].isSelected,
                              onSelected: () => _handleToggleButtonSelected(i),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Show content based on selected tab
                      if (toggleButtonsData[0].isSelected) ...[
                        // Services tab content
                        if (_getServices().isNotEmpty) ...[
                          Text(
                            'Available Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                          ...(_getServices()
                              .map((service) => Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: _selectedServiceIds
                                              .contains(service['id'])
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.grey[900],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedServiceIds
                                                .contains(service['id'])
                                            ? Colors.blue
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          _handleServiceSelected(service['id']),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service['name'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  service['description'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.attach_money,
                                                      color: Colors.green,
                                                      size: 16,
                                                    ),
                                                    Text(
                                                      '${service['price'] ?? '0'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    SizedBox(width: 15),
                                                    Icon(
                                                      Icons.schedule,
                                                      color: Colors.orange,
                                                      size: 16,
                                                    ),
                                                    Text(
                                                      ' ${service['duration'] ?? '0'} min',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            _selectedServiceIds
                                                    .contains(service['id'])
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: _selectedServiceIds
                                                    .contains(service['id'])
                                                ? Colors.blue
                                                : Colors.white54,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList()),
                          if (_selectedServiceIds.isNotEmpty) ...[
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.green, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total (${_selectedServiceIds.length} services)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '\$${_getTotalPrice().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.content_cut,
                                  size: 60,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'No services available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else if (toggleButtonsData[1].isSelected) ...[
                        // Booking tab content
                        Text(
                          'Select Date & Time',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        DateSelection(
                          selectedDate: _selectedDate,
                          onDateSelected: _handleDateSelected,
                        ),
                        SizedBox(height: 30),
                        TimeSelection(
                          selectedTime: _selectedTime,
                          onTimeSelected: (time) => _handleTimeSelected(
                            TimeOfDay(hour: time.hour, minute: time.minute),
                          ),
                        ),
                      ] else if (toggleButtonsData[2].isSelected) ...[
                        // Reviews tab content
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.star_outline,
                                size: 60,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Reviews coming soon',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Show salon details only on Services tab
                      if (toggleButtonsData[0].isSelected &&
                          _saloonData != null) ...[
                        SizedBox(height: 20),
                        Divider(color: Colors.white24),
                        SizedBox(height: 20),
                        Text(
                          'About Salon',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _saloonData!['description'] ??
                              'No description available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _saloonData!['address'] ??
                                    'No address available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.white70, size: 16),
                            SizedBox(width: 5),
                            Text(
                              _saloonData!['phone'] ?? 'No phone available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 30), // Add some bottom padding
                    ],
                  ),
                ),
              ),
            ), // Bottom widget
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 160,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      if (toggleButtonsData[1].isSelected) ...[
                        // Booking tab - show date and time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      _getFormattedDate(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _getFormattedTime(),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ] else if (toggleButtonsData[0].isSelected) ...[
                        // Services tab - show selected services info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.content_cut,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      _selectedServiceIds.isEmpty
                                          ? 'Select services'
                                          : '${_selectedServiceIds.length} service${_selectedServiceIds.length > 1 ? 's' : ''} selected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedServiceIds.isNotEmpty)
                              Text(
                                '\$${_getTotalPrice().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ] else ...[
                        // Reviews tab or default
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 7),
                            Text(
                              '5.0 Rating (500 reviews)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (toggleButtonsData[0].isSelected &&
                                      _selectedServiceIds.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please select at least one service'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  if (toggleButtonsData[0].isSelected &&
                                      _selectedServiceIds.isNotEmpty) {
                                    // Switch to booking tab when services are selected
                                    _handleToggleButtonSelected(1);
                                    return;
                                  }
                                  if (toggleButtonsData[1].isSelected &&
                                      (_selectedDate == null ||
                                          _selectedTime == null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please select date and time'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  // Book the appointment when all conditions are met
                                  if (toggleButtonsData[1].isSelected &&
                                      _selectedDate != null &&
                                      _selectedTime != null &&
                                      _selectedServiceIds.isNotEmpty) {
                                    _bookAppointment();
                                  }
                                },
                          style: ButtonStyle(),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                )
                              : Text(
                                  toggleButtonsData[0].isSelected
                                      ? 'Continue to Booking'
                                      : toggleButtonsData[1].isSelected
                                          ? 'Book Now'
                                          : 'View Reviews',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
