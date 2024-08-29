import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Main UI"),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (action) async {
                devtools.log('$action');
                switch (action) {
                  case MenuAction.logout:
                    final navigator = Navigator.of(context);
                    final shouldLogout = await showLogOutDialog(context);

                    if (shouldLogout) {
                      await AuthService.firebase().logout();
                      navigator.pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
              ],
            ),
          ]),
      body: const Column(children: [
        Text("Welcome to the main UI"),
      ]),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Yes"),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}
