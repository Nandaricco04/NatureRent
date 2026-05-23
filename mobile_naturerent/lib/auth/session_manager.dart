import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  const SessionData({
    required this.userId,
    required this.role,
    this.name,
    this.email,
  });

  final dynamic userId;
  final String role;
  final String? name;
  final String? email;

  bool get isUser => role == 'user';
  bool get isOwner => role == 'owner' || role == 'pemilikrental';
}

class SessionManager {
  static const _isLoggedInKey = 'is_logged_in';
  static const _userIdKey = 'session_user_id';
  static const _roleKey = 'session_role';
  static const _nameKey = 'session_name';
  static const _emailKey = 'session_email';

  static Future<void> saveSession({
    required dynamic userId,
    required String role,
    String? name,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId.toString());
    await prefs.setString(_roleKey, _normalizeRole(role));

    if (name?.trim().isNotEmpty == true) {
      await prefs.setString(_nameKey, name!.trim());
    } else {
      await prefs.remove(_nameKey);
    }

    if (email?.trim().isNotEmpty == true) {
      await prefs.setString(_emailKey, email!.trim());
    } else {
      await prefs.remove(_emailKey);
    }
  }

  static Future<SessionData?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final userIdText = prefs.getString(_userIdKey);
    final role = prefs.getString(_roleKey);

    if (!isLoggedIn || userIdText == null || role == null) return null;

    return SessionData(
      userId: int.tryParse(userIdText) ?? userIdText,
      role: _normalizeRole(role),
      name: prefs.getString(_nameKey),
      email: prefs.getString(_emailKey),
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }

  static String _normalizeRole(String role) {
    final value = role.trim().toLowerCase();
    if (value == 'pemilikrental') return 'owner';
    return value;
  }
}
