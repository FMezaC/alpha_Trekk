import 'dart:io';
import 'package:alpha_treck/presentation/login/start_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alpha_treck/utils/format_date.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alpha_treck/services/users/user_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  File? profileImage;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController registerDate = TextEditingController();

  String? tempLanguage;

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Usuario no logueado'));
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Configuración"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StartPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Datos no encontrados'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Initialize controllers with current data
          nameController.text = data['name'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          countryController.text = data['country'] ?? '';
          languageController.text = data['language'] ?? '';
          tempLanguage = data['language'] ?? '';

          usernameController.text = data['username'] ?? '';
          emailController.text = data['email'] ?? '';
          registerDate.text = formatDate(
            DateTime.parse(
              data['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderImage(data['photoURL']),
                _buildProfileCard(data),
                _buildEditButton(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  // Función para seleccionar una nueva imagen de perfil
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

  Widget _buildHeaderImage(String? photoUrl) {
    const defaultImage =
        "https://image-tc.galaxy.tf/wijpeg-7ellqz2uqv2l9plk30futx9jr/experiencias-machu-picchu_wide.jpg?crop=0%2C63%2C1200%2C675&width=1140";

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          photoUrl ?? defaultImage,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(24),
            child: profileImage == null
                ? const Icon(Icons.camera_alt, color: Colors.grey, size: 28)
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(profileImage!),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Mi Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Nombre', nameController),
          _buildInfoRow('Apellidos', lastNameController),
          _buildInfoRow('Usuario', usernameController, isEditable: false),
          _buildInfoRow('Email', emailController, isEditable: false),
          _buildInfoRow('País', countryController),
          _buildInfoRow('Fecha registro', registerDate, isEditable: false),
          _buildInfoRow('Idioma', languageController),
          _buildSocialRow(data['socialMedia']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    dynamic controller, {
    bool isEditable = true,
  }) {
    final bool isLanguageField = (title == 'Idioma');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 5),

          // --- CAMPO ESPECIAL PARA IDIOMA ---
          if (isLanguageField)
            isEditing
                ? _buildLanguageDropdownStyled() // Dropdown con estilo de TextField
                : _buildDisabledTextField(tempLanguage ?? "Sin idioma"),

          // --- CAMPOS NORMALES ---
          if (!isLanguageField)
            TextField(
              controller: controller,
              enabled: isEditable && isEditing,
              decoration: InputDecoration(
                hintText: 'Ingresa $title',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdownStyled() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: DropdownButtonFormField<String>(
        value: tempLanguage,
        decoration: const InputDecoration(border: InputBorder.none),
        items: const [
          DropdownMenuItem(value: "Spanish", child: Text("Español")),
          DropdownMenuItem(value: "English", child: Text("Inglés")),
          DropdownMenuItem(value: "Quechua", child: Text("Quechua")),
        ],
        onChanged: (newValue) {
          setState(() => tempLanguage = newValue);
        },
      ),
    );
  }

  Widget _buildSocialRow(Map<String, dynamic>? socialMedia) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildSocialIcon(Icons.facebook, Colors.blue),
          const SizedBox(width: 10),
          _buildSocialIcon(Icons.camera_alt, Colors.purple),
          const SizedBox(width: 10),
          _buildSocialIcon(Icons.alternate_email, Colors.lightBlue),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Icono de red social presionado")),
        );
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Función para alternar entre editar y guardar
  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () async {
        if (isEditing) {
          await _updateProfile();
        } else {
          setState(() {
            isEditing = true;
          });
        }
      },
      child: Text(isEditing ? 'Guardar cambios' : 'Editar perfil'),
    );
  }

  // Función para actualizar los datos del perfil
  Future<void> _updateProfile() async {
    try {
      await userService.updateUserProfile(
        name: nameController.text,
        lastName: lastNameController.text,
        country: countryController.text,
        language: tempLanguage ?? languageController.text,
      );

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado con éxito")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildDisabledTextField(String value) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
