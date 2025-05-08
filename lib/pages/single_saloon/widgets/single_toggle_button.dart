import 'package:flutter/material.dart';

class SingleToggleButton extends StatefulWidget {
  const SingleToggleButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onSelected,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  State<SingleToggleButton> createState() => _SingleToggleButtonState();
}

class _SingleToggleButtonState extends State<SingleToggleButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onSelected,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: widget.isSelected ? Colors.transparent : Colors.grey,
            width: widget.isSelected ? 0 : 1,
          ),
        ),
        backgroundColor: widget.isSelected ? Colors.white : Colors.black,
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          color: widget.isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
