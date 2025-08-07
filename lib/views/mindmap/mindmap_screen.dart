import 'package:flutter/material.dart';

class MindMapScreen extends StatelessWidget {
  const MindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bağlantılı Notlar')),
      body: const Center(
        child: Text('Bağlantılı Notlar Ekranı'),
      ),
    );
  }
}
