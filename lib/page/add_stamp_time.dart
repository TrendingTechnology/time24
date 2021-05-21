import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/time_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

      if (breaks.isEmpty) {
        breaks.add(new TimeStamp(null, null));
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
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 12, right: 12),
        child: SingleChildScrollView(
          controller: ScrollController(),
          reverse: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Closes the current page and goes back to the main page
                  GestureDetector(
                    child: Icon(Icons.chevron_left_rounded, size: 30),
                    onTap: () => Navigator.pop(context),
                  ),
                  // Saves the data from the page into the json file
                  TextButton(
                    onPressed: canSave
                        ? () async {
                            print("jeloo");
                            if (workTime.begin != null)
                              workTime.begin =
                                  getTimeToDate(currentDate, workTime.begin!);
                            if (workTime.end != null)
                              workTime.end =
                                  getTimeToDate(currentDate, workTime.end!);

                            if (breaks.isNotEmpty)
                              for (var timestamp in breaks) {
                                if (timestamp.begin != null &&
                                    timestamp.end != null) {
                                  timestamp.begin = getTimeToDate(
                                      currentDate, timestamp.begin!);
                                  timestamp.end = getTimeToDate(
                                      currentDate, timestamp.end!);
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
                                          print("Overwrite it");
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
                                week.dailyHistory
                                    .putIfAbsent(weekday, () => timestamp);
                                ath.weekHistory[weekNum] = week;
                                tsh.yearHistory.update(year, (value) => ath);
                                history.writeAll(tsh.toJson());
                                print("Updated Year $year");

                                preferences!.clear();
                              }
                            } else {
                              print("Year Not Found!");
                              WeekHistory weekHistory =
                                  new WeekHistory(weekNum);
                              weekHistory.dailyHistory
                                  .putIfAbsent(weekday, () => timestamp);
                              var ath = new AnnualHistory(year);
                              ath.weekHistory
                                  .putIfAbsent(weekNum, () => weekHistory);
                              tsh.yearHistory.putIfAbsent(year, () => ath);
                              history.writeAll(tsh.toJson());
                              print("New Year $year Created!");

                              preferences!.clear();
                            }
                          }
                        : null,
                    child: Text(
                      AppLocalizations.of(context)!.basicSaveText,
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => canSave ? Colors.orange : Colors.grey),
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Colors.orange.shade50),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information field about the selected date
                    Text(
                      pageHead!,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                        letterSpacing: -2.5,
                      ),
                    ),
                    // IconButton(
                    //   alignment: Alignment.topLeft,
                    //   splashRadius: 1,
                    //   icon: Icon(
                    //     Icons.info_outline_rounded,
                    //     size: 20,
                    //   ),
                    //   onPressed: () {},
                    //   tooltip:
                    //       "The app doesn't lose any data you entered here before.",
                    // ),
                    // Information field with the selected date
                    Text(
                      pageSubHead!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.addStampTimeDescription,
                      style: TextStyle(
                        //color: Colors.grey.shade800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Button to change the current date to another day
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
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
                        style: ButtonStyle(
                          foregroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.orange),
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.orange.shade50),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.addStampTimeChangeDay,
                        ),
                      ),
                    ),
                    _showTimeField(
                      context,
                      AppLocalizations.of(context)!.addStampTimeWorkTime,
                      AppLocalizations.of(context)!
                          .addStampTimeWorkTimeDescription,
                      workTime.begin,
                      workTime.end,
                      (time) {
                        setState(() {
                          //time = getTimeToDate(currentDate, time);
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
                          //time = getTimeToDate(currentDate, time);
                          workTime.end = time;
                          preferences!
                              .setString("workTimeEnd", time.toString());
                          if (!canSave &&
                              workTime.begin != null &&
                              workTime.end != null) {
                            canSave = true;
                          }
                        });
                      },
                      false,
                      null,
                    ),
                    for (int i = 0; i < breaks.length; i++)
                      _showTimeField(
                        context,
                        breaks.length > 1
                            ? "${AppLocalizations.of(context)!.addStampTimeBreak} #${i + 1}"
                            : AppLocalizations.of(context)!.addStampTimeBreaks,
                        AppLocalizations.of(context)!
                            .addStampTimeBreakDescription,
                        breaks[i].begin,
                        breaks[i].end,
                        (time) {
                          setState(() {
                            //time = getTimeToDate(currentDate, time);
                            breaks[i].begin = time;
                            preferences!
                                .setString("breakBegin$i", time.toString());
                          });
                        },
                        (time) {
                          setState(() {
                            //time = getTimeToDate(currentDate, time);
                            breaks[i].end = time;
                            preferences!
                                .setString("breakEnd$i", time.toString());
                          });
                        },
                        i == 0 ? false : true,
                        i,
                      ),
                    if (breaks.length < maxBreakCount)
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            breaks.add(new TimeStamp(null, null));
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .addStampTimeAddOneMoreBreak,
                          style: TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                            (states) => Colors.amber.shade50,
                          ),
                        ),
                      ),
                    SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context)!.addStampTimeNotes,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.addStampTimeNotesHintText,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: notesController,
                      onChanged: (value) {
                        preferences!.setString("notes", notesController.text);
                      },
                      maxLines: 5,
                      cursorColor: Colors.amber,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showTimeField(
    BuildContext context,
    String label,
    String description,
    DateTime? begin,
    DateTime? end,
    Function(DateTime time) beginFunc,
    Function(DateTime time) endFunc,
    bool deletable,
    int? index,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: width - 250,
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.visible,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showDatePickerIOS(
                      context,
                      beginFunc,
                      CupertinoDatePickerMode.time,
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat.Hm().format(
                            begin == null ? DateTime.parse(dayZero) : begin),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.basicToText),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDatePickerIOS(
                      context,
                      endFunc,
                      CupertinoDatePickerMode.time,
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat.Hm().format(
                            end == null ? DateTime.parse(dayZero) : end),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (deletable)
                TextButton(
                  onPressed: () {
                    setState(() {
                      breaks.removeAt(index!);

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
                  },
                  child: Text(
                    AppLocalizations.of(context)!.basicRemoveText,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.orange),
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.amber.shade50),
                  ),
                ),
            ],
          )
        ],
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
