import 'package:flutter/material.dart';

Future<void> customDialog(BuildContext context, bool isWidgetDialog,
    {Widget? widget, String? message}) {
  return showDialog(
    barrierColor: Colors.black54,
    context: context,
    builder: (ctx) {
      if (isWidgetDialog) {
        return widget!;
      } else {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        );
      }
    },
  );
}
