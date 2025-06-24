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
        child: SingleChildScrollView(
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
                  SizedBox(height: MediaQuery.of(context).size.height - 270),
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

                      // Show salon details
                      if (_saloonData != null) ...[
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

                      SizedBox(height: 20),
                      const Text(
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
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ),

              // Bottom widget
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
                                      _getFormattedDate(), // Use formatted date
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
                              _getFormattedTime(), // Use formatted time
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/complete');
                            },
                            style: ButtonStyle(),
                            child: Text(
                              'Book Now',
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
      ),
    );
  }
}
