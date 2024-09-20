import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';

typedef NoteCallback = void Function(CloudNote note, int? index);

class NotesListView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: widget.notes.length,
        itemBuilder: (context, index) {
          final note = widget.notes.elementAt(widget.notes.length - 1 - index);
          final text = note.text;
          String title = note.text;
          String subtitle = 'No additional text';
          const maxTitleLength = 30;

          if (text.length > maxTitleLength) {
            int lastSpaceIndex =
                text.substring(0, maxTitleLength).lastIndexOf(' ');

            if (lastSpaceIndex != -1) {
              title = text.substring(0, lastSpaceIndex);
              subtitle = text.substring(lastSpaceIndex + 1);
            } else {
              title = text.substring(0, maxTitleLength);
              subtitle = text.substring(maxTitleLength);
            }

            title += '...';
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF8C59E2),
                      Color(0xFFB3A1F8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(_controller.value * 2 * 3.1416),
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.12),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface, // bg color for the content
                    borderRadius: BorderRadius.circular(
                        14.5), // smaller radius for inner content
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.45,
                      openThreshold: 0.15,
                      closeThreshold: 0.15,
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            await deleteNote(context, note, index);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          iconSize: 32,
                          padding: const EdgeInsets.all(0),
                        ),
                        SlidableAction(
                          onPressed: (_) async {
                            if (text.isEmpty) {
                              await showCannotShareEmptyNoteDialog(context);
                              return;
                            } else {
                              Share.share('$text\n\n\nShared via MyNotes');
                            }
                          },
                          backgroundColor: const Color(0xFF4F91F3),
                          foregroundColor: Colors.white,
                          icon: Icons.ios_share,
                          iconSize: 32,
                          padding: const EdgeInsets.all(0),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 16.0,
                        right: 8.0,
                      ),
                      onTap: () {
                        widget.onTap(note, index);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteNote(
      BuildContext context, CloudNote note, int index) async {
    final shouldDelete = await showDeleteDialog(context);
    if (shouldDelete) {
      widget.onDeleteNote(note, index);
    }
  }

  // void _handleOpen({required SlidableController controller}) {
  //   controller.openEndActionPane();
  // }

  void _handleClose({required SlidableController controller}) {
    controller.close();
  }
}
