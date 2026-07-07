import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_details_screen.dart';

const _categories = [
  {'label': 'Design',    'icon': Icons.brush_outlined},
  {'label': 'Flutter',   'icon': Icons.code_outlined},
  {'label': 'Marketing', 'icon': Icons.campaign_outlined},
  {'label': 'Data',      'icon': Icons.bar_chart_outlined},
  {'label': 'Business',  'icon': Icons.business_center_outlined},
  {'label': 'Research',  'icon': Icons.science_outlined},
];

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile   = ref.watch(userProfileProvider).value;
    final allAsync  = ref.watch(internshipsStreamProvider);
    final recommended = ref.watch(recommendedInternshipsProvider);
    final selected  = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: allAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.grey400))),
          data: (internships) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [

              // ── Greeting + notification ──────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${profile?.name.split(' ').first ?? 'there'} 👋',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Find meaningful ways to contribute.',
                            style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryRed,
                    child: Text(
                      _initials(profile?.name ?? '?'),
                      style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Search ────────────────────────────────────────────────
              TextField(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                style: const TextStyle(color: AppColors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search opportunities...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey400, size: 20),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.white, size: 15),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ── Recommended horizontal cards ─────────────────────────
              if (recommended.isNotEmpty) ...[
                _SectionHeader(title: 'Recommended', onSeeAll: () {}),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommended.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final item = recommended[i];
                      return _RecommendedCard(
                        internship: item,
                        color: _cardColors[i % _cardColors.length],
                        onTap: () => _goDetails(context, item.internshipId),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Browse by category ───────────────────────────────────
              _SectionHeader(title: 'Browse by category', onSeeAll: null),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 4,
                childAspectRatio: 0.78,
                children: _categories.map((cat) {
                  final label = cat['label'] as String;
                  final icon  = cat['icon']  as IconData;
                  final isSel = selected == label;
                  return GestureDetector(
                    onTap: () => ref.read(selectedCategoryProvider.notifier).state =
                        isSel ? 'All' : label,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primaryRed : AppColors.charcoal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon,
                              size: 20,
                              color: isSel ? AppColors.white : AppColors.grey400),
                        ),
                        const SizedBox(height: 5),
                        Text(label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isSel ? AppColors.white : AppColors.grey400,
                                fontSize: 9)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // ── Recent opportunities ─────────────────────────────────
              _SectionHeader(title: 'Recent opportunities', onSeeAll: null),
              const SizedBox(height: 10),
              if (internships.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No opportunities yet. Check back soon.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grey400)),
                  ),
                )
              else
                ...internships.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OpportunityCard(
                        internship: item,
                        onTap: () => _goDetails(context, item.internshipId),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  void _goDetails(BuildContext context, String id) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OpportunityDetailsScreen(internshipId: id)),
      );

  String _initials(String name) {
    final p = name.trim().split(' ').where((x) => x.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return '${p.first[0]}${p.last[0]}'.toUpperCase();
  }
}

const _cardColors = [
  Color(0xFF9B1B2A),
  Color(0xFF1A1A2E),
  Color(0xFF2C0E0E),
];

class _RecommendedCard extends StatelessWidget {
  final dynamic internship;
  final Color color;
  final VoidCallback onTap;
  const _RecommendedCard({required this.internship, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business, color: AppColors.white, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_outline, color: AppColors.white, size: 14),
                ),
              ],
            ),
            const Spacer(),
            Text(internship.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(internship.remote ? 'Remote' : internship.location,
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              children: [
                ...(internship.skillsRequired as List).take(2).map((s) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s,
                          style: const TextStyle(color: AppColors.white, fontSize: 9)),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See all',
                style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
          ),
      ],
    );
  }
}
