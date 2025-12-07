import 'package:alpha_treck/presentation/settings/settings_page.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/widgets/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:alpha_treck/models/login_model.dart';
import 'package:alpha_treck/repositories/auth_repository.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  bool loading = false;

  Future<void> _login() async {
    final login = LoginModel(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!login.isValid) {
      _mostrarMensaje("Completa todos los campos");
      return;
    }

    setState(() => loading = true);

    try {
      final user = await authRepository.login(login);

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
          (route) => false,
        );
      }
    } catch (e) {
      _mostrarMensaje("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: Colors.red));
  }

  void _mostrarDialogoReset() {
    final TextEditingController emailResetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => ResetPasswordDialog(
        authRepository: authRepository,
        emailController: emailResetController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 4),
      appBar: AppBar(title: Text("Ingresar")),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen
              CircleAvatar(
                radius: 60,
                child: ClipOval(
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Alpha Trekk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Ingresa a tu cuenta',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              _campoTexto(
                "Correo electronico",
                "Ingresa tu correo",
                emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _campoTexto(
                "Contraseña",
                "Ingresa tu contraseña",
                passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Ingresar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: _mostrarDialogoReset,
                child: const Text(
                  'Olvidate tu contraseña?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'No tienes cuenta aun? Crea uno',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
