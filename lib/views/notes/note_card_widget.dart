import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/note_model.dart';

class NoteCardWidget extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool gridModu; // Grid görünümü için

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    this.gridModu = false, // Varsayılan false (liste görünümü)
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                note.title,
                style: TextStyle(
                  fontSize: gridModu ? 14 : 16, // Grid modunda daha küçük font
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis, // Taşan metni ... ile göster
                ),
                maxLines: 1, // Tek satırda göster
              ),
              const SizedBox(height: 4),

              // İçerik
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: gridModu ? 12 : 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: gridModu ? 3 : 5, // Grid'de daha az satır
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Alt bilgi ve ikonlar
              Row(
                children: [
                  // Tarih
                  Text(
                    _tarihiFormatla(note.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(), // Boşluk bırak

                  // Hatırlatıcı ikonu
                  if (note.hasReminder)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.notifications,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                  // Konum ikonu
                  if (note.hasLocation)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                  // Resim ikonu
                  if (note.hasImage)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.image,
                        size: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),

                  // Silme butonu
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarih formatlama fonksiyonu
  String _tarihiFormatla(String isoDate) {
    try {
      final parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (_) {
      return isoDate;
    }
  }
}
