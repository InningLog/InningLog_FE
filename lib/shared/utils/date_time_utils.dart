class DateTimeUtils {
  static const _weekdaysKo = ['월', '화', '수', '목', '금', '토', '일'];

  /// Formats a date string like "2025-01-31 14:22" into "2025/01/31(금) 14:22".
  /// Returns the original [dateTimeString] if parsing fails.
  static String formatToKoreanDateTime(String dateTimeString) {
    final parsed = _parse(dateTimeString);
    if (parsed == null) return dateTimeString;
    return formatDateTime(parsed);
  }

  /// Formats a [DateTime] into "yyyy/MM/dd(E) HH:mm" with Korean weekday.
  static String formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final weekday = _weekdaysKo[(dateTime.weekday - 1) % 7];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year/$month/$day($weekday) $hour:$minute';
  }

  static DateTime? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final normalized =
        trimmed.contains('T') ? trimmed : trimmed.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }
}
