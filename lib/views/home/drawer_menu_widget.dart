import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notes/note_screen.dart';
import '../notification/notifications_screen.dart';
import '../friends/friends_screen.dart';
import '../settings/settings_screen.dart';
import '../map/map_screen.dart';
import '../calendar/calendar_screen.dart';
import '../mindmap/mindmap_screen.dart';
import '../auth/login_screen.dart';

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
          _buildItem(
              context, Icons.note, 'Notlar', const NoteScreen(userId: 0)),
          _buildItem(context, Icons.notifications, 'Bildirimler',
              const NotificationsScreen()),
          _buildItem(context, Icons.contacts, 'Kişiler', const FriendsScreen()),
          _buildItem(
              context, Icons.settings, 'Ayarlar', const SettingsScreen()),
          _buildItem(context, Icons.map, 'Harita', const MapScreen()),
          _buildItem(
              context, Icons.calendar_today, 'Takvim', const CalendarScreen()),
          _buildItem(
              context, Icons.link, 'Bağlantılı Notlar', const MindMapScreen()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // context'i async gap öncesi alıyoruz
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    // Async işlem sonrası navigator kullanımı
    navigator.pop();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Başarıyla çıkış yapıldı')),
    );
  }

  ListTile _buildItem(
      BuildContext context, IconData icon, String title, Widget page) {
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
