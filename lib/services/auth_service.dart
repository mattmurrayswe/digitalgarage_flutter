import 'dart:convert';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse('https://digitalgarage.com.br/api/authenticate?event_code=$code');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['authenticated'] == true) {
          isLoggedIn = true;
          print('Login successful');
        } else {
          isLoggedIn = false;
          throw Exception('Código inválido');
        }
      } else {
        throw Exception('Erro de servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro durante login: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    isLoggedIn = false;
  }
}
