import 'package:flutter/material.dart';
import 'package:saloon_guide/pages/single_saloon/models/date_selection_model.dart';
import 'package:saloon_guide/pages/single_saloon/widgets/date_selection_card.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class DateSelection extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  DateSelection(
      {super.key, required this.onDateSelected, required this.selectedDate});

  final List<DateSelectionModel> _dateSelectionDataList = List.generate(
    30,
    (index) {
      final date = DateTime.now().add(Duration(days: index));
      return DateSelectionModel(
        dateNo: int.parse(DateFormat('dd').format(date)),
        dateString: DateFormat('EEE').format(date).toUpperCase(),
        dateTime: date, // Pass the actual date
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _dateSelectionDataList.map((dateSelectionModel) {
              return GestureDetector(
                onTap: () => onDateSelected(dateSelectionModel.dateTime),
                child: DateSelectionCard(
                  dateData: dateSelectionModel,
                  selectedDate: selectedDate, // Pass selectedDate correctly
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
