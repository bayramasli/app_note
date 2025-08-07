import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için

import '../../models/note_model.dart';
import '../../services/database/database_service.dart';

class NoteScreen extends StatefulWidget {
  final int userId;

  const NoteScreen({super.key, required this.userId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final dbHelper = DatabaseHelper();
  List<NoteModel> notes = [];

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final userNotes = await dbHelper.getNotesByUserId(widget.userId);
    setState(() {
      notes = userNotes;
    });
  }

  void _addNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlık ve içerik girin')),
      );
      return;
    }

    final newNote = NoteModel(
      userId: widget.userId,
      title: title,
      content: content,
      date: DateTime.now().toIso8601String(),
    );

    await dbHelper.addNote(newNote);
    titleController.clear();
    contentController.clear();
    _loadNotes();
  }

  void _deleteNote(int id) async {
    await dbHelper.deleteNote(id);
    _loadNotes();
  }

  String _formatDate(String isoDate) {
    try {
      final parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yyyy – HH:mm').format(parsedDate);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notlarım")),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12.0),
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Başlık",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: "İçerik",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add),
                    label: const Text("Not Ekle"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text("Henüz not eklenmemiş"))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(note.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.content),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(note.date),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(note.id!),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
