import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/note_model.dart';
import '../../services/database/database_service.dart';
import '../home/drawer_menu_widget.dart';
import 'package:note_app/views/notes/components/export.dart';

class NoteScreen extends StatefulWidget {
  final int userId;

  const NoteScreen({super.key, required this.userId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final dbHelper = DatabaseHelper();
  List<NoteModel> notes = [];
  List<NoteModel> filteredNotes = [];
  String searchQuery = '';
  NoteFilterType currentFilter = NoteFilterType.all;
  NoteViewType currentView = NoteViewType.list;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final userNotes = await dbHelper.getNotesByUserId(widget.userId);
    setState(() {
      notes = userNotes;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredNotes = notes.where((note) {
        final matchesSearch =
            note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                note.content.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesFilter = currentFilter == NoteFilterType.all ||
            (currentFilter == NoteFilterType.personal && note.isPersonal) ||
            (currentFilter == NoteFilterType.shared && note.isShared) ||
            (currentFilter == NoteFilterType.team && note.isTeam);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  String _formatDate(String isoDate) {
    try {
      return DateFormat('dd.MM.yyyy – HH:mm').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildNoteCard(NoteModel note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () => _openNoteDetail(note),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.content.length > 100
                    ? '${note.content.substring(0, 100)}...'
                    : note.content,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatDate(note.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (note.hasReminder)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.alarm, size: 16, color: Colors.orange),
                    ),
                  if (note.hasLocation)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child:
                          Icon(Icons.location_on, size: 16, color: Colors.blue),
                    ),
                  if (note.hasImage)
                    const Icon(Icons.image, size: 16, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNoteDetail(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(note.title)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (note.hasReminder)
                    Row(
                      children: [
                        const Icon(Icons.alarm, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('Hatırlatıcı: ${_formatDate(note.reminderDate!)}'),
                      ],
                    ),
                  if (note.hasLocation)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('Konum: ${note.location}'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(filteredNotes[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(filteredNotes[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notlarım"),
        actions: [
          NoteFilterMenu(
            currentFilter: currentFilter,
            onFilterSelected: (filter) {
              setState(() {
                currentFilter = filter; // Cast kaldırıldı
                _applyFilters();
              });
            },
          ),
          NoteViewSwitcher(
            currentView: currentView,
            onViewChanged: (view) {
              setState(() {
                currentView = view; // Cast kaldırıldı
              });
            },
          ),
        ],
      ),
      drawer: const DrawerMenuWidget(),
      body: Column(
        children: [
          NoteSearchBox(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                searchQuery = query;
                _applyFilters();
              });
            },
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 24),
              label: const Text("YENİ NOT", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _createNewNote,
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(
                    child: Text(
                      "Hiç not bulunamadı",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : currentView == NoteViewType.list
                    ? _buildListView()
                    : _buildGridView(),
          ),
        ],
      ),
    );
  }

  void _createNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Yeni Not")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Başlık",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "İçerik",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadNotes();
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

enum NoteFilterType { all, personal, shared, team }

enum NoteViewType { list, grid }
