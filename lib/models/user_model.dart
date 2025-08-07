class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;

  UserModel(
      {this.id,
      required this.fullName,
      required this.email,
      required this.password});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }
}
