import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_details_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results   = ref.watch(filteredInternshipsProvider);
    final isLoading = ref.watch(internshipsStreamProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Explore',
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 12),
              child: Text('All available opportunities',
                  style: TextStyle(color: AppColors.grey400, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                style: const TextStyle(color: AppColors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search by title or skill',
                  prefixIcon: Icon(Icons.search, color: AppColors.grey400, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                  ? const Center(
                      child: Text('No matching opportunities.',
                          style: TextStyle(color: AppColors.grey400)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => OpportunityCard(
                        internship: results[i],
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            OpportunityDetailsScreen(internshipId: results[i].internshipId))),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
