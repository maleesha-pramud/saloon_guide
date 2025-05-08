import 'package:flutter/material.dart';
import 'package:saloon_guide/pages/single_saloon/models/time_selection_model.dart';
import 'package:saloon_guide/pages/single_saloon/widgets/time_selection_card.dart';
import 'package:intl/intl.dart';

class TimeSelection extends StatelessWidget {
  final Function(DateTime) onTimeSelected;
  final TimeOfDay? selectedTime;

  TimeSelection(
      {super.key, required this.onTimeSelected, required this.selectedTime});

  final List<TimeSelectionModel> _timeSelectionDataList = List.generate(
    30, // Generate 30 time slots
    (index) {
      final time = DateTime(0, 0, 0, 8, 0).add(Duration(minutes: index * 30));
      return TimeSelectionModel(
        timeString: DateFormat('hh:mm a').format(time),
        time: time, // Pass the actual time
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIME',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _timeSelectionDataList.map((timeSelectionModel) {
              return GestureDetector(
                onTap: () => onTimeSelected(timeSelectionModel.time),
                child: TimeSelectionCard(
                  timeData: timeSelectionModel,
                  selectedTime: selectedTime,
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
