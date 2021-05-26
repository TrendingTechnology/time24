import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time24/constrant/app_themes.dart';

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

DateTime correctDateTime(DateTime begin, DateTime end) {
  int difference = end.difference(begin).inMinutes;
  if (difference.isNegative) {
    end = end.add(const Duration(days: 1));
  }

  return end;
}

_showDatePickerIOS(
  BuildContext context,
  Function(DateTime time) function,
  CupertinoDatePickerMode mode,
  DateTime currentDate,
) {
  var brightness = MediaQuery.of(context).platformBrightness;
  bool darkModeOn = brightness == Brightness.dark;

  showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: 500,
      color:
          darkModeOn ? AppThemes.richBlack : Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          Container(
            height: 400,
            child: CupertinoDatePicker(
              minimumYear: 2000,
              mode: mode,
              initialDateTime: currentDate,
              onDateTimeChanged: function,
            ),
          ),
          CupertinoButton(
            child: Text(AppLocalizations.of(context)!.basicOkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}

Column buildTimeField(
  BuildContext context,
  DateTime begin,
  DateTime end,
  Function(DateTime time) beginFunc,
  Function(DateTime time) endFunc,
) {
  var brightness = MediaQuery.of(context).platformBrightness;
  bool darkModeOn = brightness == Brightness.dark;

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(8, 8),
            topRight: Radius.elliptical(8, 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Beginn",
              style: Theme.of(context).textTheme.headline6,
            ),
            GestureDetector(
              onTap: () => _showDatePickerIOS(
                context,
                beginFunc,
                CupertinoDatePickerMode.time,
                begin,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color:
                      darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat.Hm().format(begin),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
        ),
        child: Divider(),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(8, 8),
            bottomRight: Radius.elliptical(8, 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.timeEditEnd,
              style: Theme.of(context).textTheme.headline6,
            ),
            GestureDetector(
              onTap: () => _showDatePickerIOS(
                context,
                endFunc,
                CupertinoDatePickerMode.time,
                end,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color:
                      darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat.Hm().format(end),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Column buildDeletableTimeField(
    BuildContext context,
    String label,
    DateTime begin,
    DateTime end,
    Function(DateTime time) beginFunc,
    Function(DateTime time) endFunc,
    Function()? deleteFunc) {
  var brightness = MediaQuery.of(context).platformBrightness;
  bool darkModeOn = brightness == Brightness.dark;

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.headline4,
          ),
          if (deleteFunc != null)
            TextButton(
              onPressed: deleteFunc,
              child: Text(
                AppLocalizations.of(context)!.basicRemoveText,
              ),
            ),
        ],
      ),
      if (deleteFunc == null) SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(8, 8),
            topRight: Radius.elliptical(8, 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.timeEditBegin,
              style: Theme.of(context).textTheme.headline6,
            ),
            GestureDetector(
              onTap: () => _showDatePickerIOS(
                context,
                beginFunc,
                CupertinoDatePickerMode.time,
                begin,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: darkModeOn ? AppThemes.black : Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat.Hm().format(begin),
                  style: TextStyle(
                    color: darkModeOn ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
        ),
        child: Divider(),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(8, 8),
            bottomRight: Radius.elliptical(8, 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.timeEditEnd,
              style: Theme.of(context).textTheme.headline6,
            ),
            GestureDetector(
              onTap: () => _showDatePickerIOS(
                context,
                endFunc,
                CupertinoDatePickerMode.time,
                end,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: darkModeOn ? AppThemes.black : Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat.Hm().format(end),
                  style: TextStyle(
                    color: darkModeOn ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
