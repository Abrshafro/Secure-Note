class User {
  final String id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      password: json['password'],
    );
  }
}
