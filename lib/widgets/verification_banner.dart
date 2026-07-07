import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/startup_model.dart';

class VerificationBanner extends StatelessWidget {
  final VerificationStatus status;
  const VerificationBanner({super.key, required this.status});

  ({Color bg, Color fg, IconData icon, String title, String subtitle}) get _content {
    switch (status) {
      case VerificationStatus.verified:
        return (
          bg: const Color(0xFF173404),
          fg: AppColors.success,
          icon: Icons.verified_rounded,
          title: 'Verified startup',
          subtitle: 'You can post internships and receive applications.',
        );
      case VerificationStatus.rejected:
        return (
          bg: const Color(0xFF4A1B0C),
          fg: AppColors.error,
          icon: Icons.error_outline_rounded,
          title: 'Verification rejected',
          subtitle: 'Update your profile details and it will be re-reviewed.',
        );
      case VerificationStatus.pending:
        return (
          bg: const Color(0xFF412402),
          fg: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: 'Pending verification',
          subtitle: 'An admin is reviewing your startup. Posting unlocks once verified.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _content;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(c.icon, color: c.fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: TextStyle(color: c.fg, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(c.subtitle, style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
