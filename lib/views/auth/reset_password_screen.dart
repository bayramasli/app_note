// lib/views/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';

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
    if (_formKey.currentState!.validate()) {
      try {
        await controller.resetPassword(emailController.text);
        if (!mounted) return;

        setState(() => errorText = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => errorText = e.toString());
      }
    }
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
              ElevatedButton(onPressed: handleReset, child: const Text('Gönder')),
            ],
          ),
        ),
      ),
    );
  }
}
