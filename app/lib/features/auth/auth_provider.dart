import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user_model.dart';
import '../../shared/services/api_client.dart';
import '../../shared/services/auth_service.dart';

class AuthState {
  const AuthState({
    this.isLoading = true,
    this.user,
    this.error,
  });

  final bool isLoading;
  final UserModel? user;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(const AuthState());

  final AuthService _service;

  Future<void> initialize() async {
    final storedUser = await _service.restoreSession();
    state = state.copyWith(isLoading: false, user: storedUser);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _service.login(email, password);
      state = state.copyWith(isLoading: false, user: _service.currentUser);
      return success;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String nombreVisible,
  ) async {
    try {
      await _service.register(email, password, nombreVisible);
      return true;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(isLoading: false);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref.watch(authServiceProvider));
  notifier.initialize();
  return notifier;
});
