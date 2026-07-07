import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../repositories/application_repository.dart';
import 'auth_provider.dart';

final applicationRepositoryProvider =
    Provider<ApplicationRepository>((ref) => ApplicationRepository());

final myApplicationsProvider = StreamProvider<List<ApplicationModel>>((ref) {
  final uid = ref.watch(firebaseUserProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(applicationRepositoryProvider).watchForStudent(uid);
});

/// Handles the "Apply" action with loading/error state, same AsyncNotifier
/// pattern as AuthController so it's a familiar shape to explain.
class ApplicationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> apply({
    required String internshipId,
    required String coverLetter,
  }) async {
    final uid = ref.read(firebaseUserProvider).value?.uid;
    if (uid == null) return false;

    state = const AsyncLoading();
    try {
      final repo = ref.read(applicationRepositoryProvider);
      final already = await repo.hasApplied(uid, internshipId);
      if (already) {
        state = AsyncError('You already applied to this opportunity.', StackTrace.current);
        return false;
      }
      await repo.submit(ApplicationModel(
        applicationId: '',
        studentId: uid,
        internshipId: internshipId,
        coverLetter: coverLetter,
        submittedAt: DateTime.now(),
      ));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError('Could not submit application. Please try again.', st);
      return false;
    }
  }
}

final applicationControllerProvider =
    AsyncNotifierProvider<ApplicationController, void>(ApplicationController.new);
