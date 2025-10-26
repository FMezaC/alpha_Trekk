import 'package:alpha_treck/models/profile_model.dart';
import 'package:alpha_treck/utils/format_date.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeaderImage(), _buildProfileCard()]),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }
}

Widget _buildHeaderImage() {
  const image =
      "https://image-tc.galaxy.tf/wijpeg-7ellqz2uqv2l9plk30futx9jr/experiencias-machu-picchu_wide.jpg?crop=0%2C63%2C1200%2C675&width=1140";
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.network(
        image,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      ),
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(24),
        child: Icon(Icons.camera_alt, color: Colors.grey, size: 28),
      ),
    ],
  );
}

Widget _buildProfileCard() {
  return Container(
    margin: const EdgeInsets.all(24),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      //border: Border.all(color: Colors.blue.shade100),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
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
        for (var field in dataProfile) ...[
          _buildInfoRow('Name', field.name),
          _buildInfoRow('Username', field.username),
          _buildInfoRow('E-mail', field.email),
          _buildInfoRow('Country', field.country),
          _buildInfoRow("Date of Birth", formatDate(field.dateBirth)),
          _buildInfoRow("Language", field.language),
          _buildInfoRow('Social Media', field.socialMedia),
        ],
      ],
    ),
  );
}

//Linea de info detalle
Widget _buildInfoRow(String title, String value) {
  if (title == 'Social Media') {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Media',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSocialIcon(Icons.facebook, Colors.blue),
              const SizedBox(width: 10),
              _buildSocialIcon(Icons.camera_alt, Colors.purple),
              const SizedBox(width: 10),
              _buildSocialIcon(Icons.alternate_email, Colors.lightBlue),
            ],
          ),
        ],
      ),
    );
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (value.isNotEmpty)
          Text(value, style: TextStyle(color: Colors.black87)),
      ],
    ),
  );
}

//icono de las redes sociales
Widget _buildSocialIcon(IconData icon, Color color) {
  return InkWell(
    onTap: () {
      // Aquí abrir link
      print('Icono de red social presionado');
    },
    child: CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}
