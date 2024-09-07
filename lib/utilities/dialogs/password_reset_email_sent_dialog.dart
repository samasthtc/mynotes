import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'An email has been sent to reset your password. Please check your email for more information.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
