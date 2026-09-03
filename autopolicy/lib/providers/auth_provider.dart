import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Declare REST client provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Declare Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

// Manage authentication state notifier
class AuthNotifier extends StateNotifier<UserProfile?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  bool get isAuthenticated => state != null;
  String get activeRole => state?.role ?? 'Guest';
  String get username => state?.username ?? '';

  Future<void> signIn(String email, String password, String selectedRole) async {
    final profile = await _authService.login(email, password, selectedRole);
    state = profile;
  }

  Future<void> signUp(String email, String password, String selectedRole) async {
    final profile = await _authService.signUp(email, password, selectedRole);
    state = profile;
  }

  Future<void> signOut() async {
    await _authService.logout();
    state = null;
  }
}

// Global Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
