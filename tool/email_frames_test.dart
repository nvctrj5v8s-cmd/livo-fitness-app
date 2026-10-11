// Renders the animated feature pictures of the welcome e-mail with Flutter,
// so they look exactly like the app (Roboto, AppColors). Output: web/email/.
//
// Not part of the normal test run. Start it explicitly from the project root:
//   flutter test tool/email_frames_test.dart
//
// Animations play once and stop on their final frame.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fitness_ai_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const _size = Size(220, 165);
const _pixelRatio = 2.0;

void main() {
  testWidgets('render e-mail feature animations', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _render(
      tester,
      'feature-track.gif',
      frames: 26,
      build: (t) => _TrackFrame(t),
    );
    await _render(
      tester,
      'feature-coach.gif',
      frames: 40,
      build: (t) => _CoachFrame(t),
    );
  });
}

Future<void> _loadFonts() async {
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final dir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final name in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ]) {
    final bytes = File('$dir/$name').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('$dir/materialicons-regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

Future<void> _render(
  WidgetTester tester,
  String name, {
  required int frames,
  required Widget Function(double t) build,
}) async {
  final key = GlobalKey();
  img.Image? animation;
  for (var i = 0; i < frames; i++) {
    final t = i / (frames - 1);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto', brightness: Brightness.dark),
        home: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: SizedBox.fromSize(
              size: _size,
              child: Material(
                color: AppColors.surface,
                child: DefaultTextStyle(
                  style: const TextStyle(fontFamily: 'Roboto'),
                  child: build(t),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final frame = await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final result = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: data!.buffer,
        numChannels: 4,
      );
      image.dispose();
      return img.Image.from(result).convert(numChannels: 3);
    });
    frame!.frameDuration = i == frames - 1 ? 4000 : 70;
    if (animation == null) {
      animation = frame;
    } else {
      animation.addFrame(frame);
    }
  }
  final bytes = img.encodeGif(
    animation!,
    samplingFactor: 1,
    dither: img.DitherKernel.none,
  );
  Directory('web/email').createSync(recursive: true);
  File('web/email/$name').writeAsBytesSync(_withoutLoop(bytes));
  final preview = Platform.environment['EMAIL_PREVIEW_DIR'];
  if (preview != null) {
    File(
      '$preview/$name.png',
    ).writeAsBytesSync(img.encodePng(animation.frames.last));
  }
}

// Without the NETSCAPE loop block every mail client plays the GIF once.
Uint8List _withoutLoop(Uint8List bytes) {
  for (var i = 0; i + 19 <= bytes.length; i++) {
    if (bytes[i] == 0x21 &&
        bytes[i + 1] == 0xFF &&
        bytes[i + 2] == 0x0B &&
        String.fromCharCodes(bytes.sublist(i + 3, i + 14)) == 'NETSCAPE2.0') {
      return Uint8List.fromList([
        ...bytes.sublist(0, i),
        ...bytes.sublist(i + 19),
      ]);
    }
  }
  return bytes;
}

double _span(double t, double start, double end) =>
    Curves.easeOutCubic.transform(((t - start) / (end - start)).clamp(0, 1));

// ─── Tracken: calorie ring and macro bars fill up ───────────────────────────

class _TrackFrame extends StatelessWidget {
  const _TrackFrame(this.t);
  final double t;

  @override
  Widget build(BuildContext context) {
    final fill = _span(t, 0.05, 0.75);
    final kcal = (1240 * fill).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HEUTE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CustomPaint(
                    painter: _RingPainter(fill * 1240 / 2100),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _thousands(kcal),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            'von 2.100 kcal',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 7.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Macro(
                        'Protein',
                        78,
                        130,
                        AppColors.primary,
                        _span(t, 0.15, 0.8),
                      ),
                      const SizedBox(height: 9),
                      _Macro(
                        'Kohlenhydrate',
                        142,
                        240,
                        AppColors.mint,
                        _span(t, 0.22, 0.86),
                      ),
                      const SizedBox(height: 9),
                      _Macro(
                        'Fett',
                        41,
                        70,
                        AppColors.orange,
                        _span(t, 0.3, 0.92),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _thousands(int value) {
  final s = value.toString();
  return s.length > 3
      ? '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}'
      : s;
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.grams, this.goal, this.color, this.fill);
  final String label;
  final int grams;
  final int goal;
  final Color color;
  final double fill;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${(grams * fill).round()} g',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 8),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColors.surfaceSoft),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: grams / goal * fill,
                child: ColoredBox(color: color),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final ring = rect.deflate(stroke / 2);
    canvas.drawArc(
      ring,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.surfaceSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (value <= 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

// ─── KI-Coach: question, typing dots, answer types out ─────────────────────

class _CoachFrame extends StatelessWidget {
  const _CoachFrame(this.t);
  final double t;

  static const _question = 'Was kann ich heute Abend noch essen?';
  static const _answer =
      'Du hast heute noch etwa 650 kcal frei. Wie wäre eine '
      'Lachs-Tomaten-Bowl? Rund 35 g Protein.';

  @override
  Widget build(BuildContext context) {
    final ask = _span(t, 0.04, 0.2);
    final typing = ((t - 0.22) / 0.2).clamp(0.0, 1.0);
    final reveal = ((t - 0.42) / 0.45).clamp(0.0, 1.0);
    final chars = (_answer.length * reveal).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.mint],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 12,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 7),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lookin Coach',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'KI · Ernährung & Fitness',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 7),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: ask,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - ask)),
                child: const _Bubble(_question, mine: true, lines: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: reveal == 0
                ? Opacity(
                    opacity: typing > 0 ? 1 : 0,
                    child: _TypingDots(typing),
                  )
                : _Bubble(_answer.substring(0, chars), mine: false, lines: 4),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text, {required this.mine, required this.lines});
  final String text;
  final bool mine;
  final int lines;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    height: 10 + lines * 12.0,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: mine ? AppColors.primary : AppColors.surfaceHigh,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
        bottomLeft: Radius.circular(mine ? 12 : 3),
        bottomRight: Radius.circular(mine ? 3 : 12),
      ),
      border: mine ? null : Border.all(color: AppColors.border),
    ),
    child: Text(
      text,
      maxLines: lines,
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: mine ? AppColors.black : AppColors.text,
        fontSize: 8.5,
        height: 1.4,
        fontWeight: mine ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
  );
}

class _TypingDots extends StatelessWidget {
  const _TypingDots(this.value);
  final double value;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 24,
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Transform.translate(
              offset: Offset(
                0,
                -3 * math.max(0, math.sin((value * 3 - i * 0.25) * math.pi)),
              ),
              child: Container(
                width: 4.5,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
