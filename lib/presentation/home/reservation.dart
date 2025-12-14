import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/repositories/reservation_repository.dart';
import 'package:flutter/material.dart';
import 'package:alpha_treck/models/reservation_model.dart';
import 'package:alpha_treck/services/reservation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationPage extends StatefulWidget {
  final String zoneId;
  final String zoneName;
  final String zoneImg;

  const ReservationPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
    required this.zoneImg,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _peopleController = TextEditingController();
  String? _isoDate;

  bool loading = false;
  final ReservationService _reservationService = ReservationService(
    ReservationRepository(),
  );

  // Función para mostrar el calendario
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      _dateController.text =
          "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";
      _isoDate = selectedDate.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Reservar Servicio',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen
                  CircleAvatar(
                    radius: 70,
                    child: ClipOval(
                      child: Image.network(
                        widget.zoneImg,
                        fit: BoxFit.cover,
                        width: 140,
                        height: 140,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      widget.zoneName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa la información para hacer la reserva',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Nombre Completo',
                    hintText: 'Ingresa tu nombre',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dateController,
                        labelText: 'Fecha de Reserva',
                        hintText: 'Selecciona la fecha',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _peopleController,
                    labelText: 'Número de Personas',
                    hintText: 'Ingresa el número de personas',
                    icon: Icons.group_add_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Botón de confirmación
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirmar Reserva',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      // Aquí ayuda
                    },
                    child: const Text(
                      '¿Tienes dudas? Contáctanos',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para crear campos de texto con iconos
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (controller == _peopleController && int.tryParse(value) == null) {
          return 'Ingresa un número válido';
        }
        return null;
      },
    );
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;

        ReservationModel reservation = ReservationModel(
          id: '',
          serviceId: widget.zoneId,
          customerName: _nameController.text,
          reservationDate: _isoDate!,
          numberOfPeople: int.parse(_peopleController.text),
          serviceType: widget.zoneName,
          status: 'pendiente',
          createdAt: Timestamp.now(),
        );
        await _reservationService.createReservation(userId, reservation);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva realizada con éxito')),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar la reserva: $e')),
        );
      }
    }
  }
}
