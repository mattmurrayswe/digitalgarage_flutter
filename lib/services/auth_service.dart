class AuthService {
  static bool isLoggedIn = false;

  static Future<bool> checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    return isLoggedIn;
  }

  static Future<void> login(String email, String password) async {
    print('Email: $email');
    print('Password: $password');
    isLoggedIn = true;
  }

  static Future<void> loginCode(String code) async {
    print('Code: $code');
    isLoggedIn = true;
  }

  static Future<void> logout() async {
    isLoggedIn = false;
  }
}
