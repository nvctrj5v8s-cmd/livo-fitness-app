import '../../../l10n/l10n.dart';

part 'coach_sources.g.dart';

class CoachSource {
  const CoachSource({
    required this.id,
    required this.title,
    required this.url,
    required this.checked,
    required this.summaryDe,
    required this.summaryEn,
  });

  final String id;
  final String title;
  final String url;
  final String checked;
  final String summaryDe;
  final String summaryEn;
  Uri get uri => Uri.parse(url);
  String get summary => L10n.isEnglish ? summaryEn : summaryDe;
}

class CitedCoachAnswer {
  const CitedCoachAnswer(this.text, this.sources);

  final String text;
  final List<CoachSource> sources;
}

/// Parse only complete, server-generated footers with exact allowlisted URLs.
/// Other Markdown links remain plain text and cannot launch arbitrary sites.
CitedCoachAnswer parseCitedCoachAnswer(String text) {
  final marker = RegExp(r'\n\n(?:Quellen|Sources):\n').firstMatch(text);
  if (marker == null) return CitedCoachAnswer(text, const []);
  final lines = text.substring(marker.end).trim().split('\n');
  final result = <CoachSource>[];
  for (final line in lines) {
    final link = RegExp(
      r'^\[(\d+)\] \[[^\]]+\]\((https://[^\s)]+)\)$',
    ).firstMatch(line.trim());
    if (link == null || int.parse(link.group(1)!) != result.length + 1) {
      return CitedCoachAnswer(text, const []);
    }
    final source = coachSources.where((entry) => entry.url == link.group(2));
    if (source.isEmpty || result.contains(source.first)) {
      return CitedCoachAnswer(text, const []);
    }
    result.add(source.first);
  }
  return CitedCoachAnswer(text.substring(0, marker.start), result);
}
