import 'package:flutter/material.dart';
import 'package:note_app/controllers/auth_controller.dart';
import 'package:note_app/views/auth/register_screen.dart';
import 'package:note_app/views/auth/reset_password_screen.dart';
import 'package:note_app/views/notes/note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = AuthController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;
  bool isPasswordVisible = false;

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await controller.login(
          emailController.text,
          passwordController.text,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id!);

        if (mounted) {
          setState(() => errorText = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş başarılı')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NoteScreen(userId: user.id!),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => errorText = e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (errorText != null) ...[
                Text(errorText!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'E-posta gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Şifre gerekli' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleLogin,
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Hesabınız yok mu? Kayıt olun'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordScreen(),
                    ),
                  );
                },
                child: const Text('Şifrenizi mi unuttunuz?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
