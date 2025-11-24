import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alpha_treck/models/user_model.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Método para registrar usuario
  Future<dynamic> registerUser({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String country,
    required String language,
    required String profileImageUrl,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear username automáticamente
      // final username = "${name.trim()[0]}${lastName.trim()}"
      //     .toLowerCase()
      //     .replaceAll(" ", "");
      // Toma el primer apellido o solo el apellido si solo hay uno.
      String lastNameTrimmed = lastName.split(' ').first;
      String username = "${name.trim()[0]}$lastNameTrimmed".toUpperCase();

      // Crear modelo
      final user = UserModel(
        id: cred.user!.uid,
        name: name,
        lastName: lastName,
        username: username,
        email: email,
        country: country,
        language: language,
        profileImage: profileImageUrl,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Guardar modelo en Firestore
      await _firestore.collection("users").doc(user.id).set(user.toMap());

      return user; // éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // error
    }
  }

  /// Método para subir imagen a Firebase Storage y devolver URL
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('profile_images').child(fileName);

      await ref.putFile(imageFile);

      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  /// Método para actualizar los datos del perfil del usuario
  Future<void> updateUserProfile({
    required String name,
    required String lastName,
    required String country,
    required String language,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No se encontró el usuario.");
      }

      final userDoc = _firestore
          .collection('users')
          .doc(user.uid); // Documento del usuario en Firestore

      // Crear un mapa con los campos a actualizar
      Map<String, dynamic> updateData = {
        'name': name,
        'lastName': lastName,
        'country': country,
        'language': language,
      };

      // Si se proporciona una nueva URL de imagen, se agrega al mapa
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        updateData['profileImage'] = profileImageUrl;
      }

      // Actualizar los datos en Firestore
      await userDoc.update(updateData);

      print("Perfil actualizado exitosamente");
    } catch (e) {
      print("Error al actualizar el perfil: $e");
      throw Exception("Error al actualizar el perfil: $e");
    }
  }
}
