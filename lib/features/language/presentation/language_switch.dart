import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/locale_controller.dart';

/// Small "DE | EN" switch for the pages before sign-in (introduction,
/// questions, sign-in), so nobody has to sign up first to change the
/// language. The highlight slides to the chosen language; the whole app
/// switches at once. Without a [LocaleController] in the tree (tests,
/// previews) it shows nothing.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  static const _width = 104.0;

  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);
    if (controller == null) return const SizedBox.shrink();
    final english = controller.locale.languageCode == 'en';
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 240);

    void choose(Locale locale) {
      if (controller.locale == locale) return;
      HapticFeedback.selectionClick();
      unawaited(controller.choose(locale));
    }

    return Semantics(
      container: true,
      label: context.l10n.languageSettingsTitle,
      child: SizedBox(
        width: _width,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _width - 4,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
            ),
            SizedBox(
              width: _width - 4,
              height: 36,
              child: AnimatedAlign(
                duration: duration,
                curve: Curves.easeOutCubic,
                alignment: english
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: (_width - 4) / 2 - 2,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                _Segment(
                  key: const Key('language-switch-de'),
                  code: 'DE',
                  name: 'Deutsch',
                  selected: !english,
                  duration: duration,
                  onTap: () => choose(L10n.german),
                ),
                _Segment(
                  key: const Key('language-switch-en'),
                  code: 'EN',
                  name: 'English',
                  selected: english,
                  duration: duration,
                  onTap: () => choose(L10n.english),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.code,
    required this.name,
    required this.selected,
    required this.duration,
    required this.onTap,
    super.key,
  });

  final String code;
  final String name;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        label: name,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          child: SizedBox(
            height: 48,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: duration,
                style: TextStyle(
                  color: selected ? AppColors.black : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
                child: Text(code, textScaler: TextScaler.noScaling),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
