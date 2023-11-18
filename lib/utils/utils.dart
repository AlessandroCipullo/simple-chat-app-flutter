import 'package:flutter/material.dart';

class Utils {
  static Future<void> showCircularProgress(BuildContext context) {
    return showDialog(
        context: context,
        builder: ((context) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }));
  }

  static SnackBar createSnackbar(String msg) {
    return SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3));
  }
}
