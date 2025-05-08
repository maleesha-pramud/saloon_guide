import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/pages/single_saloon/models/time_selection_model.dart';

class TimeSelectionCard extends StatefulWidget {
  const TimeSelectionCard(
      {super.key, required this.timeData, required this.selectedTime});

  final TimeSelectionModel timeData;
  final TimeOfDay? selectedTime;

  @override
  State<TimeSelectionCard> createState() => _TimeSelectionCardState();
}

class _TimeSelectionCardState extends State<TimeSelectionCard> {
  bool _isSelected() {
    return widget.timeData.time.hour == widget.selectedTime?.hour &&
        widget.timeData.time.minute == widget.selectedTime?.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 100,
          decoration: BoxDecoration(
            color: _isSelected() ? Colors.white : AppColors.secondaryLight2,
            border: Border.all(
              color: _isSelected() ? Colors.white : Colors.white24,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.timeData.timeString,
                style: TextStyle(
                  color: _isSelected() ? Colors.black : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
