import 'dart:async';
import 'package:flutter/foundation.dart';
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
    } catch (e, st) {
      debugPrint('signIn error: $e\n$st');
      return (user: null, error: 'An unexpected error occurred');
    }
  }

  Future<AppUser?> getProfile() async {
    try {
      final userResponse = await _client.auth.getUser().timeout(const Duration(seconds: 8));
      final user = userResponse.user ?? _client.auth.currentUser;
      if (user == null) return null;
      return _fetchProfile(user.id);
    } on AuthApiException catch (e) {
      // Locally cached session refers to a user that no longer exists server-side
      // (e.g. a local Supabase reset/reseed). Sign out so the router sends the
      // user back to login instead of retrying forever against a dead session.
      if (e.code == 'user_not_found' || e.statusCode == '403') {
        debugPrint('getProfile: stale session, signing out');
        await _client.auth.signOut();
        return null;
      }
      debugPrint('getProfile auth error: $e');
      return null;
    } on TimeoutException catch (_) {
      debugPrint('getProfile timed out');
      return null;
    } catch (e, st) {
      debugPrint('getProfile error: $e\n$st');
      return null;
    }
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
        .maybeSingle()
        .timeout(const Duration(seconds: 8));
    if (data == null) return null;
    return AppUser.fromMap(data);
  }
}
