import 'package:flutter/material.dart';

class MakeDialog {
  static void build(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
