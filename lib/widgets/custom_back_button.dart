import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: BackButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white10),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
    );
  }
}
