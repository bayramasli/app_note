import 'package:get/get.dart';
import '../models/note_model.dart';
import '../services/database/database_service.dart';

class NotesController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  RxList<NoteModel> allNotes = <NoteModel>[].obs;
  RxList<NoteModel> filteredNotes = <NoteModel>[].obs;
  RxString viewMode = 'list'.obs;
  RxString currentFilter = 'Tümü'.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes({int? userId}) async {
    try {
      List<NoteModel> notes;

      // Kullanıcı ID'si varsa onun notlarını getir
      if (userId != null) {
        notes = await _dbHelper.getNotesByUserId(userId);
      } else {
        // Ya da alternatif bir yöntem (örneğin son 50 not)
        notes = await _dbHelper.getRecentNotes(limit: 50);
      }

      allNotes.assignAll(notes);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
          'Hata', 'Notlar yüklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'list' ? 'grid' : 'list';
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    // Filtreleme
    var result = allNotes.where((note) {
      final matchesFilter =
          currentFilter.value == 'Tümü' || note.category == currentFilter.value;

      final matchesSearch = searchQuery.value.isEmpty ||
          note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    filteredNotes.assignAll(result);
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _dbHelper.addNote(note);
      await fetchNotes(); // Listeyi yenile
    } catch (e) {
      Get.snackbar('Hata', 'Not eklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _dbHelper.deleteNote(id);
      await fetchNotes(); // Listeyi yenile
    } catch (e) {
      Get.snackbar('Hata', 'Not silinirken bir hata oluştu: ${e.toString()}');
    }
  }
}
