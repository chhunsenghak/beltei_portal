import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/models/app_user.dart';

typedef SignInResult = ({AppUser? user, String? error});

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return (user: null, error: 'Login failed');
      final profile = await _fetchProfile(response.user!.id);
      if (profile == null) return (user: null, error: 'Profile not found. Contact admin.');
      return (user: profile, error: null);
    } on AuthException catch (e) {
      return (user: null, error: e.message);
    } catch (_) {
      return (user: null, error: 'An unexpected error occurred');
    }
  }

  Future<AppUser?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<AppUser?> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }
}
