import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_colors.dart';

class CustomFormTimeField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool Function(String) validateTimeFormat;

  const CustomFormTimeField({
    super.key,
    required this.label,
    required this.controller,
    required this.validateTimeFormat,
  });

  @override
  State<CustomFormTimeField> createState() => _CustomFormTimeFieldState();
}

class _CustomFormTimeFieldState extends State<CustomFormTimeField> {
  late String _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.controller.text;

    // Add listener to keep display value in sync with controller
    widget.controller.addListener(_updateDisplayValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateDisplayValue);
    super.dispose();
  }

  void _updateDisplayValue() {
    if (_displayValue != widget.controller.text) {
      setState(() {
        _displayValue = widget.controller.text;
      });
    }
  }

  // Helper method to parse time string to TimeOfDay
  TimeOfDay? _parseTimeString(String timeString) {
    if (timeString.isEmpty) return null;

    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing time: $e');
      }
    }

    return null;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeString(widget.controller.text) ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              surface: AppColors.secondaryLight,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format time as HH:MM (ensuring proper 24-hour format)
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final newTimeValue = '$hour:$minute';

      if (kDebugMode) {
        print('Time picked: $newTimeValue');
      }

      // Update both the controller and our display value
      setState(() {
        _displayValue = newTimeValue;
        widget.controller.text = newTimeValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the direct controller instead of a local TextEditingController
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () => _selectTime(context),
        child: AbsorbPointer(
          child: TextFormField(
            controller: widget.controller,
            readOnly: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.secondaryLight,
              suffixIcon: Icon(Icons.access_time),
              helperText: 'Format: HH:MM (24-hour)',
              helperStyle: TextStyle(color: Colors.grey),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (!widget.validateTimeFormat(value)) {
                return 'Must be in HH:MM format (24-hour)';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
