class ProfileModel {
  final String name;
  final String username;
  final String email;
  final String country;
  final String socialMedia;
  final DateTime? dateBirth;
  final String language;

  ProfileModel({
    required this.name,
    required this.username,
    required this.email,
    required this.country,
    required this.socialMedia,
    required this.dateBirth,
    required this.language,
  });
}

List<ProfileModel> dataProfile = [
  ProfileModel(
    name: 'Pepito Perez',
    username: 'pperez',
    email: 'pepito_123@gmail.com',
    country: 'peru',
    socialMedia: 'SocialMedia',
    dateBirth: DateTime(1995, 12, 10),
    language: "Spanish",
  ),
];
