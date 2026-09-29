/// German number formatting for the recipe screens. Values stay numeric in
/// the models and are only formatted here.
library;

/// `1,5` – trailing zeros removed.
String formatDecimalDe(double value, {int decimals = 1}) {
  var text = value.toStringAsFixed(decimals);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text.replaceAll('.', ',');
}

/// `1.240`
String formatThousandsDe(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatKcal(double calories) =>
    '${formatThousandsDe(calories.round())} kcal';

/// Macro nutrients: whole grams from 10 g, otherwise one decimal.
String formatNutrientGrams(double grams) =>
    grams >= 10 ? '${grams.round()} g' : '${formatDecimalDe(grams)} g';

/// Salt needs more precision for small values.
String formatSaltGrams(double grams) =>
    '${formatDecimalDe(grams, decimals: grams < 1 ? 2 : 1)} g';

/// `24 Min.`, `1 Std. 10 Min.`
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes Min.';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours Std.' : '$hours Std. $rest Min.';
}

/// `07:59` or `1:05:00`.
String formatCountdown(Duration duration) {
  final totalSeconds = duration.inMilliseconds <= 0
      ? 0
      : (duration.inMilliseconds / 1000).ceil();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '${two(minutes)}:${two(seconds)}';
}

/// Spoken form for screen readers: `7 Minuten 59 Sekunden`.
String spokenDuration(Duration duration) {
  final totalSeconds = duration.inMilliseconds <= 0
      ? 0
      : (duration.inMilliseconds / 1000).ceil();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final parts = [
    if (minutes > 0) '$minutes ${minutes == 1 ? 'Minute' : 'Minuten'}',
    if (seconds > 0 || minutes == 0)
      '$seconds ${seconds == 1 ? 'Sekunde' : 'Sekunden'}',
  ];
  return parts.join(' ');
}

/// "1 Zutat", "3 Zutaten".
String countText(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
