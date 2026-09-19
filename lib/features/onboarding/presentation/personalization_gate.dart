import 'package:flutter/material.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'personalization_page.dart';

/// Runs after sign-in. The app owns a fresh controller/Navigator per account.
class PersonalizationGate extends StatefulWidget {
  const PersonalizationGate({required this.child, super.key});
  final Widget child;

  @override
  State<PersonalizationGate> createState() => _PersonalizationGateState();
}

class _PersonalizationGateState extends State<PersonalizationGate> {
  bool _started = false;
  bool? _showQuestions;
  bool _readFailed = false;
  int _loadAttempt = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final controller = AppScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(controller);
    });
  }

  Future<void> _load(AppController controller) async {
    final attempt = ++_loadAttempt;
    setState(() => _readFailed = false);
    try {
      final record = await controller.loadPersonalization();
      if (mounted && attempt == _loadAttempt) {
        setState(() => _showQuestions = !record.hasDecision);
      }
    } catch (_) {
      if (mounted && attempt == _loadAttempt) {
        setState(() => _readFailed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (_readFailed) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Deine Einstellungen konnten nicht geladen werden.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => _load(controller),
                      child: const Text('Erneut versuchen'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _readFailed = false;
                        _showQuestions = false;
                      }),
                      child: const Text('Für jetzt fortfahren'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (_showQuestions == null) {
      return const Scaffold(
        body: Center(child: Text('Dein LIVO wird vorbereitet …')),
      );
    }
    if (!_showQuestions!) return widget.child;
    return PersonalizationPage(
      onComplete: (profile) async {
        await controller.savePersonalization(profile);
        if (mounted) setState(() => _showQuestions = false);
      },
      onLater: () async {
        var saved = true;
        try {
          await controller.deferPersonalization();
        } catch (_) {
          saved = false;
        }
        if (!mounted) return;
        setState(() => _showQuestions = false);
        if (!saved) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(
              content: Text(
                'Du kannst weitermachen. Die Fragen erscheinen beim nächsten Start möglicherweise erneut.',
              ),
            ),
          );
        }
      },
    );
  }
}
