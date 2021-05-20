import 'package:intl/intl.dart';

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

int dayDiffrence(DateTime time) {
  var now = DateTime.now();
  var today = DateTime(now.year, now.month, now.day);

  return -today.difference(time).inDays;
}

DateTime getTimeToDate(DateTime current, DateTime time) {
  return new DateTime(
    current.year,
    current.month,
    current.day,
    time.hour,
    time.minute,
    time.second,
  );
}
