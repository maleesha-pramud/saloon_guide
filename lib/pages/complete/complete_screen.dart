import 'package:flutter/material.dart';
import 'package:saloon_guide/pages/complete/widgets/review_circle_button.dart';
import 'package:saloon_guide/widgets/custom_back_button.dart';

class CompleteScreen extends StatefulWidget {
  const CompleteScreen({super.key});

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  String _email = '';
  String _password = '';

  void onEmailChanged(String value) {
    _email = value;
  }

  void onPasswordChanged(String value) {
    _password = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            CustomBackButton(),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/permanent/complete.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Completed Appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Your appointment ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        TextSpan(
                          text: 'have been completed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              '. Maleesha\'s Saloon is marked as completed your appointment',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReviewCircleButton(
                        icon: Icons.clean_hands,
                        labelText: 'Clean',
                      ),
                      ReviewCircleButton(
                        icon: Icons.waving_hand,
                        labelText: 'Friendly',
                      ),
                      ReviewCircleButton(
                        icon: Icons.schedule,
                        labelText: 'On-Time',
                      ),
                      ReviewCircleButton(
                        icon: Icons.psychology,
                        labelText: 'Educated',
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
