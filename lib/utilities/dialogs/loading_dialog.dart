import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = Dialog(
    backgroundColor: Colors.transparent,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.inversePrimary,
          strokeCap: StrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}
