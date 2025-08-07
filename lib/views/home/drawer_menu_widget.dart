import 'package:flutter/material.dart';
import '../notes/note_screen.dart';
import '../notification/notifications_screen.dart';
import '../friends/friends_screen.dart';
import '../settings/settings_screen.dart';
import '../map/map_screen.dart';
import '../calendar/calendar_screen.dart';
import '../mindmap/mindmap_screen.dart';

class DrawerMenuWidget extends StatelessWidget {
  const DrawerMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menü',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildItem(context, Icons.note, 'Notlar', const NoteScreen()),
          _buildItem(context, Icons.notifications, 'Bildirimler', const NotificationsScreen()),
          _buildItem(context, Icons.contacts, 'Kişiler', const FriendsScreen()),
          _buildItem(context, Icons.settings, 'Ayarlar', const SettingsScreen()),
          _buildItem(context, Icons.map, 'Harita', const MapScreen()),
          _buildItem(context, Icons.calendar_today, 'Takvim', const CalendarScreen()),
          _buildItem(context, Icons.link, 'Bağlantılı Notlar', const MindMapScreen()),
        ],
      ),
    );
  }

  ListTile _buildItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // Drawer'ı kapat
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
