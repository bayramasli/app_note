class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String phone;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
  });

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }
}
