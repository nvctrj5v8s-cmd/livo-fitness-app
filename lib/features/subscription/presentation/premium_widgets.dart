import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/subscription_plans.dart';
import 'premium_format.dart';

/// Marks premium features with icon and text, never with color alone.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({this.label = 'Premium', super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.mint],
      ),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.workspace_premium_rounded,
          size: 13,
          color: AppColors.black,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Shown below the free recipes. Free accounts do not load premium recipes
/// at all (RLS), so this card is the honest pointer to the rest.
class PremiumRecipesCard extends StatelessWidget {
  const PremiumRecipesCard({required this.onUnlock, super.key});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('premium-recipes-card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.surfaceHigh, AppColors.primary, 0.13)!,
            AppColors.surface,
            Color.lerp(AppColors.surface, AppColors.mint, 0.06)!,
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumBadge(),
              const SizedBox(height: 12),
              Text(
                'Mehr Rezepte mit Premium',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _Line(
                icon: Icons.lock_outline_rounded,
                color: AppColors.textMuted,
                text: PremiumCopy.freeRecipes,
              ),
              const SizedBox(height: 6),
              const _Line(
                icon: Icons.check_circle_rounded,
                color: AppColors.primary,
                text: PremiumCopy.premiumRecipes,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('premium-recipes-unlock'),
                onPressed: onUnlock,
                icon: const Icon(Icons.workspace_premium_rounded, size: 19),
                label: const Text('Alle Rezepte freischalten'),
              ),
              const SizedBox(height: 8),
              Text(
                '${SubscriptionPlans.trialDays} Tage kostenlos testen · endet '
                'automatisch',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RecipeStack(),
                const SizedBox(height: 16),
                details,
              ],
            );
          }
          return Row(
            children: [
              const _RecipeStack(),
              const SizedBox(width: 22),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

/// Decorative stack of locked recipe tiles.
class _RecipeStack extends StatelessWidget {
  const _RecipeStack();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      (Icons.set_meal_rounded, AppColors.orange, -0.14, Offset(0, 10)),
      (Icons.rice_bowl_rounded, AppColors.mint, 0.12, Offset(58, 8)),
      (Icons.eco_rounded, AppColors.primary, -0.02, Offset(28, 0)),
    ];
    return ExcludeSemantics(
      child: SizedBox(
        width: 136,
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (icon, color, angle, offset) in tiles)
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 76,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.4),
                          AppColors.surfaceHigh,
                        ],
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: -4,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.mint],
                  ),
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 17,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
