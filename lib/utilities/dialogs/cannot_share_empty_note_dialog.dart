import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing Error',
    content:
        'Cannot share an empty note! Please write something before sharing.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
