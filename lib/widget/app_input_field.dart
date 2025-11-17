
import 'package:flutter/material.dart';

class AppInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType textInputType;
  const AppInputField({
    super.key, required this.hintText, required this.controller, required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(

      controller: TextEditingController(),
      keyboardType: textInputType,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,

        // Rounded Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50), // premium green
            width: 2,
          ),
        ),

      ),
    );
  }
}