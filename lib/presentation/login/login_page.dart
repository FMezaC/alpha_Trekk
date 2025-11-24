import 'package:alpha_treck/presentation/profile/profile_page.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Ingresar"),
        shadowColor: Colors.black26,
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 25),

            _campoTexto(
              Icons.person,
              "Usuario...",
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 10),

            _campoTexto(
              Icons.lock,
              "Contraseña...",
              passwordController,
              isPassword: true,
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "Restablecer contraseña",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Ingresar",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(
    IconData icono,
    String texto,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icono),
        hintText: texto,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
