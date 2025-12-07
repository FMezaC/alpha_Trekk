import 'package:alpha_treck/models/login_model.dart';
import 'package:alpha_treck/services/login/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<User?> login(LoginModel login) {
    return _authService.signIn(login);
  }

  Future<void> logout() {
    return _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception("Correo no enviado");
    }
  }
}
