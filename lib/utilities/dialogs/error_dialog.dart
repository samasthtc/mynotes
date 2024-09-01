import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occured',
    content: content,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
