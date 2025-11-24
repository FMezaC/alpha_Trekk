class LoginModel {
  final String email;
  final String password;

  LoginModel({required this.email, required this.password});

  bool get isValid => email.trim().isNotEmpty && password.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {"email": email.trim(), "password": password.trim()};
  }
}
