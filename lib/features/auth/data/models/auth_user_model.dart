class AuthUserModel {
  const AuthUserModel({
    required this.contactId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.mobile,
  });

  final String contactId;
  final String firstname;
  final String lastname;
  final String email;
  final String mobile;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      contactId: json['contactid'].toString(),
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}
