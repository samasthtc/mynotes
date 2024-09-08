import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

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
      duration: const Duration(seconds: 3), // Control the speed of rotation
    )..repeat(); // Continuously repeat the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
              ), // Add margins to create spacing between tiles
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF8C59E2),
                    Color(0xFFB3A1F8),
                  ], // Gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment
                      .bottomRight, // Start with top-left to bottom-right
                  transform: GradientRotation(_controller.value * 2 * 3.1416),
                  // Rotate the gradient over time
                ),
                borderRadius:
                    BorderRadius.circular(16.0), // Round the gradient border
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
                      .surface, // Background color for the content
                  borderRadius: BorderRadius.circular(
                      14.5), // Smaller radius for inner content
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
                  trailing: IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        widget.onDeleteNote(note, index);
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 16.0,
                    right: 8.0,
                  ), // Adjust padding for the content
                  onTap: () {
                    widget.onTap(note, index);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
