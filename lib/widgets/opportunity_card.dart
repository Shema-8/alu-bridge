import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/internship_model.dart';

class OpportunityCard extends StatelessWidget {
  final InternshipModel internship;
  final VoidCallback onTap;
  final bool compact;

  const OpportunityCard({
    super.key,
    required this.internship,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.charcoal,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Company logo placeholder
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: AppColors.primaryRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(internship.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _Tag(label: internship.paid ? 'Paid' : 'Volunteer'),
                        const SizedBox(width: 6),
                        _Tag(label: internship.remote ? 'Remote' : internship.location),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bookmark_outline, size: 18, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: const TextStyle(color: AppColors.grey400, fontSize: 10)),
  );
}
