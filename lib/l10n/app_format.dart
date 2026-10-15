import 'l10n.dart';

/// Numbers, money and dates in the format of the active language.
///
/// German: `1.240`, `6,99 €`, `14.10.2026, 14:30 Uhr`.
/// English (British, unambiguous in Europe): `1,240`, `€6.99`,
/// `14 Oct 2026, 14:30`.
///
/// Every method takes an optional [code] (`de` or `en`); without it the
/// active language (`L10n.code`) is used.
abstract final class AppFormat {
  static const _nbsp = ' ';

  static bool _en(String? code) => (code ?? L10n.code) == 'en';

  /// Whole number with thousands separator: `1.240` / `1,240`.
  static String integer(num value, {String? code}) {
    final digits = value.round().abs().toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        grouped.write(_en(code) ? ',' : '.');
      }
      grouped.write(digits[i]);
    }
    return '${value.round() < 0 ? '-' : ''}$grouped';
  }

  /// Decimal number with up to [maxDecimals] digits after the separator;
  /// trailing zeros are dropped: `2,5` / `2.5`, `3` / `3`.
  static String decimal(num value, {int maxDecimals = 1, String? code}) {
    var text = value.toStringAsFixed(maxDecimals);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    if (text.contains('.')) {
      final parts = text.split('.');
      final whole = integer(int.parse(parts[0]).abs(), code: code);
      final sign = value < 0 ? '-' : '';
      return '$sign$whole${_en(code) ? '.' : ','}${parts[1]}';
    }
    return integer(num.parse(text), code: code);
  }

  /// Euro amount from cents: `6,99 €` / `€6.99`. The non-breaking space keeps
  /// German amounts on one line.
  static String euro(int cents, {String? code}) {
    final euros = integer(cents ~/ 100, code: code);
    final rest = (cents.abs() % 100).toString().padLeft(2, '0');
    return _en(code) ? '€$euros.$rest' : '$euros,$rest$_nbsp€';
  }

  /// Energy: `1.240 kcal` / `1,240 kcal`.
  static String kcal(num value, {String? code}) =>
      '${integer(value, code: code)}${_nbsp}kcal';

  /// Weight in grams: `35 g`.
  static String grams(num value, {String? code}) =>
      '${decimal(value, code: code)}${_nbsp}g';

  static const _monthsDe = [
    // l10n-ignore
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', // l10n-ignore
    'August', 'September', 'Oktober', 'November', 'Dezember',
  ];
  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdaysDe = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', //
    'Sonntag',
  ];
  static const _weekdaysEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
    'Sunday',
  ];

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Full month name: `Oktober` / `October`.
  static String monthName(int month, {String? code}) =>
      (_en(code) ? _monthsEn : _monthsDe)[month - 1];

  /// Short month name: `Okt.` / `Oct`.
  static String monthShort(int month, {String? code}) {
    final name = monthName(month, code: code);
    if (_en(code)) return name.substring(0, 3);
    return name.length <= 4 ? name : '${name.substring(0, 3)}.';
  }

  /// Full weekday name: `Dienstag` / `Tuesday`.
  static String weekdayName(DateTime date, {String? code}) =>
      (_en(code) ? _weekdaysEn : _weekdaysDe)[date.weekday - 1];

  /// Short weekday: `Di` / `Tue`.
  static String weekdayShort(DateTime date, {String? code}) =>
      weekdayName(date, code: code).substring(0, _en(code) ? 3 : 2);

  /// Date: `14.10.2026` / `14 Oct 2026`.
  static String date(DateTime value, {String? code}) {
    final local = value.toLocal();
    return _en(code)
        ? '${local.day} ${monthShort(local.month, code: code)} ${local.year}'
        : '${_two(local.day)}.${_two(local.month)}.${local.year}';
  }

  /// Day and month without year: `14.10.` / `14 Oct`.
  static String dayMonth(DateTime value, {String? code}) {
    final local = value.toLocal();
    return _en(code)
        ? '${local.day} ${monthShort(local.month, code: code)}'
        : '${_two(local.day)}.${_two(local.month)}.';
  }

  /// Written date: `14. Oktober 2026` / `14 October 2026`.
  static String longDate(DateTime value, {String? code}) {
    final local = value.toLocal();
    final month = monthName(local.month, code: code);
    return _en(code)
        ? '${local.day} $month ${local.year}'
        : '${local.day}. $month ${local.year}';
  }

  /// Clock time: `14:30 Uhr` / `14:30`.
  static String time(DateTime value, {String? code}) {
    final local = value.toLocal();
    final clock = '${_two(local.hour)}:${_two(local.minute)}';
    return _en(code) ? clock : '$clock${_nbsp}Uhr';
  }

  /// Date and time: `14.10.2026, 14:30 Uhr` / `14 Oct 2026, 14:30`.
  static String dateTime(DateTime value, {String? code}) =>
      '${date(value, code: code)}, ${time(value, code: code)}';
}
