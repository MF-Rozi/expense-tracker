import 'package:expense_tracker/core/utils/constants.dart';
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void displayFlash(String message) {}

  void showSnackbar({
    required String message,
    void Function()? action,
    String? actionText,
  }) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        // action: action == null && actionText != null
        //     ? null
        //     : SnackBarAction(label: actionText!, onPressed: action!),
      ),
    );
  }

  ThemeData get theme => Theme.of(this);
}
