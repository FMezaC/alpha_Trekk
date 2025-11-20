import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Registrarse"),
        shadowColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 25),
            _campoTexto(Icons.person, "Usuario..."),
            const SizedBox(height: 10),
            _campoTexto(Icons.email, "Correo..."),
            const SizedBox(height: 10),
            _campoTexto(Icons.lock, "Contraseña..."),
            const SizedBox(height: 10),
            _campoTexto(Icons.lock, "Confirmar contraseña"),
            const SizedBox(height: 25),

            // BOTÓN REGISTRARME
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Registrarme",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(IconData icono, String texto) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icono),
        hintText: texto,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
