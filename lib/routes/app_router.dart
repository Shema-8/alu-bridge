import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/startup/startup_dashboard_screen.dart';
import '../screens/student/student_shell.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUserAsync = ref.watch(firebaseUserProvider);

    return firebaseUserAsync.when(
      loading: () => const SplashScreen(),
      
      error: (err, st) => const LoginScreen(),
      data: (firebaseUser) {
        if (firebaseUser == null) return const LoginScreen();

        final profileAsync = ref.watch(userProfileProvider);
        return profileAsync.when(
          loading: () => const SplashScreen(),
          error: (err, st) => const LoginScreen(),
          data: (profile) {
            if (profile == null) return const LoginScreen();
            if (!profile.onboardingComplete) return const RoleSelectionScreen();
            return profile.role == UserRole.startup
                ? const StartupDashboardScreen()
                : const StudentShell();
          },
        );
      },
    );
  }
}
