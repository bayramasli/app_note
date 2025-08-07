import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import '../services/database/database_service.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final dbHelper = DatabaseHelper();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> register(String fullName, String email, String password, String phone) async {
    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final existingUser = await dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      _isLoading.value = false;
      throw 'Bu e-posta zaten kayıtlı';
    }

    final hashedPassword = hashPassword(password);
    final newUser = UserModel(fullName: fullName, email: email, password: hashedPassword, phone: phone);
    await dbHelper.registerUser(newUser);

    _isLoading.value = false;
  }

  Future<UserModel> login(String email, String password) async {
    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final user = await dbHelper.getUserByEmail(email);
    _isLoading.value = false;

    final hashedPassword = hashPassword(password);
    if (user == null || user.password != hashedPassword) {
      throw 'Geçersiz giriş bilgileri';
    }
    return user;
  }

  Future<void> resetPassword(String email) async {
    _isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _isLoading.value = false;

    if (!email.contains('@')) {
      throw 'Geçersiz e-posta';
    }

    final user = await dbHelper.getUserByEmail(email);
    if (user == null) {
      throw 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
    }

    // Burada bir e-posta gönderimi vs. entegrasyonu yapılabilir.
  }
}
