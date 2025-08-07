class NoteModel {
  int? id;
  int userId;
  String title;
  String content;
  String date;
  String? category;
  String? reminderDate; // Hatırlatıcı tarihi
  String? location; // Konum bilgisi
  String? imagePath; // Yerel resim yolu
  String? imageUrl; // Online resim URL'si
  String type; // Not tipi (personal, shared, team)

  NoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    this.category,
    this.reminderDate,
    this.location,
    this.imagePath,
    this.imageUrl,
    this.type = 'personal', // Varsayılan kişisel not
  });

  // Notun hatırlatıcısı var mı?
  bool get hasReminder => reminderDate != null;

  // Notun konum bilgisi var mı?
  bool get hasLocation => location != null;

  // Notun resmi var mı?
  bool get hasImage => imagePath != null || imageUrl != null;

  // Notun tipini kontrol etmek için yardımcı metodlar
  bool get isPersonal => type == 'personal';
  bool get isShared => type == 'shared';
  bool get isTeam => type == 'team';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'date': date,
      'category': category,
      'reminderDate': reminderDate,
      'location': location,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'type': type,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      category: map['category'],
      reminderDate: map['reminderDate'],
      location: map['location'],
      imagePath: map['imagePath'],
      imageUrl: map['imageUrl'],
      type: map['type'] ?? 'personal', // Varsayılan değer
    );
  }

  // Notu kopyalamak için yardımcı metod
  NoteModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? date,
    String? category,
    String? reminderDate,
    String? location,
    String? imagePath,
    String? imageUrl,
    String? type,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      category: category ?? this.category,
      reminderDate: reminderDate ?? this.reminderDate,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
    );
  }
}
