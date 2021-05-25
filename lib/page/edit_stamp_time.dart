import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time24/app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time24/constrant/app_themes.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/time_utils.dart';

class EditStampTime extends StatefulWidget {
  EditStampTime({Key? key, required this.date}) : super(key: key);

  final DateTime date;

  @override
  _EditStampTimeState createState() => _EditStampTimeState(this.date);
}

class _EditStampTimeState extends State<EditStampTime> {
  final DateTime date;
  final JsonFile json = new JsonFile("history");
  final DateTime zero = DateTime.parse("0000-00-00 00:00:00");

  TextEditingController notesController = new TextEditingController(text: "");

  DailyTimeStamp? timeStamp;
  TimeStamp workTime = new TimeStamp(DateTime.now(), DateTime.now());
  List<TimeStamp> breakTimes = [];

  _EditStampTimeState(this.date);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  _loadPrefs() async {
    TimeStampHistory history =
        TimeStampHistory.fromJson(await json.getContentAsMap);

    AnnualHistory annual = history.yearHistory[date.year]!;
    WeekHistory week = annual.weekHistory[weekNumber(date)]!;
    timeStamp = week.dailyHistory[date.weekday];

    setState(() {
      workTime.begin = timeStamp!.workTime.begin!;
      workTime.end = timeStamp!.workTime.end!;
      breakTimes = timeStamp!.breakTime;
      notesController.text = timeStamp!.notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom + 20;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

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
        title: Text(
          DateFormat.MMMMEEEEd().format(this.date),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Not Importent Right Now.
              // Communicate with the user, that a break isn't filled?
              for (int index = 0; index < breakTimes.length; index++) {
                TimeStamp breakTime = breakTimes[index];

                if (breakTime.begin!.compareTo(zero) == 0 &&
                    breakTime.end!.compareTo(zero) == 0) {
                  breakTimes.remove(breakTime);
                }
              }

              TimeStampHistory history = TimeStampHistory.fromJson(
                await json.getContentAsMap,
              );

              AnnualHistory annual = history.yearHistory[date.year]!;
              WeekHistory week = annual.weekHistory[weekNumber(date)]!;
              week.dailyHistory.update(date.weekday, (value) => timeStamp!);
              annual.weekHistory.update(weekNumber(date), (value) => week);
              history.yearHistory.update(date.year, (value) => annual);
              json.writeAll(history.toJson());

              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.basicSaveText,
            ),
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SafeArea(
          minimum: const EdgeInsets.only(left: MIN_PADDING, right: MIN_PADDING),
          child: SingleChildScrollView(
            reverse: true,
            controller: ScrollController(),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.timeEditInformationMessage,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 10),
                  buildDeletableTimeField(
                    context,
                    AppLocalizations.of(context)!.addStampTimeWorkTime,
                    workTime.begin!,
                    workTime.end!,
                    (time) {
                      setState(() {
                        workTime.begin = time;
                      });
                    },
                    (time) {
                      setState(() {
                        workTime.end = time;
                      });
                    },
                    null,
                  ),
                  SizedBox(height: 10),
                  for (int i = 0; i < breakTimes.length; i++)
                    buildDeletableTimeField(
                      context,
                      breakTimes.length > 1
                          ? "${AppLocalizations.of(context)!.addStampTimeBreak} #${i + 1}"
                          : AppLocalizations.of(context)!.addStampTimeBreak,
                      breakTimes[i].begin!,
                      breakTimes[i].end!,
                      (time) {
                        setState(() {
                          breakTimes[i].begin = time;
                        });
                      },
                      (time) {
                        setState(() {
                          breakTimes[i].end = time;
                        });
                      },
                      (breakTimes.length <= 3)
                          ? () {
                              setState(() {
                                breakTimes.removeAt(i);
                              });
                            }
                          : null,
                    ),
                  if (breakTimes.length < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            breakTimes.add(new TimeStamp(zero, zero));
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
                    onEditingComplete: () {
                      timeStamp!.notes = notesController.text;
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    maxLines: 5,
                    cursorColor: AppThemes.primaryColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      fillColor: darkModeOn
                          ? AppThemes.richBlack
                          : Colors.grey.shade300,
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
}
