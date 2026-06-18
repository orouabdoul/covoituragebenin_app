import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? get token => _prefs.getString(_tokenKey);
  String? get userRole => _prefs.getString(_roleKey);

  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);
  Future<void> saveUserRole(String role) => _prefs.setString(_roleKey, role);
  Future<void> clear() async => _prefs.clear();
}
