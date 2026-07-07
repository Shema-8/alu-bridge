import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/verification_banner.dart';
import 'admin_verification_screen.dart';
import 'create_startup_profile_screen.dart';
import 'post_internship_screen.dart';

class StartupDashboardScreen extends ConsumerWidget {
  const StartupDashboardScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String internshipId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: const Text('Delete posting?', style: TextStyle(color: AppColors.white)),
        content: Text('"$title" will be removed and students will no longer see it.',
            style: const TextStyle(color: AppColors.grey400)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(internshipControllerProvider.notifier).remove(internshipId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Dashboard'),
        actions: [
          // Temporary entry point to the admin review screen — see the
          // doc comment on AdminVerificationScreen for why this isn't
          // gated by real admin auth yet.
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Admin: review pending startups',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminVerificationScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: startupAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
              child: Text('Could not load your startup profile.',
                  style: const TextStyle(color: AppColors.grey400))),
          data: (startup) {
            if (startup == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 56, color: AppColors.primaryRed),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${profile?.name.split(' ').first ?? 'Founder'}!',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up your startup profile to get verified and '
                      'start posting internships.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey400),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Create startup profile',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateStartupProfileScreen()),
                      ),
                    ),
                  ],
                ),
              );
            }

            final isVerified = startup.status == VerificationStatus.verified;
            final myInternshipsAsync = ref.watch(myInternshipsProvider);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                VerificationBanner(status: startup.status),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(startup.name,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateStartupProfileScreen(existing: startup),
                        ),
                      ),
                      child: const Text('Edit',
                          style: TextStyle(color: AppColors.primaryRed)),
                    ),
                  ],
                ),
                Text(startup.industry,
                    style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Active internships',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    if (isVerified)
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PostInternshipScreen()),
                        ),
                        icon: const Icon(Icons.add, size: 16, color: AppColors.primaryRed),
                        label: const Text('Post new',
                            style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!isVerified)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Internship posting unlocks once your startup is verified.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grey400),
                      ),
                    ),
                  )
                else
                  myInternshipsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: Text('Could not load your postings.',
                              style: TextStyle(color: AppColors.grey400))),
                    ),
                    data: (postings) {
                      if (postings.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'You haven\'t posted anything yet.\nTap "Post new" to publish your first opportunity.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.grey400),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: postings.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.charcoal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.title,
                                          style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.positions} position${p.positions > 1 ? 's' : ''} · '
                                        '${p.isOpen ? "Open" : "Closed"}',
                                        style: TextStyle(
                                            color: p.isOpen
                                                ? AppColors.grey400
                                                : AppColors.error,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: AppColors.grey400),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, p.internshipId, p.title),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
