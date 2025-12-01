class AuthCredentials {
  final String email;
  final String password;

  const AuthCredentials({
    this.email = '',
    this.password = '',
  });

  AuthCredentials copyWith({
    String? email,
    String? password,
  }) {
    return AuthCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  bool get isValid => email.isNotEmpty && password.length >= 6;
}

