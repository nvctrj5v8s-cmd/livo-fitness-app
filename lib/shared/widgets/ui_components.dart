import 'package:flutter/material.dart';

import '../../core/state/app_controller.dart';
import '../../core/theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.mint],
                  ),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.24),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 7),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 14), trailing!],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(action!),
          ),
      ],
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.surface,
    this.borderRadius = 24,
    this.gradient,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            borderColor ?? AppColors.borderBright,
            AppColors.border.withValues(alpha: 0.42),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Material(
          color: gradient == null ? color : Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius - 1),
          ),
          child: Ink(
            decoration: gradient == null
                ? null
                : BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(borderRadius - 1),
                  ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.backgroundRaised,
                AppColors.background,
              ],
            ),
          ),
        ),
        Positioned(
          top: -180,
          right: -120,
          child: IgnorePointer(
            child: Container(
              width: 430,
              height: 430,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -170,
          bottom: -240,
          child: IgnorePointer(
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.mint.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    this.borderRadius = 22,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: reduceMotion
                ? 1
                : _pressed
                ? 0.972
                : _hovered
                ? 1.018
                : 1,
            duration: Duration(milliseconds: _pressed ? 100 : 180),
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.radius = 24,
    this.onTap,
    this.semanticLabel = 'Profil öffnen',
    super.key,
  });

  final double radius;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bytes = AppScope.of(context).avatarBytes;
    final avatar = Hero(
      tag: 'profile-avatar',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceHigh,
        backgroundImage: bytes == null
            ? const AssetImage('assets/images/profile_avatar.webp')
            : MemoryImage(bytes),
      ),
    );
    if (onTap == null) return avatar;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}
