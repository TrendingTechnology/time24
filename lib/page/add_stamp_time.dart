import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:time24/constrant/app_themes.dart';

import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/time_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time24/page/edit_stamp_time.dart';

class AddStampTime extends StatefulWidget {
  AddStampTime({Key? key}) : super(key: key);

  @override
  _AddStampTimeState createState() => _AddStampTimeState();
}

// ToDo: Maybe switch the SharedProfile saving after the user finished to change
//       his times.
class _AddStampTimeState extends State<AddStampTime> {
  SharedPreferences? preferences;
  TextEditingController notesController = new TextEditingController(text: "");
  JsonFile history = new JsonFile("history");

  final DateTime zero = DateTime.parse("0000-00-00 00:00:00");
  final String dayZero = "0000-00-00 00:00:00";
  DateTime currentDate = DateTime.now();
  String? pageHead;
  String? pageSubHead;
  int? weekOfYear;

  bool canSave = false;

  bool isIOS = true; // implement later the android version

  int maxBreakCount = 3;
  TimeStamp workTime = new TimeStamp(null, null);
  List<TimeStamp> breaks = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    pageSubHead = DateFormat.MMMMEEEEd().format(currentDate);
  }

  _loadPreferences() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      if (preferences!.containsKey("workTimeBegin")) {
        workTime.begin =
            DateTime.parse(preferences!.getString("workTimeBegin")!);
      }

      if (preferences!.containsKey("workTimeEnd")) {
        workTime.end = DateTime.parse(preferences!.getString("workTimeEnd")!);
      }

      for (int i = 0; i < maxBreakCount; i++) {
        if (preferences!.containsKey("breakBegin$i") ||
            preferences!.containsKey("breakEnd$i")) {
          String? breakBegin = preferences!.getString("breakBegin$i");
          String? breakEnd = preferences!.getString("breakEnd$i");

          TimeStamp stampTime = TimeStamp(
            DateTime.parse(breakBegin == null ? dayZero : breakBegin),
            DateTime.parse(breakEnd == null ? dayZero : breakEnd),
          );

          breaks.add(stampTime);
        }
      }

      if (preferences!.containsKey("notes")) {
        notesController.text = preferences!.getString("notes")!;
      }

      if (!canSave && workTime.begin != null && workTime.end != null) {
        canSave = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom + 20;
    if (pageHead == null)
      pageHead = AppLocalizations.of(context)!.addStampTimeDefaultTitle;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 30,
          ),
        ),
        actions: [
          TextButton(
            onPressed: canSave
                ? () async {
                    print("jeloo");
                    if (workTime.begin != null)
                      workTime.begin =
                          getTimeToDate(currentDate, workTime.begin!);
                    if (workTime.end != null)
                      workTime.end = getTimeToDate(currentDate, workTime.end!);

                    if (breaks.isNotEmpty)
                      for (var timestamp in breaks) {
                        if (timestamp.begin != null && timestamp.end != null) {
                          timestamp.begin =
                              getTimeToDate(currentDate, timestamp.begin!);
                          timestamp.end =
                              getTimeToDate(currentDate, timestamp.end!);
                        }
                      }

                    DailyTimeStamp timestamp = new DailyTimeStamp(
                      currentDate,
                      notesController.text,
                      workTime,
                      breakTime: breaks,
                    );

                    var content = await history.getContentAsMap;
                    TimeStampHistory tsh;
                    if (content.isEmpty) {
                      tsh = new TimeStampHistory(DateTime.now());
                    } else {
                      tsh = TimeStampHistory.fromJson(content);
                    }

                    int year = currentDate.year;
                    int weekNum = weekNumber(currentDate);
                    int weekday = currentDate.weekday;
                    if (tsh.yearHistory.containsKey(year)) {
                      var ath = tsh.yearHistory[year]!;
                      print("Year $year Found!");

                      var week;
                      if (ath.weekHistory.containsKey(weekNum)) {
                        week = ath.weekHistory[weekNum]!;
                      } else {
                        week = new WeekHistory(weekNum);
                      }

                      if (week.dailyHistory.containsKey(weekday)) {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            title: Text(
                                AppLocalizations.of(context)!
                                    .addStampTimeDuplicationError,
                                style: TextStyle(color: Colors.red)),
                            message: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .addStampTimeDuplicationErrorMessage1,
                                  ),
                                  TextSpan(
                                    text: DateFormat.MMMMEEEEd()
                                        .format(currentDate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .addStampTimeDuplicationErrorMessage2,
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditStampTime(
                                        date: currentDate,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .addStampTimeDuplicationOverwrite,
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .addStampTimeDuplicationClose,
                              ),
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      } else {
                        week.dailyHistory.putIfAbsent(weekday, () => timestamp);
                        ath.weekHistory[weekNum] = week;
                        tsh.yearHistory.update(year, (value) => ath);
                        history.writeAll(tsh.toJson());
                        print("Updated Year $year");

                        preferences!.clear();
                      }
                    } else {
                      print("Year Not Found!");
                      WeekHistory weekHistory = new WeekHistory(weekNum);
                      weekHistory.dailyHistory
                          .putIfAbsent(weekday, () => timestamp);
                      var ath = new AnnualHistory(year);
                      ath.weekHistory.putIfAbsent(weekNum, () => weekHistory);
                      tsh.yearHistory.putIfAbsent(year, () => ath);
                      history.writeAll(tsh.toJson());
                      print("New Year $year Created!");

                      preferences!.clear();
                    }
                  }
                : null,
            child: Text(
              AppLocalizations.of(context)!.basicSaveText,
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SafeArea(
          minimum: const EdgeInsets.only(left: 12, right: 12),
          child: SingleChildScrollView(
            controller: ScrollController(),
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(left: 10, bottom: bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pageHead!,
                              style: Theme.of(context).textTheme.headline1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              pageSubHead!,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isIOS) {
                            _showDatePickerIOS(context, (time) {
                              int diffrence = dayDiffrence(time);
                              var days = AppLocalizations.of(context)!
                                  .addStampTimeDays;
                              var day =
                                  AppLocalizations.of(context)!.addStampTimeDay;

                              setState(() {
                                if (diffrence == 0) {
                                  pageHead = AppLocalizations.of(context)!
                                      .addStampTimeDefaultTitle;
                                } else {
                                  var ago = AppLocalizations.of(context)!
                                      .addStampTimeAgo;

                                  if (diffrence.isNegative) {
                                    pageHead = "${diffrence.abs()} ";
                                    if (diffrence < -1) {
                                      pageHead = pageHead! + days;
                                    } else {
                                      pageHead = pageHead! + day;
                                    }

                                    pageHead = sprintf(ago, [pageHead!]);
                                  } else {
                                    var text = AppLocalizations.of(context)!
                                        .addStampTimeIn;
                                    pageHead = "$diffrence ";

                                    if (diffrence > 1) {
                                      pageHead = pageHead! + days;
                                    } else {
                                      pageHead = pageHead! + day;
                                    }

                                    pageHead = sprintf(text, [pageHead!]);
                                  }
                                }

                                currentDate = time;
                                pageSubHead =
                                    DateFormat.MMMMEEEEd().format(time);
                              });
                            }, CupertinoDatePickerMode.date);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.addStampTimeChangeDay,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.addStampTimeDescription,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 10),
                  buildDeletableTimeField(
                    context,
                    AppLocalizations.of(context)!.addStampTimeWorkTime,
                    workTime.begin == null ? zero : workTime.begin!,
                    workTime.end == null ? zero : workTime.end!,
                    (time) {
                      setState(() {
                        workTime.begin = time;
                        preferences!
                            .setString("workTimeBegin", time.toString());
                        if (!canSave &&
                            workTime.begin != null &&
                            workTime.end != null) {
                          canSave = true;
                        }
                      });
                    },
                    (time) {
                      setState(() {
                        workTime.end = time;
                        preferences!.setString("workTimeEnd", time.toString());
                        if (!canSave &&
                            workTime.begin != null &&
                            workTime.end != null) {
                          canSave = true;
                        }
                      });
                    },
                    null,
                  ),
                  SizedBox(height: 10),
                  for (int i = 0; i < breaks.length; i++)
                    buildDeletableTimeField(
                      context,
                      breaks.length > 1
                          ? "${AppLocalizations.of(context)!.addStampTimeBreak} #${i + 1}"
                          : AppLocalizations.of(context)!.addStampTimeBreak,
                      breaks[i].begin == null ? zero : breaks[i].begin!,
                      breaks[i].end == null ? zero : breaks[i].end!,
                      (time) {
                        setState(() {
                          breaks[i].begin = time;
                          preferences!
                              .setString("breakBegin$i", time.toString());
                        });
                      },
                      (time) {
                        setState(() {
                          breaks[i].end = time;
                          preferences!.setString("breakEnd$i", time.toString());
                        });
                      },
                      (breaks.length <= 3)
                          ? () {
                              setState(() {
                                breaks.removeAt(i);

                                for (int i = 0; i < maxBreakCount; i++) {
                                  preferences!.remove("breakBegin$i");
                                  preferences!.remove("breakEnd$i");
                                }

                                for (int i = 0; i < breaks.length; i++) {
                                  preferences!.setString(
                                    "breakBegin$i",
                                    breaks[i].begin.toString(),
                                  );
                                  preferences!.setString(
                                    "breakEnd$i",
                                    breaks[i].end.toString(),
                                  );
                                }
                              });
                            }
                          : null,
                    ),
                  if (breaks.length < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            breaks.add(new TimeStamp(zero, zero));
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .addStampTimeAddOneMoreBreak,
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  Text(
                    AppLocalizations.of(context)!.addStampTimeNotes,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SizedBox(height: 5),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: notesController,
                    onChanged: (value) {
                      preferences!.setString("notes", notesController.text);
                    },
                    maxLines: 5,
                    cursorColor: AppThemes.primaryColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDatePickerIOS(
    BuildContext context,
    Function(DateTime time) function,
    CupertinoDatePickerMode mode,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 500,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 400,
              child: CupertinoDatePicker(
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
}
