import 'package:flutter/material.dart';
import 'package:saloon_guide/pages/single_saloon/models/toggle_buttons_model.dart';
import 'package:intl/intl.dart'; // Add this import for date and time formatting

import 'package:saloon_guide/pages/single_saloon/widgets/blured_title_bar.dart';
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
  List<ToggleButtonsModel> toggleButtonsData = [
    ToggleButtonsModel(
      title: 'Booking',
      isSelected: true,
    ),
    ToggleButtonsModel(
      title: 'Reviews',
      isSelected: false,
    ),
  ];

  DateTime? _selectedDate; // Separate variable for selected date
  TimeOfDay? _selectedTime; // Separate variable for selected time

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

  @override
  Widget build(BuildContext context) {
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

              BluredTitleBar(),

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
                      const Text(
                        'August 22',
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
