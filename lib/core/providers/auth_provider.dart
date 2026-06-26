import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../features/auth/models/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  return ref.read(authServiceProvider).getProfile();
});
