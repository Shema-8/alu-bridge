import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/custom_button.dart';

class OpportunityDetailsScreen extends ConsumerWidget {
  final String internshipId;
  const OpportunityDetailsScreen({super.key, required this.internshipId});

  void _showApplySheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Consumer(builder: (context, ref, _) {
          final state = ref.watch(applicationControllerProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apply for this role',
                  style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Tell us why you\'re a great fit.',
                  style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 5,
                style: const TextStyle(color: AppColors.white, fontSize: 13),
                decoration: const InputDecoration(hintText: 'Cover letter...'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Submit application',
                isLoading: state.isLoading,
                onPressed: () async {
                  final ok = await ref
                      .read(applicationControllerProvider.notifier)
                      .apply(internshipId: internshipId, coverLetter: ctrl.text.trim());
                  if (ok && ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted!')),
                    );
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(internshipByIdProvider(internshipId));

    ref.listen(applicationControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => const Center(child: Text('Could not load opportunity.',
            style: TextStyle(color: AppColors.grey400))),
        data: (internship) {
          if (internship == null) return const Center(
              child: Text('This opportunity no longer exists.',
                  style: TextStyle(color: AppColors.grey400)));

          return Column(
            children: [
              // ── Hero header ─────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
                            ),
                            const Expanded(
                              child: Text('Opportunity Details',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined, color: AppColors.white, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.business, color: AppColors.primaryRed, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(internship.title,
                                      style: const TextStyle(
                                          color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    const Icon(Icons.verified, color: AppColors.primaryRed, size: 13),
                                    const SizedBox(width: 3),
                                    const Text('Verified startup',
                                        style: TextStyle(color: AppColors.grey400, fontSize: 11)),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 3-stat row matching the sample
                        Row(
                          children: [
                            _StatChip(icon: Icons.people_outline, label: '${internship.positions} spots'),
                            const SizedBox(width: 8),
                            _StatChip(icon: Icons.location_on_outlined, label: internship.remote ? 'Remote' : internship.location),
                            const SizedBox(width: 8),
                            _StatChip(icon: Icons.schedule_outlined, label: _daysLeft(internship.deadline)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text('About',
                        style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(internship.description,
                        style: const TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.6)),
                    const SizedBox(height: 20),
                    const Text('Skills required',
                        style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: internship.skillsRequired.map<Widget>((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.deepRed.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.4)),
                        ),
                        child: Text(s, style: const TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _DetailRow(icon: Icons.payments_outlined, label: internship.paid ? 'Paid position' : 'Unpaid / voluntary'),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Apply button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: PrimaryButton(
                  label: internship.isOpen ? 'Apply Now' : 'Applications Closed',
                  onPressed: internship.isOpen ? () => _showApplySheet(context, ref) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _daysLeft(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 'Closed';
    if (days == 0) return 'Last day';
    return 'Closes in $days days';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Icon(icon, size: 16, color: AppColors.grey400),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 10)),
      ]),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: AppColors.primaryRed),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(color: AppColors.grey400, fontSize: 13)),
  ]);
}
