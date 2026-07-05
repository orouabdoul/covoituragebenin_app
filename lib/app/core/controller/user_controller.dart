import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/data/models/auth/user_model.dart';

class UserController extends GetxController {
  static const String _tokenStorageKey = 'token';
  static const String _tokenTimestampKey = 'token_timestamp';
  static const String _roleStorageKey = 'user_role';
  static const String _profileCompleteKey = 'profile_complete';
  static const int _sessionDurationHours = 24;

  static UserController get instance => Get.find<UserController>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxString token = ''.obs;
  final RxString role = ''.obs;
  final RxBool profileComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreRole();
    Future.microtask(_restoreToken);
  }

  Future<void> setUserAndToken(
    UserModel u,
    String t, {
    bool isProfileComplete = false,
  }) async {
    user.value = u;
    token.value = t;
    profileComplete.value = isProfileComplete;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenStorageKey, t);
    await prefs.setInt(
      _tokenTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setBool(_profileCompleteKey, isProfileComplete);
  }

  Future<void> setProfileComplete(bool value) async {
    profileComplete.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompleteKey, value);
  }

  void setRole(String value) {
    role.value = value;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_roleStorageKey, value));
  }

  Future<String> getSessionToken() async {
    if (token.value.isNotEmpty) return token.value;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenStorageKey) ?? '';
    if (stored.isEmpty) return '';

    if (await isSessionExpired()) {
      await logout();
      return '';
    }

    token.value = stored;
    profileComplete.value = prefs.getBool(_profileCompleteKey) ?? false;
    return stored;
  }

  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
    return DateTime.now().isAfter(expiry);
  }

  Future<int> getRemainingSessionMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) return 0;

    final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
    final remaining = expiry.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> logout() async {
    user.value = null;
    token.value = '';
    role.value = '';
    profileComplete.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenStorageKey) ?? '';
    if (stored.isNotEmpty && token.value.isEmpty) {
      token.value = stored;
      profileComplete.value = prefs.getBool(_profileCompleteKey) ?? false;
    }
  }

  Future<void> _restoreRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleStorageKey) ?? '';
    if (saved.isNotEmpty) role.value = saved;
  }
}
