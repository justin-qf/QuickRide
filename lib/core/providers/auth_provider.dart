import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:quickride/core/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase user stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// App user provider
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await ref.read(authServiceProvider).getUserData(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current user provider (synchronous)
final currentUserProvider = StateProvider<AppUser?>((ref) => null);
