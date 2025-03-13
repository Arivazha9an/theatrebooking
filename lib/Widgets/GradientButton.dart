import 'package:flutter/material.dart';
import 'package:ticket_booking/const/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 220,
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              blue,
              lightBlue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10), // Slightly rounded edges
          boxShadow: [
            BoxShadow(
              color:  black,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color:  white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
