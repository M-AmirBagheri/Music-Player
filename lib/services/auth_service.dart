class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  void login() => _loggedIn = true;
  void logout() => _loggedIn = false;
}
