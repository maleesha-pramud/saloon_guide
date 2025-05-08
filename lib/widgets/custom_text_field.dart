import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.labelText,
    this.hintText = '',
  });

  final TextEditingController _controller = TextEditingController();
  final String value;
  final String hintText;
  final String? labelText;
  final Function onValueChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 5),
        ],
        TextField(
          controller: _controller,
          onChanged: (value) => onValueChange(value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white12, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
