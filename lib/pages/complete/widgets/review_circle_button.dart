import 'package:flutter/material.dart';

class ReviewCircleButton extends StatefulWidget {
  const ReviewCircleButton(
      {super.key, required this.icon, required this.labelText});

  final IconData icon;
  final String labelText;

  @override
  State<ReviewCircleButton> createState() => _ReviewCircleButtonState();
}

class _ReviewCircleButtonState extends State<ReviewCircleButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white24),
          ),
          padding: EdgeInsets.all(20),
          icon: Icon(
            widget.icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.labelText,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        )
      ],
    );
  }
}
