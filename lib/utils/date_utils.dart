import 'package:intl/intl.dart';

/// Utilitaire pour la gestion des dates
class DateUtils {
  /// Formats de date
  static final DateFormat formatFull = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final DateFormat formatShort = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat formatMonth = DateFormat('MMMM yyyy', 'fr_FR');
  static final DateFormat formatMonthShort = DateFormat('MMM yyyy', 'fr_FR');
  static final DateFormat formatDay = DateFormat('EEEE dd MMMM', 'fr_FR');
  static final DateFormat formatTime = DateFormat('HH:mm', 'fr_FR');

  /// Formate une date au format complet
  static String formatFullDate(DateTime date) {
    return formatFull.format(date);
  }

  /// Formate une date au format court
  static String formatShortDate(DateTime date) {
    return formatShort.format(date);
  }

  /// Formate une date au format mois
  static String formatMonthYear(DateTime date) {
    return formatMonth.format(date);
  }

  /// Formate une date de manière relative (aujourd'hui, hier, etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Aujourd\'hui à ${formatTime.format(date)}';
    } else if (dateDay == yesterday) {
      return 'Hier à ${formatTime.format(date)}';
    } else if (dateDay.isAfter(today.subtract(const Duration(days: 7)))) {
      return '${DateFormat('EEEE', 'fr_FR').format(date)} à ${formatTime.format(date)}';
    } else if (dateDay.year == now.year) {
      return formatDay.format(date);
    } else {
      return formatShort.format(date);
    }
  }

  /// Obtient le début du mois
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Obtient la fin du mois
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Obtient le début de la semaine
  static DateTime getWeekStart(DateTime date, {int firstDayOfWeek = 1}) {
    final daysToSubtract = (date.weekday - firstDayOfWeek) % 7;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Obtient la fin de la semaine
  static DateTime getWeekEnd(DateTime date, {int firstDayOfWeek = 1}) {
    final weekStart = getWeekStart(date, firstDayOfWeek: firstDayOfWeek);
    return weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  /// Obtient le début de l'année
  static DateTime getYearStart(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Obtient la fin de l'année
  static DateTime getYearEnd(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  /// Obtient le début du jour
  static DateTime getDayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Obtient la fin du jour
  static DateTime getDayEnd(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Vérifie si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifie si une date est dans le mois en cours
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Vérifie si une date est dans l'année en cours
  static bool isCurrentYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Obtient la liste des jours entre deux dates
  static List<DateTime> getDaysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = getDayStart(start);
    final endDay = getDayStart(end);

    while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Obtient le nombre de jours entre deux dates
  static int getDaysCount(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Obtient le nom du mois
  static String getMonthName(int month) {
    final date = DateTime(2024, month, 1);
    return formatMonth.format(date);
  }

  /// Parse une date depuis une chaîne
  static DateTime? parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        return formatShort.parse(dateStr);
      } catch (e) {
        return null;
      }
    }
  }
}
