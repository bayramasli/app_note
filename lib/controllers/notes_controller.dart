import 'package:get/get.dart';
import '../models/note_model.dart';
import '../services/database/database_service.dart';

class NotesController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  RxList<NoteModel> allNotes = <NoteModel>[].obs;
  RxList<NoteModel> filteredNotes = <NoteModel>[].obs;
  RxString viewMode = 'list'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  void fetchNotes() async {
    // Eğer kullanıcı bazlı not alıyorsan, userId parametre olmalı
    final notes =
        await _dbHelper.getAllNotes(); // ya da getNotesByUserId(userId)
    allNotes.value = notes;
    filteredNotes.value = notes;
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'list' ? 'grid' : 'list';
  }

  void filterNotes(String filter) {
    if (filter == 'Tümü') {
      filteredNotes.value = allNotes;
    } else {
      filteredNotes.value =
          allNotes.where((note) => note.category == filter).toList();
    }
  }

  void searchNotes(String query) {
    filteredNotes.value = allNotes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
