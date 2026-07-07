import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final firebaseUserProvider = StreamProvider<User?>((ref) {
  try {
    return ref.watch(authRepositoryProvider).authStateChanges;
  } catch (_) {
    return Stream.value(null);
  }
});

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return null;
  try {
    final repo = ref.watch(authRepositoryProvider);
    return repo.fetchUserProfile(firebaseUser.uid);
  } catch (_) {
    return null;
  }
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.register(email: email, password: password, name: name);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(_repo.mapError(e), st);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _repo.login(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(_repo.mapError(e), st);
      return false;
    }
  }

  Future<bool> chooseRole(UserRole role) async {
    final uid = ref.read(firebaseUserProvider).value?.uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    try {
      await _repo.setRole(uid, role);
      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(_repo.mapError(e), st);
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      await _repo.sendPasswordReset(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_repo.mapError(e), st);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
