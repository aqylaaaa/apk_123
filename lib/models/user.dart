class User {
  final String name;
  final String email;
  final String username;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });

  // Konversi User ke Map untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  // Buat User dari Map yang disimpan
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }
} 