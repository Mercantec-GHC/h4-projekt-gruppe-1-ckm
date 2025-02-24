import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

 // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: "jwt_token");
  }

  // Retrieve token
  Future<String?> getToken() async {
    return await _storage.read(key: "jwt_token");
  }

}
