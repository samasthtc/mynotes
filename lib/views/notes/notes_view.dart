import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "📓 Your Notes",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
            // color: const Color.fromARGB(255, 69, 1, 81),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (action) async {
              devtools.log('$action');
              switch (action) {
                case MenuAction.logout:
                  final navigator = Navigator.of(context);
                  final shouldLogout = await showLogoutDialog(context);

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
                child: Text(
                  "Logout",
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(
                              id: note.id,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    // return const Text("Waiting for all notes...");
                    // final notes = snapshot.data;
                    // return ListView.builder(
                    //   itemCount: notes?.length,
                    //   itemBuilder: (context, index) {
                    //     final note = notes[index];
                    //     return ListTile(
                    //       title: Text(note.title),
                    //       subtitle: Text(note.content),
                    //     );
                    //   },
                    // );
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              devtools.log('Loading Notes...');
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
