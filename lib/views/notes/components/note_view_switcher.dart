import 'package:flutter/material.dart';
import 'package:note_app/views/notes/note_screen.dart';

class NoteViewSwitcher extends StatelessWidget {
  final NoteViewType currentView;
  final Function(NoteViewType) onViewChanged;

  const NoteViewSwitcher({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        currentView == NoteViewType.list ? Icons.grid_view : Icons.list,
      ),
      onPressed: () {
        onViewChanged(
          currentView == NoteViewType.list
              ? NoteViewType.grid
              : NoteViewType.list,
        );
      },
    );
  }
}
