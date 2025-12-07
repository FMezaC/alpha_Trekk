import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String username;
  final String email;
  final String country;
  final String language;
  final String profileImage;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.username,
    required this.email,
    required this.country,
    required this.language,
    required this.profileImage,
    required this.createdAt,
  });

  // Convertir documento de Firebase a UserModel
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'],
      lastName: data['lastName'],
      username: data['username'],
      email: data['email'],
      country: data['country'],
      language: data['language'],
      profileImage: data['profileImage'],
      createdAt: data['createdAt'],
    );
  }

  // Convertir UserModel a mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "lastName": lastName,
      "username": username,
      "email": email,
      "country": country,
      "language": language,
      "profileImage": profileImage,
      "createdAt": createdAt,
    };
  }

  //recuperar
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      lastName: map['lastName'] ?? "",
      username: map['username'] ?? "",
      email: map['email'] ?? "",
      country: map['country'] ?? "",
      language: map['language'] ?? "",
      profileImage: map['profileImage'] ?? "",
      createdAt: map['createdAt'] ?? "",
    );
  }
}
