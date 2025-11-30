import 'dart:io';
import 'package:alpha_treck/presentation/settings/settings_page.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:alpha_treck/services/users/user_service.dart';
import 'package:alpha_treck/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final UserService userService = UserService();

  String? selectedLanguage = "Spanish"; // idioma por defecto
  File? profileImage; // foto seleccionada

  bool loading = false;

  /// Seleccionar imagen (opcional)
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final country = countryController.text.trim();

    // Validación mínima
    if ([
      name,
      lastName,
      email,
      password,
      confirmPassword,
    ].any((e) => e.isEmpty)) {
      _mostrarMensaje("Completa todos los campos obligatorios");
      return;
    }

    if (password != confirmPassword) {
      _mostrarMensaje("Las contraseñas no coinciden");
      return;
    }

    setState(() => loading = true);

    String profileUrl = "";
    if (profileImage != null) {
      // Subir foto solo si existe, actualizar plan para usar esta opcion
      //profileUrl = await userService.uploadProfileImage(profileImage!);
    }

    // Registrar usuario mínimo
    final result = await userService.registerUser(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      country: country,
      language: selectedLanguage ?? "", // si no selecciona idioma
      profileImageUrl: profileUrl,
    );

    setState(() => loading = false);

    if (result is String) {
      //print(result);
      _mostrarMensaje(result);
      return;
    }

    if (result is UserModel) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
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
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // FOTO DE PERFIL (opcional)
            GestureDetector(
              onTap: pickImage,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Foto de perfil (opcional)",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _input("Nombre", "Ingresa tu nombre", nameController),
            const SizedBox(height: 10),

            _input("Apellidos", "Ingresa tus apellidos", lastNameController),
            const SizedBox(height: 10),

            _input("Correo electrónico", "usuario@mail.com", emailController),
            const SizedBox(height: 10),

            _input(
              "Contraseña",
              "********",
              passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 10),

            _input(
              "Confirmar contraseña",
              "********",
              confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 10),

            _input("País", "Peru...", countryController),
            const SizedBox(height: 15),

            // SELECTOR DE IDIOMA (opcional)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Idioma (opcional)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: selectedLanguage,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Spanish", child: Text("Español")),
                    DropdownMenuItem(value: "English", child: Text("Inglés")),
                    DropdownMenuItem(value: "Quechua", child: Text("Quechua")),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedLanguage = value),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Crear cuenta",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET DE INPUT
  Widget _input(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
