import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final apps    = ref.watch(myApplicationsProvider).value ?? [];
    final accepted = apps.where((a) => a.status == ApplicationStatus.accepted).length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            // ── Profile hero ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.primaryRed,
                        child: Text(_initials(profile?.name ?? '?'),
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 12, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(profile?.name ?? '',
                      style: const TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(profile?.email ?? '',
                      style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ALU Student',
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(value: '${apps.length}', label: 'Applied'),
                      _Divider(),
                      _StatBox(value: '0',              label: 'Saved'),
                      _Divider(),
                      _StatBox(value: '$accepted',      label: 'Accepted'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Menu items ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuGroup(items: [
                    _MenuItem(icon: Icons.person_outline,       label: 'Edit profile',         onTap: () {}),
                    _MenuItem(icon: Icons.description_outlined, label: 'Resume and skills',    onTap: () {}),
                    _MenuItem(icon: Icons.bookmark_outline,     label: 'Saved opportunities',  onTap: () {}),
                  ]),
                  const SizedBox(height: 12),
                  _MenuGroup(items: [
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications',     onTap: () {}),
                    _MenuItem(icon: Icons.help_outline,           label: 'Help and support',  onTap: () {}),
                  ]),
                  const SizedBox(height: 12),
                  _MenuGroup(items: [
                    _MenuItem(
                      icon: Icons.logout,
                      label: 'Log out',
                      isDestructive: true,
                      onTap: () => ref.read(authControllerProvider.notifier).signOut(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(' ').where((x) => x.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return '${p.first[0]}${p.last[0]}'.toUpperCase();
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28,
    color: AppColors.grey700,
  );
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.charcoal,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Column(
          children: [
            e.value,
            if (!isLast)
              const Divider(height: 1, indent: 52, color: AppColors.grey700),
          ],
        );
      }).toList(),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? AppColors.error : AppColors.grey400),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: color, fontSize: 13))),
            if (!isDestructive)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.grey700),
          ],
        ),
      ),
    );
  }
}
