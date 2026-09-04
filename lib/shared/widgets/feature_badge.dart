import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FeatureBadge extends StatelessWidget {
  const FeatureBadge({
    this.label = 'VORSCHAU',
    this.icon = Icons.auto_awesome_rounded,
    super.key,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.forest),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.forest,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
