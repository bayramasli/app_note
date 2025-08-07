class NoteModel {
  int? id;
  int userId;
  String title;
  String content;
  String date;
  String? category; // opsiyonel olarak kategori eklendi

  NoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'date': date,
      'category': category,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      category: map['category'], // ekledik
    );
  }
}
