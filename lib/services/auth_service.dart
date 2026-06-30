import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> login(String username, String password) async {
    // จำลอง: บังคับ user = admin, pass = 1234
    if (username == 'admin' && password == '1234') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
