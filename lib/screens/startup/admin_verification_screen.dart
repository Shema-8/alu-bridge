import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/startup_provider.dart';

class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStartupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Startup verification')),
      body: SafeArea(
        child: pendingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
              child: Text('Could not load pending startups.',
                  style: const TextStyle(color: AppColors.grey400))),
          data: (pending) {
            if (pending.isEmpty) {
              return const Center(
                child: Text('No startups awaiting review.',
                    style: TextStyle(color: AppColors.grey400)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final startup = pending[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.name,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${startup.industry} · ${startup.founderName}',
                          style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
                      const SizedBox(height: 8),
                      Text(startup.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(38),
                                side: const BorderSide(color: AppColors.error),
                                foregroundColor: AppColors.error,
                              ),
                              onPressed: () => ref
                                  .read(startupControllerProvider.notifier)
                                  .reject(startup.startupId),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(38)),
                              onPressed: () => ref
                                  .read(startupControllerProvider.notifier)
                                  .approve(startup.startupId),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
