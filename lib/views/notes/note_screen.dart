import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notlar')),
      body: const Center(
        child: Text('Notlar Ekranı'),
      ),
    );
  }
}
