import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

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
              Navigator.of(context).pushNamed(
                createOrUpdateNoteRoute,
              );
            },
            icon: const Icon(Icons.add),
            // color: const Color.fromARGB(255, 69, 1, 81),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (action) async {
              devtools.log('$action');
              switch (action) {
                case MenuAction.logout:
                  // final navigator = Navigator.of(context);
                  final shouldLogout = await showLogoutDialog(context);

                  if (shouldLogout) {
                    if (!context.mounted) {
                      return;
                    }
                    context.read<AuthBloc>().add(const AuthEventLogout());
                    // await AuthService.firebase().logout();
                    // navigator.pushNamedAndRemoveUntil(
                    //   loginRoute,
                    //   (_) => false,
                    // );
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
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note, index) async {
                    await _notesService.deleteNote(
                      documentId: note.documentId,
                    );
                  },
                  onTap: (note, index) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: [
                        note,
                        index,
                      ],
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
