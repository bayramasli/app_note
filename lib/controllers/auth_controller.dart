import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/database/database_service.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final dbHelper = DatabaseHelper();

  Future<void> register(String fullName, String email, String password) async {
    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // isteğe bağlı

    final existingUser = await dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      _isLoading.value = false;
      throw 'Bu e-posta zaten kayıtlı';
    }

    final newUser =
        UserModel(fullName: fullName, email: email, password: password);
    await dbHelper.registerUser(newUser);

    _isLoading.value = false;
  }

  Future<void> login(String email, String password) async {
    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final user = await dbHelper.getUserByEmail(email);
    _isLoading.value = false;

    if (user == null || user.password != password) {
      throw 'Geçersiz giriş bilgileri';
    }
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
