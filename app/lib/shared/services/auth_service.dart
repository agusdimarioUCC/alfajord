import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    final data = await _apiClient.post(
      'auth/login',
      data: {
        'email': email,
        'password': password,
      },
    ) as Map<String, dynamic>;

    final payload = data['data'] as Map<String, dynamic>?;
    if (payload == null) {
      return false;
    }

    final token = payload['token'] as String?;
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      return false;
    }

    _currentUser = UserModel.fromJson(userJson);
    await _persistSession(token, _currentUser!);
    return true;
  }

  Future<bool> register(
    String email,
    String password,
    String nombreVisible,
  ) async {
    await _apiClient.post(
      'auth/register',
      data: {
        'email': email,
        'password': password,
        'nombreVisible': nombreVisible,
      },
    );
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    _apiClient.updateToken(null);
  }

  Future<UserModel?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      return null;
    }

    _apiClient.updateToken(token);

    final userRaw = await _storage.read(key: _userKey);
    if (userRaw == null) {
      return null;
    }

    try {
      final jsonMap = jsonDecode(userRaw) as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(jsonMap);
    } catch (_) {
      _currentUser = null;
    }

    return _currentUser;
  }

  Future<void> _persistSession(String token, UserModel user) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    _apiClient.updateToken(token);
  }
}
