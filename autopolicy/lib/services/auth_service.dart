import 'api_service.dart';

class UserProfile {
  final String username;
  final String email;
  final String role; // 'Admin', 'Security Engineer', 'Manager'
  final String token;

  const UserProfile({
    required this.username,
    required this.email,
    required this.role,
    required this.token,
  });
}

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<UserProfile> login(String email, String password, String selectedRole) async {
    // Call REST endpoint simulator
    await _apiService.post('/auth/login', {
      'email': email,
      'password': '***', // sensitive
      'role': selectedRole,
    });

    // Simulate validation and token generation
    if (email.contains('@') && password.length >= 6) {
      final String username = email.split('@').first.toUpperCase();
      final String token = 'eySimulatedCyberSOCJWTToken_${selectedRole}_${DateTime.now().millisecondsSinceEpoch}';
      
      _apiService.setAuthToken(token);

      return UserProfile(
        username: username,
        email: email,
        role: selectedRole,
        token: token,
      );
    } else {
      throw Exception('Invalid security credentials or network policy violation');
    }
  }

  Future<UserProfile> signUp(String email, String password, String selectedRole) async {
    // Call REST endpoint simulator for registration
    await _apiService.post('/auth/signup', {
      'email': email,
      'password': '***',
      'role': selectedRole,
    });

    // Simulate registration check (same validation rules)
    if (email.contains('@') && password.length >= 6) {
      final String username = email.split('@').first.toUpperCase();
      final String token = 'eySimulatedCyberSOCJWTToken_${selectedRole}_${DateTime.now().millisecondsSinceEpoch}';
      
      _apiService.setAuthToken(token);

      return UserProfile(
        username: username,
        email: email,
        role: selectedRole,
        token: token,
      );
    } else {
      throw Exception('Registration rejected: weak password or network policy violation');
    }
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout', {});
    _apiService.clearAuthToken();
  }
}
