import 'package:firebase_auth/firebase_auth.dart';
import 'package:alpha_treck/models/login_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(LoginModel login) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: login.email,
        password: login.password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Usuario no encontrado";
      case 'wrong-password':
        return "Contraseña incorrecta";
      case 'invalid-email':
        return "Email inválido";
      case 'network-request-failed':
        return "Error de red, verifica tu conexión";
      default:
        return "Ocurrió un error inesperado";
    }
  }
}
