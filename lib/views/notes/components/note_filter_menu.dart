import 'package:flutter/material.dart';
import 'package:note_app/views/notes/note_screen.dart';

class NoteFilterMenu extends StatelessWidget {
  final NoteFilterType currentFilter;
  final Function(NoteFilterType) onFilterSelected;

  const NoteFilterMenu({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NoteFilterType>(
      icon: const Icon(Icons.filter_alt),
      onSelected: onFilterSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: NoteFilterType.all,
          child: Text('Tüm Notlar'),
        ),
        const PopupMenuItem(
          value: NoteFilterType.personal,
          child: Text('Kişisel'),
        ),
        const PopupMenuItem(
          value: NoteFilterType.shared,
          child: Text('Paylaşılan'),
        ),
        const PopupMenuItem(
          value: NoteFilterType.team,
          child: Text('Takım'),
        ),
      ],
    );
  }
}
