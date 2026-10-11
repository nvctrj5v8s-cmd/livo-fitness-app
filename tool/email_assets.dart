// Builds the images used by the Supabase e-mail templates in
// `supabase/templates/`. Output goes to `web/email/`, which GitHub Pages
// serves next to the web app, because e-mails can only load images by URL.
//
// Run from the project root:  dart run tool/email_assets.dart
//
// Animated GIFs play once and stop on their final frame (no endless motion).
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const _out = 'web/email';

// Lookin colours (AppColors): page, card, accent.
final _page = img.ColorRgb8(0x05, 0x07, 0x08);
final _card = img.ColorRgb8(0x0E, 0x14, 0x14);
const _accent = (0xC8, 0xFF, 0x5A);

void main() {
  Directory(_out).createSync(recursive: true);
  _writeGif('logo.gif', _logoFrames(size: 112, background: _page));
  _writeGif('hero-welcome.gif', _heroFrames(_Symbol.ring));
  _writeGif('hero-recovery.gif', _heroFrames(_Symbol.lock));
  _tile('livo-salmon-avocado-rice.webp', 'feature-recipes.jpg');
  stdout.writeln('E-Mail-Bilder in $_out erstellt.');
}

// Food photo for the recipe row of the welcome mail (shown at 220 x 165).
void _tile(String source, String name) {
  final decoded = img.decodeWebP(
    File('assets/images/recipes/$source').readAsBytesSync(),
  )!;
  const w = 440, h = 330;
  final scale = math.max(w / decoded.width, h / decoded.height);
  final resized = img.copyResize(
    decoded,
    width: (decoded.width * scale).ceil(),
    height: (decoded.height * scale).ceil(),
    interpolation: img.Interpolation.average,
  );
  final cropped = img.copyCrop(
    resized,
    x: (resized.width - w) ~/ 2,
    y: (resized.height - h) ~/ 2,
    width: w,
    height: h,
  );
  File('$_out/$name').writeAsBytesSync(img.encodeJpg(cropped, quality: 78));
}

enum _Symbol { ring, lock }

double _ease(double t) => 1 - math.pow(1 - t.clamp(0.0, 1.0), 3).toDouble();

// The Lookin mark: an open ring with a dot, drawn in over [t] (0..1).
List<img.Image> _logoFrames({
  required int size,
  required img.Color background,
}) {
  const count = 18;
  final frames = <img.Image>[];
  for (var i = 0; i < count; i++) {
    final t = i / (count - 1);
    final frame = img.Image(width: size, height: size);
    img.fill(frame, color: background);
    _drawMark(frame, size / 2, size / 2, size * 0.34, size * 0.085, t, 1);
    frame.frameDuration = i == count - 1 ? 2000 : 45;
    frames.add(frame);
  }
  return frames;
}

// Large symbol on the card colour with a soft green glow (shown at 520 x 200).
List<img.Image> _heroFrames(_Symbol symbol) {
  const w = 1040, h = 400, count = 16;
  final cx = w / 2, cy = h / 2;
  final frames = <img.Image>[];
  for (var i = 0; i < count; i++) {
    final t = i / (count - 1);
    final frame = img.Image(width: w, height: h);
    img.fill(frame, color: _card);
    _glow(frame, cx, cy, 190 * (0.6 + 0.4 * _ease(t)), 0.22 * _ease(t));
    _dots(frame, t);
    switch (symbol) {
      case _Symbol.ring:
        _drawMark(frame, cx, cy, 92, 22, t, 1);
      case _Symbol.lock:
        _drawLock(frame, cx, cy, t);
    }
    final small = img.copyResize(
      frame,
      width: 780,
      height: 300,
      interpolation: img.Interpolation.average,
    );
    small.frameDuration = i == count - 1 ? 3000 : 55;
    frames.add(small);
  }
  return frames;
}

void _glow(img.Image image, double cx, double cy, double radius, double alpha) {
  if (alpha <= 0) return;
  final r0 = _card.r, g0 = _card.g, b0 = _card.b;
  final x1 = math.max(0, (cx - radius).floor());
  final x2 = math.min(image.width - 1, (cx + radius).ceil());
  final y1 = math.max(0, (cy - radius).floor());
  final y2 = math.min(image.height - 1, (cy + radius).ceil());
  for (var y = y1; y <= y2; y++) {
    for (var x = x1; x <= x2; x++) {
      final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy)) / radius;
      if (d >= 1) continue;
      final a = alpha * math.pow(1 - d, 2);
      image.setPixelRgb(
        x,
        y,
        (r0 + (_accent.$1 - r0) * a).round(),
        (g0 + (_accent.$2 - g0) * a).round(),
        (b0 + (_accent.$3 - b0) * a).round(),
      );
    }
  }
}

// A few small accent dots around the symbol that fade in.
void _dots(img.Image image, double t) {
  const spots = [
    (300.0, 110.0, 5),
    (760.0, 96.0, 4),
    (240.0, 280.0, 3),
    (812.0, 300.0, 6),
    (690.0, 340.0, 3),
    (360.0, 330.0, 4),
  ];
  final a = _ease((t - 0.35) / 0.65);
  for (final (x, y, r) in spots) {
    _disc(image, x, y, r.toDouble(), a * 0.55);
  }
}

// Anti-aliased filled circle blended over the existing pixels.
void _disc(img.Image image, double cx, double cy, double r, double alpha) {
  if (alpha <= 0 || r <= 0) return;
  for (var y = (cy - r - 1).floor(); y <= (cy + r + 1).ceil(); y++) {
    for (var x = (cx - r - 1).floor(); x <= (cx + r + 1).ceil(); x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      final cover = (r + 0.5 - d).clamp(0.0, 1.0) * alpha;
      if (cover > 0) _blend(image, x, y, cover);
    }
  }
}

void _blend(img.Image image, int x, int y, double a) {
  final p = image.getPixel(x, y);
  final c = _accentOverride ?? _accent;
  image.setPixelRgb(
    x,
    y,
    (p.r + (c.$1 - p.r) * a).round(),
    (p.g + (c.$2 - p.g) * a).round(),
    (p.b + (c.$3 - p.b) * a).round(),
  );
}

// Thick anti-aliased arc from [start] sweeping [sweep] radians (clockwise,
// 0 = up), with round caps.
void _arc(
  img.Image image,
  double cx,
  double cy,
  double radius,
  double stroke,
  double start,
  double sweep,
) {
  if (sweep <= 0) return;
  final half = stroke / 2;
  final outer = radius + half + 1;
  for (var y = (cy - outer).floor(); y <= (cy + outer).ceil(); y++) {
    for (var x = (cx - outer).floor(); x <= (cx + outer).ceil(); x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      final dx = x - cx, dy = y - cy;
      final d = math.sqrt(dx * dx + dy * dy);
      var angle = math.atan2(dx, -dy) - start;
      angle %= 2 * math.pi;
      double cover;
      if (angle <= sweep) {
        cover = (half + 0.5 - (d - radius).abs()).clamp(0.0, 1.0);
      } else {
        cover = 0;
      }
      // Round caps at both ends.
      for (final end in [start, start + sweep]) {
        final ex = cx + radius * math.sin(end),
            ey = cy - radius * math.cos(end);
        final de = math.sqrt((x - ex) * (x - ex) + (y - ey) * (y - ey));
        cover = math.max(cover, (half + 0.5 - de).clamp(0.0, 1.0));
      }
      if (cover > 0) _blend(image, x, y, cover);
    }
  }
}

// Thick anti-aliased line with round caps.
void _line(
  img.Image image,
  double x1,
  double y1,
  double x2,
  double y2,
  double stroke,
) {
  final half = stroke / 2;
  final minX = (math.min(x1, x2) - half - 1).floor();
  final maxX = (math.max(x1, x2) + half + 1).ceil();
  final minY = (math.min(y1, y2) - half - 1).floor();
  final maxY = (math.max(y1, y2) + half + 1).ceil();
  final vx = x2 - x1, vy = y2 - y1;
  final len2 = vx * vx + vy * vy;
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      var u = len2 == 0 ? 0.0 : ((x - x1) * vx + (y - y1) * vy) / len2;
      u = u.clamp(0.0, 1.0);
      final px = x1 + u * vx, py = y1 + u * vy;
      final d = math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
      final cover = (half + 0.5 - d).clamp(0.0, 1.0);
      if (cover > 0) _blend(image, x, y, cover);
    }
  }
}

// Open ring (gap at the top right, like the app icon) plus centre dot.
void _drawMark(
  img.Image image,
  double cx,
  double cy,
  double radius,
  double stroke,
  double t,
  double scale,
) {
  const gapStart = 0.85; // radians after "up" where the gap ends
  const fullSweep = 2 * math.pi - 0.75;
  _arc(image, cx, cy, radius, stroke, gapStart, fullSweep * _ease(t / 0.75));
  final dotT = _ease((t - 0.55) / 0.45);
  // Small overshoot so the dot "pops".
  final pop = dotT < 1 ? dotT * (1 + 0.25 * math.sin(dotT * math.pi)) : 1.0;
  _disc(image, cx, cy, radius * 0.36 * pop, dotT == 0 ? 0 : 1);
}

void _drawLock(img.Image image, double cx, double cy, double t) {
  const stroke = 20.0;
  final top = cy - 30, bottom = cy + 82;
  // Shackle drops into place and closes.
  final drop = 34 * (1 - _ease((t - 0.2) / 0.6));
  final shackleY = cy - 58 - drop;
  final legEnd = top + 4;
  _arc(image, cx, shackleY, 46, stroke, -math.pi / 2, math.pi);
  _line(image, cx - 46, shackleY, cx - 46, legEnd, stroke);
  _line(
    image,
    cx + 46,
    shackleY,
    cx + 46,
    math.min(legEnd, shackleY + 18 + 30 * _ease((t - 0.6) / 0.4)),
    stroke,
  );
  // Solid body with a keyhole.
  final appear = _ease(t / 0.35);
  _roundRect(image, cx - 84, top, cx + 84, bottom, 22, appear);
  final keyhole = _ease((t - 0.65) / 0.35);
  if (keyhole > 0) {
    final saved = _accentOverride;
    _accentOverride = (_card.r.toInt(), _card.g.toInt(), _card.b.toInt());
    _disc(image, cx, cy + 18, 15 * keyhole, 1);
    _line(image, cx, cy + 18, cx, cy + 18 + 28 * keyhole, 11);
    _accentOverride = saved;
  }
}

// Filled rounded rectangle blended over the existing pixels.
void _roundRect(
  img.Image image,
  double x1,
  double y1,
  double x2,
  double y2,
  double r,
  double alpha,
) {
  if (alpha <= 0) return;
  for (var y = y1.floor(); y <= y2.ceil(); y++) {
    for (var x = x1.floor(); x <= x2.ceil(); x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      final qx = math.max(0.0, math.max(x1 + r - x, x - (x2 - r)));
      final qy = math.max(0.0, math.max(y1 + r - y, y - (y2 - r)));
      final d = math.sqrt(qx * qx + qy * qy) - r;
      final edge = math.min(math.min(x - x1, x2 - x), math.min(y - y1, y2 - y));
      final cover = math.min(
        (0.5 - d).clamp(0.0, 1.0),
        (edge + 0.5).clamp(0.0, 1.0),
      );
      if (cover > 0) _blend(image, x, y, cover * alpha);
    }
  }
}

(int, int, int)? _accentOverride;

void _writeGif(String name, List<img.Image> frames) {
  final animation = frames.first;
  for (final frame in frames.skip(1)) {
    animation.addFrame(frame);
  }
  final preview = Platform.environment['EMAIL_PREVIEW_DIR'];
  if (preview != null) {
    File('$preview/$name.png').writeAsBytesSync(img.encodePng(frames.last));
  }
  final bytes = img.encodeGif(
    animation,
    samplingFactor: 1,
    dither: img.DitherKernel.none,
  );
  File('$_out/$name').writeAsBytesSync(_withoutLoop(bytes));
}

// The encoder always writes a NETSCAPE loop block. Without it, every mail
// client plays the animation exactly once and keeps the last frame.
Uint8List _withoutLoop(Uint8List bytes) {
  const marker = 'NETSCAPE2.0';
  for (var i = 0; i + 19 <= bytes.length; i++) {
    if (bytes[i] == 0x21 &&
        bytes[i + 1] == 0xFF &&
        bytes[i + 2] == 0x0B &&
        String.fromCharCodes(bytes.sublist(i + 3, i + 14)) == marker) {
      return Uint8List.fromList([
        ...bytes.sublist(0, i),
        ...bytes.sublist(i + 19),
      ]);
    }
  }
  return bytes;
}
