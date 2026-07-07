import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/internship_model.dart';
import '../repositories/internship_repository.dart';
import 'startup_provider.dart';

final internshipRepositoryProvider =
    Provider<InternshipRepository>((ref) => InternshipRepository());

/// Raw real-time stream of every internship posting.
final internshipsStreamProvider = StreamProvider<List<InternshipModel>>((ref) {
  return ref.watch(internshipRepositoryProvider).watchAll();
});

/// One internship by id — `.family` lets us parameterize a provider by
/// an argument (the id), so OpportunityDetailsScreen can watch exactly
/// the document it needs instead of re-filtering the whole list.
final internshipByIdProvider =
    StreamProvider.family<InternshipModel?, String>((ref, id) {
  return ref.watch(internshipRepositoryProvider).watchById(id);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredInternshipsProvider = Provider<List<InternshipModel>>((ref) {
  final internships = ref.watch(internshipsStreamProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return internships.where((i) {
    final matchesQuery = query.isEmpty ||
        i.title.toLowerCase().contains(query) ||
        i.skillsRequired.any((s) => s.toLowerCase().contains(query));
    final matchesCategory = category == 'All' ||
        i.skillsRequired.any((s) => s.toLowerCase() == category.toLowerCase());
    return matchesQuery && matchesCategory;
  }).toList();
});

/// First 3 results — used for the "Recommended" strip on the home tab.
final recommendedInternshipsProvider = Provider<List<InternshipModel>>((ref) {
  final all = ref.watch(internshipsStreamProvider).value ?? [];
  return all.take(3).toList();
});

final myInternshipsProvider = StreamProvider<List<InternshipModel>>((ref) {
  final startup = ref.watch(myStartupProvider).value;
  if (startup == null) return const Stream.empty();
  return ref.watch(internshipRepositoryProvider).watchByStartup(startup.startupId);
});

class InternshipController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> post({
    required String title,
    required String description,
    required List<String> skills,
    required String location,
    required bool remote,
    required bool paid,
    required DateTime deadline,
    required int positions,
  }) async {
    final startup = ref.read(myStartupProvider).value;
    if (startup == null) return false;

    state = const AsyncLoading();
    try {
      await ref.read(internshipRepositoryProvider).create(
            InternshipModel(
              internshipId: '',
              startupId: startup.startupId,
              title: title,
              description: description,
              skillsRequired: skills,
              location: location,
              remote: remote,
              paid: paid,
              deadline: deadline,
              positions: positions,
              createdAt: DateTime.now(),
            ),
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError('Could not post this internship. Please try again.', st);
      return false;
    }
  }

  Future<void> remove(String internshipId) async {
    await ref.read(internshipRepositoryProvider).delete(internshipId);
  }
}

final internshipControllerProvider =
    AsyncNotifierProvider<InternshipController, void>(InternshipController.new);
