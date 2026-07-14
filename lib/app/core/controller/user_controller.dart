import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/data/models/auth/user_model.dart';

class UserController extends GetxController {
  static const String _tokenStorageKey = 'token';
  static const String _tokenTimestampKey = 'token_timestamp';
  static const String _roleStorageKey = 'user_role';
  static const String _profileCompleteKey = 'profile_complete';
  static const String _accountVerifiedKey = 'account_verified';
  static const String _accountBlockedKey = 'account_blocked';
  static const int _sessionDurationHours = 12;

  static UserController get instance => Get.find<UserController>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxString token = ''.obs;
  final RxString role = ''.obs;
  final RxBool profileComplete = false.obs;
  final RxBool accountVerified = false.obs;
  final RxBool accountBlocked = false.obs;

  // Expiry cached in memory — avoids repeated SharedPreferences I/O
  DateTime? _sessionExpiry;

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
    accountVerified.value = u.isVerified;
    accountBlocked.value = u.isBlocked;
    _sessionExpiry =
        DateTime.now().add(const Duration(hours: _sessionDurationHours));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenStorageKey, t);
    await prefs.setInt(
      _tokenTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setBool(_profileCompleteKey, isProfileComplete);
    await prefs.setBool(_accountVerifiedKey, u.isVerified);
    await prefs.setBool(_accountBlockedKey, u.isBlocked);
  }

  Future<void> persistBlockedStatus({required bool blocked}) async {
    accountBlocked.value = blocked;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountBlockedKey, blocked);
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
    // Fast path: check in-memory expiry (no I/O) — catches active-session timeout
    if (_sessionExpiry != null && DateTime.now().isAfter(_sessionExpiry!)) {
      await logout();
      return '';
    }

    if (token.value.isNotEmpty) return token.value;

    // Cold start: load from disk, then verify expiry
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenStorageKey) ?? '';
    if (stored.isEmpty) return '';

    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) {
      await logout();
      return '';
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
    if (DateTime.now().isAfter(expiry)) {
      await logout();
      return '';
    }

    _sessionExpiry = expiry;
    token.value = stored;
    profileComplete.value = prefs.getBool(_profileCompleteKey) ?? false;
    accountVerified.value = prefs.getBool(_accountVerifiedKey) ?? false;
    accountBlocked.value = prefs.getBool(_accountBlockedKey) ?? false;
    return stored;
  }

  Future<bool> isSessionExpired() async {
    if (_sessionExpiry != null) {
      return DateTime.now().isAfter(_sessionExpiry!);
    }
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
    return DateTime.now().isAfter(expiry);
  }

  Future<int> getRemainingSessionMinutes() async {
    final expiry = _sessionExpiry ?? await _loadExpiryFromPrefs();
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  Future<DateTime?> _loadExpiryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
  }

  Future<void> logout() async {
    user.value = null;
    token.value = '';
    role.value = '';
    profileComplete.value = false;
    accountVerified.value = false;
    accountBlocked.value = false;
    _sessionExpiry = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenStorageKey) ?? '';
    if (stored.isEmpty || token.value.isNotEmpty) return;

    // Verify expiry BEFORE putting token in memory
    final timestamp = prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) {
      await logout();
      return;
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .add(const Duration(hours: _sessionDurationHours));
    if (DateTime.now().isAfter(expiry)) {
      await logout();
      return;
    }

    _sessionExpiry = expiry;
    token.value = stored;
    profileComplete.value = prefs.getBool(_profileCompleteKey) ?? false;
    accountVerified.value = prefs.getBool(_accountVerifiedKey) ?? false;
    accountBlocked.value = prefs.getBool(_accountBlockedKey) ?? false;
  }

  Future<void> _restoreRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleStorageKey) ?? '';
    if (saved.isNotEmpty) role.value = saved;
  }
}
