class DateUtilsHelper {
  static bool isInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month;
  }
}
