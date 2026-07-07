import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/startup_model.dart';
import '../repositories/startup_repository.dart';
import 'auth_provider.dart';

final startupRepositoryProvider =
    Provider<StartupRepository>((ref) => StartupRepository());

final myStartupProvider = StreamProvider<StartupModel?>((ref) {
  final uid = ref.watch(firebaseUserProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(startupRepositoryProvider).watchByfounderId(uid);
});

/// Every startup waiting on admin review — watched by the (admin-only,
/// for now unauthenticated-gate) verification screen.
final pendingStartupsProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.watch(startupRepositoryProvider).watchPending();
});

class StartupController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> saveProfile({
    required String name,
    required String description,
    required String industry,
    required String contactEmail,
  }) async {
    final user = ref.read(firebaseUserProvider).value;
    final profile = ref.read(userProfileProvider).value;
    if (user == null) return false;

    state = const AsyncLoading();
    try {
      await ref.read(startupRepositoryProvider).createOrUpdateProfile(
            StartupModel(
              startupId: user.uid,
              name: name,
              description: description,
              industry: industry,
              founderName: profile?.name ?? '',
              contactEmail: contactEmail,
              createdAt: DateTime.now(),
            ),
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError('Could not save startup profile. Please try again.', st);
      return false;
    }
  }

  Future<void> approve(String startupId) async {
    await ref.read(startupRepositoryProvider).setStatus(startupId, VerificationStatus.verified);
  }

  Future<void> reject(String startupId) async {
    await ref.read(startupRepositoryProvider).setStatus(startupId, VerificationStatus.rejected);
  }
}

final startupControllerProvider =
    AsyncNotifierProvider<StartupController, void>(StartupController.new);
