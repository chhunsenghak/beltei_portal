import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../../features/auth/models/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final currentUserProvider = FutureProvider.autoDispose<AppUser?>((ref) async {
  final authService = ref.read(authServiceProvider);

  // onAuthStateChange is backed by a BehaviorSubject that replays the last
  // event to every new subscriber — without skip(1) that replay would
  // immediately re-trigger invalidateSelf() on every rebuild, looping forever.
  final subscription =
      Supabase.instance.client.auth.onAuthStateChange.skip(1).listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  try {
    return await authService.getProfile();
  } catch (e, st) {
    debugPrint('currentUserProvider error: $e\n$st');
    return null;
  }
});
