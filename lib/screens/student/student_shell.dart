import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'applications_screen.dart';
import 'discover_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

final studentTabIndexProvider = StateProvider<int>((ref) => 0);

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key});

  static const _screens = [
    DiscoverScreen(),
    ExploreScreen(),
    ApplicationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(studentTabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(studentTabIndexProvider.notifier).state = i,
        backgroundColor: AppColors.black,
        // Removed const here — AppColors.primaryRed is not a const value
        indicatorColor: AppColors.primaryRed.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryRed),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppColors.primaryRed),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.primaryRed),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryRed),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
