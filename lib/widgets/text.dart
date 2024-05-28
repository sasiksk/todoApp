import 'package:flutter/material.dart';

class TextFormat {
  Widget formatText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 4, 42, 124),
      ),
    );
  }
}
