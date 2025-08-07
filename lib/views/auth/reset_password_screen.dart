import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/database/database_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final controller = AuthController();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String? errorText;

  Future<void> handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    try {
      await controller.resetPassword(email);

      if (!mounted) return;
      setState(() => errorText = null);

      final result = await _showNewPasswordDialog(email);

      if (!mounted) return;

      _showSnackBar(
        result
            ? 'Şifre başarıyla güncellendi'
            : 'Şifre sıfırlama talimatları gönderildi',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => errorText = e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _showNewPasswordDialog(String email) async {
    final newPasswordController = TextEditingController();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Yeni Şifre Belirle'),
              content: TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Yeni Şifre'),
              ),
              actions: [
                TextButton(
                  onPressed: () => navigator.pop(false),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPassword = newPasswordController.text.trim();

                    if (newPassword.length < 6) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Şifre en az 6 karakter olmalı')),
                      );
                      return;
                    }

                    try {
                      final db = DatabaseHelper();
                      final user = await db.getUserByEmail(email);

                      if (user != null) {
                        final updatedUser = user.copyWith(
                          password: controller.hashPassword(newPassword),
                        );
                        await db.updateUserPassword(
                            user.email, updatedUser.password);
                        navigator.pop(true);
                        return;
                      }
                      navigator.pop(false);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Hata: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Sıfırla')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorText != null) ...[
                Text(errorText!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) => value!.isEmpty ? 'E-posta gerekli' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleReset,
                child: const Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
