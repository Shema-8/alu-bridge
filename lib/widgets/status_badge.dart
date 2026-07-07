import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/application_model.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const StatusBadge({super.key, required this.status});

  ({Color bg, Color fg, String label}) get _style {
    switch (status) {
      case ApplicationStatus.accepted:
        return (bg: const Color(0xFF173404), fg: AppColors.success, label: 'Accepted');
      case ApplicationStatus.interview:
        return (bg: const Color(0xFF412402), fg: AppColors.warning, label: 'Interview');
      case ApplicationStatus.reviewed:
        return (bg: AppColors.charcoal, fg: AppColors.grey400, label: 'Reviewed');
      case ApplicationStatus.rejected:
        return (bg: const Color(0xFF4A1B0C), fg: AppColors.error, label: 'Rejected');
      case ApplicationStatus.pending:
        return (bg: AppColors.charcoal, fg: AppColors.grey400, label: 'Pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(8)),
      child: Text(s.label, style: TextStyle(color: s.fg, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
