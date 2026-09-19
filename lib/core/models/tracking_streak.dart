/// Calendar dates use UTC midnight only as a date key, avoiding DST drift.
DateTime trackingDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

int calculateTrackingStreak(Iterable<DateTime> dates, DateTime now) {
  final days = dates.map(trackingDay).toSet();
  final today = trackingDay(now);
  var cursor = days.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

class StreakCelebration {
  const StreakCelebration({
    required this.id,
    required this.date,
    required this.days,
  });
  final String id;
  final DateTime date;
  final int days;
}
