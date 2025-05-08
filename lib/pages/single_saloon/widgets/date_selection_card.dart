import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/pages/single_saloon/models/date_selection_model.dart';

class DateSelectionCard extends StatefulWidget {
  const DateSelectionCard(
      {super.key, required this.dateData, required this.selectedDate});

  final DateSelectionModel dateData;
  final DateTime? selectedDate;

  @override
  State<DateSelectionCard> createState() => _DateSelectionCardState();
}

class _DateSelectionCardState extends State<DateSelectionCard> {
  bool _isSelected() {
    return widget.dateData.dateTime.day == widget.selectedDate?.day &&
        widget.dateData.dateTime.month == widget.selectedDate?.month &&
        widget.dateData.dateTime.year == widget.selectedDate?.year;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 90,
          width: 70,
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
                widget.dateData.dateNo
                    .toString()
                    .padLeft(2, '0'), // Ensure two digits
                style: TextStyle(
                  color: _isSelected() ? Colors.black : Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.dateData.dateString,
                style: TextStyle(
                  color: _isSelected() ? Colors.black : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
