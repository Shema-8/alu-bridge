import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/internship_provider.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync    = ref.watch(myApplicationsProvider);
    final internships  = ref.watch(internshipsStreamProvider).value ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('My Applications',
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('Track your internship applications',
                  style: TextStyle(color: AppColors.grey400, fontSize: 12)),
            ),
            const SizedBox(height: 16),

            // ── Status filter tabs ─────────────────────────────────
            _StatusTabs(),
            const SizedBox(height: 16),

            Expanded(
              child: appsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => const Center(
                    child: Text('Could not load applications.',
                        style: TextStyle(color: AppColors.grey400))),
                data: (apps) {
                  if (apps.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined, size: 52, color: AppColors.grey400),
                            SizedBox(height: 12),
                            Text('No applications yet',
                                style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('Browse opportunities and apply to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: apps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final app = apps[i];
                      final matches = internships.where(
                        (x) => x.internshipId == app.internshipId);
                      final internship = matches.isEmpty ? null : matches.first;
                      return _AppCard(app: app, title: internship?.title ?? 'Opportunity removed',
                          company: internship != null ? (internship.remote ? 'Remote' : internship.location) : '');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ['All', 'Pending', 'Interview', 'Accepted'].map((t) {
          final selected = t == 'All';
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryRed : AppColors.charcoal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(t,
                style: TextStyle(
                    color: selected ? AppColors.white : AppColors.grey400,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          );
        }).toList(),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final ApplicationModel app;
  final String title;
  final String company;
  const _AppCard({required this.app, required this.title, required this.company});

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(app.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: AppColors.primaryRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('${company.isNotEmpty ? '$company  ·  ' : ''}Applied ${_daysAgo(app.submittedAt)}',
                    style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
            child: Text(s.label, style: TextStyle(color: s.fg, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg, String label}) _statusStyle(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:  return (bg: const Color(0xFF173404), fg: const Color(0xFF1FAA59), label: 'Accepted');
      case ApplicationStatus.interview: return (bg: const Color(0xFF412402), fg: const Color(0xFFE6A100), label: 'Interview');
      case ApplicationStatus.reviewed:  return (bg: const Color(0xFF1A1A2E), fg: const Color(0xFF9B9BA1), label: 'Reviewed');
      case ApplicationStatus.rejected:  return (bg: const Color(0xFF4A1B0C), fg: const Color(0xFFD32F2F), label: 'Rejected');
      case ApplicationStatus.pending:   return (bg: AppColors.charcoal,      fg: AppColors.grey400,       label: 'Pending');
    }
  }

  String _daysAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'today';
    if (days == 1) return '1 day ago';
    return '$days days ago';
  }
}
