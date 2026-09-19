import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../domain/avatar_image.dart';

Future<void> showAvatarEditor(BuildContext context) {
  final controller = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AvatarEditor(controller: controller),
  );
}

class AvatarEditor extends StatefulWidget {
  const AvatarEditor({required this.controller, super.key});
  final AppController controller;

  @override
  State<AvatarEditor> createState() => _AvatarEditorState();
}

class _AvatarEditorState extends State<AvatarEditor> {
  PreparedAvatarImage? _prepared;
  ui.Image? _preview;
  double _zoom = 1;
  double _horizontal = .5;
  double _vertical = .5;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _preview?.dispose();
    super.dispose();
  }

  Future<void> _select() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Bilder',
            extensions: ['jpg', 'jpeg', 'png'],
            mimeTypes: ['image/jpeg', 'image/png'],
            uniformTypeIdentifiers: ['public.jpeg', 'public.png'],
          ),
        ],
      );
      if (file == null || !mounted) return;
      if (await file.length() > maxAvatarSourceBytes) {
        throw const AvatarImageException('Wähle ein Bild mit höchstens 8 MB.');
      }
      final prepared = await compute(
        prepareAvatarImage,
        await file.readAsBytes(),
      );
      final codec = await ui.instantiateImageCodec(prepared.bytes);
      final ui.FrameInfo frame;
      try {
        frame = await codec.getNextFrame();
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      final previous = _preview;
      setState(() {
        _prepared = prepared;
        _preview = frame.image;
        _zoom = 1;
        _horizontal = .5;
        _vertical = .5;
      });
      previous?.dispose();
    } on AvatarImageException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Das Bild ließ sich nicht öffnen. Versuche es mit einem anderen JPG oder PNG.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final prepared = _prepared;
    if (_busy || prepared == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final jpeg = await compute(
        cropAvatarImage,
        AvatarCropRequest(
          image: prepared,
          zoom: _zoom,
          horizontal: _horizontal,
          vertical: _vertical,
        ),
      );
      final success = await widget.controller.updateAvatar(jpeg);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        return;
      }
      setState(
        () => _error =
            widget.controller.avatarError ??
            'Das Profilbild wurde nicht gespeichert. Versuche es erneut.',
      );
    } on AvatarImageException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Das Profilbild wurde nicht gespeichert. Dein bisheriges Bild bleibt erhalten.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final success = await widget.controller.removeAvatar();
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        return;
      }
      setState(
        () => _error =
            widget.controller.avatarError ??
            'Das Profilbild konnte nicht entfernt werden.',
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Das Profilbild konnte nicht entfernt werden. Versuche es erneut.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _move(DragUpdateDetails details, double size) {
    if (_busy || _prepared == null) return;
    final image = _prepared!;
    final side = math.min(image.width, image.height) / _zoom;
    setState(() {
      if (image.width > side) {
        _horizontal =
            (_horizontal -
                    details.delta.dx / size * side / (image.width - side))
                .clamp(0.0, 1.0);
      }
      if (image.height > side) {
        _vertical =
            (_vertical - details.delta.dy / size * side / (image.height - side))
                .clamp(0.0, 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: !_busy,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dein Profilbild',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Ein kleines Stück von dir.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      tooltip: 'Schließen',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = math.min(constraints.maxWidth - 12, 256.0);
                    return AnimatedContainer(
                      duration: reduced
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .12),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: SizedBox.square(
                          dimension: size,
                          child: _preview == null
                              ? AppAvatar(radius: size / 2)
                              : Semantics(
                                  label:
                                      'Bildausschnitt. Ziehe das Bild oder nutze die Regler.',
                                  child: GestureDetector(
                                    onPanUpdate: (details) =>
                                        _move(details, size),
                                    child: CustomPaint(
                                      painter: _AvatarCropPainter(
                                        _preview!,
                                        zoom: _zoom,
                                        horizontal: _horizontal,
                                        vertical: _vertical,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (_prepared != null) ...[
                  const Text(
                    'Verschiebe das Bild für deinen Ausschnitt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.zoom_out_rounded,
                        color: AppColors.textMuted,
                      ),
                      Expanded(
                        child: Slider(
                          value: _zoom,
                          min: 1,
                          max: 3,
                          label: '${_zoom.toStringAsFixed(1)}×',
                          semanticFormatterCallback: (value) =>
                              '${value.toStringAsFixed(1)}-fache Vergrößerung',
                          onChanged: _busy
                              ? null
                              : (value) => setState(() => _zoom = value),
                        ),
                      ),
                      const Icon(
                        Icons.zoom_in_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Ausschnitt fein einstellen',
                      style: TextStyle(fontSize: 12),
                    ),
                    children: [
                      _PositionSlider(
                        label: 'Links – rechts',
                        value: _horizontal,
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _horizontal = value),
                      ),
                      _PositionSlider(
                        label: 'Oben – unten',
                        value: _vertical,
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _vertical = value),
                      ),
                    ],
                  ),
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Einen Moment …',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const ValueKey('avatar-select'),
                    onPressed: _busy ? null : _select,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _prepared == null
                          ? 'Bild auswählen'
                          : 'Anderes Bild auswählen',
                    ),
                  ),
                ),
                if (_prepared != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('avatar-save'),
                      onPressed: _busy ? null : _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Profilbild speichern'),
                    ),
                  ),
                ],
                if (widget.controller.avatarBytes != null)
                  TextButton.icon(
                    key: const ValueKey('avatar-remove'),
                    onPressed: _busy ? null : _remove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Profilbild entfernen'),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'JPG oder PNG · bis 8 MB\nDein Profilbild ist nur für dein Konto sichtbar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionSlider extends StatelessWidget {
  const _PositionSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      Slider(
        value: value,
        onChanged: onChanged,
        semanticFormatterCallback: (value) =>
            '$label: ${(value * 100).round()} Prozent',
      ),
    ],
  );
}

class _AvatarCropPainter extends CustomPainter {
  const _AvatarCropPainter(
    this.image, {
    required this.zoom,
    required this.horizontal,
    required this.vertical,
  });
  final ui.Image image;
  final double zoom;
  final double horizontal;
  final double vertical;
  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(image.width, image.height) / zoom;
    final source = Rect.fromLTWH(
      (image.width - side) * horizontal,
      (image.height - side) * vertical,
      side,
      side,
    );
    canvas.drawImageRect(
      image,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_AvatarCropPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.zoom != zoom ||
      oldDelegate.horizontal != horizontal ||
      oldDelegate.vertical != vertical;
}
