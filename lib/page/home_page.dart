import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:time24/constrant/profile_settings.dart';

import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/time_utils.dart';
import 'package:time24/page/add_stamp_time.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:math' as math;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  num requiredHoursPerWeek = 0;
  num trackedHours = 0;
  num trackedHoursFromLastWeek = 0;
  num loanPerHour = 0;

  JsonFile? historyFile;
  JsonFile? settingsFile;

  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  _loadPrefs() async {
    historyFile = new JsonFile("history");
    settingsFile = new JsonFile("settings");

    TimeStampHistory history =
        TimeStampHistory.fromJson(await historyFile!.getContentAsMap);
    ProfileSettings settings =
        ProfileSettings.fromJson(await settingsFile!.getContentAsMap);

    if (history.yearHistory.containsKey(today.year)) {
      AnnualHistory annual = history.yearHistory[today.year]!;

      if (annual.weekHistory.containsKey(weekNumber(today))) {
        WeekHistory week = annual.weekHistory[weekNumber(today)]!;

        week.dailyHistory.values.forEach((daily) {
          num x =
              daily.workTime.end!.difference(daily.workTime.begin!).inMinutes;
          setState(() {
            trackedHours += (x / 60);
          });
        });
      }
    }

    setState(() {
      requiredHoursPerWeek = settings.requiredHoursPerWeek;
      loanPerHour = settings.loanPerHour;
    });
  }

  // ToDo: FutureBuilder for the build method with a custom future method which
  //       loads all the data above. ???MAYBE???
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  radius: 20,
                  child: Text(
                    "T24",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                      letterSpacing: -2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_box_rounded,
                    size: 32,
                  ),
                  splashRadius: 32,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStampTime(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            buildWeeklyInformation(context),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeViewStampTimes,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto",
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Expanded(
              child: FutureBuilder(
                future: historyFile!.getContentAsMap,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            String.fromCharCode(0x1F629),
                            style: TextStyle(
                              fontSize: 50,
                            ),
                          ),
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .homeViewStampTimeError,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final content = snapshot.data as Map<String, dynamic>;
                  if (content.isEmpty) {
                    return Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: 270 * math.pi / 180,
                                  child: Text(
                                    String.fromCharCode(0x1F389),
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)!
                                      .homeViewStampTimeEmpty1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Roboto",
                                    letterSpacing: 2.5,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  String.fromCharCode(0x1F389),
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .homeViewStampTimeEmpty2,
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(Icons.add_box_rounded),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .homeViewStampTimeEmpty3,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  TimeStampHistory history = TimeStampHistory.fromJson(content);
                  AnnualHistory annual = history.yearHistory[today.year]!;
                  WeekHistory week = annual.weekHistory[weekNumber(today)]!;

                  return FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(
                      controller: ScrollController(),
                      itemCount: week.dailyHistory.length,
                      itemBuilder: (context, index) {
                        var value = week.dailyHistory.values.elementAt(index);
                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: getStampTimeInformationBox(value, context),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container getStampTimeInformationBox(
      DailyTimeStamp info, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String weekday =
        DateFormat.E(Platform.localeName).format(info.workTime.begin!);

    return Container(
      height: 60,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.grey.shade300,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${info.workTime.begin!.day}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weekday,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: width - 150,
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat.Hm().format(info.workTime.begin!),
                      ),
                      TextSpan(text: " - "),
                      TextSpan(
                        text: DateFormat.Hm().format(info.workTime.end!),
                      ),
                    ],
                  ),
                ),
                Text(
                  info.notes,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded),
            splashRadius: 20,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Expanded getTimeInformationBox(
      BuildContext context, num value, String information) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            Text(
              information,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Column buildWeeklyInformation(BuildContext context) {
    DateTime date = DateTime.now();
    var startOfTheWeek = date.subtract(Duration(days: date.weekday - 1));
    var endOfTheWeek =
        date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
    String week =
        DateFormat.MMMMEEEEd(Platform.localeName).format(startOfTheWeek);
    week +=
        " - " + DateFormat.MMMMEEEEd(Platform.localeName).format(endOfTheWeek);
    num remainingHours = requiredHoursPerWeek - trackedHours;
    double width = MediaQuery.of(context).size.width * 0.9;
    num indicatorValue = (trackedHours / requiredHoursPerWeek);
    var previousEarnings =
        NumberFormat.simpleCurrency().format(loanPerHour * trackedHours);
    String? motivationMessage;
    String? emoji;

    if (indicatorValue > 1.1) {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage110;
      emoji = String.fromCharCode(0x1F92F);
    } else if (indicatorValue > 1) {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage100;
      emoji = String.fromCharCode(0x1F973);
    } else if (indicatorValue > 0.75) {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage75;
      emoji = String.fromCharCode(0x231B);
    } else if (indicatorValue > 0.5) {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage50;
      emoji = String.fromCharCode(0x1F917);
    } else if (indicatorValue > 0.1) {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage10;
      emoji = String.fromCharCode(0x1F971);
    } else {
      motivationMessage =
          AppLocalizations.of(context)!.homeViewMotivationMessage0;
      emoji = String.fromCharCode(0x1F971);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.homeViewPageTitle,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
            letterSpacing: -2.5,
          ),
        ),
        Text(
          week,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getTimeInformationBox(context, trackedHours,
                AppLocalizations.of(context)!.homeViewHoursTracked),
            SizedBox(width: 25),
            (remainingHours.isNegative)
                ? getTimeInformationBox(context, remainingHours.abs(),
                    AppLocalizations.of(context)!.homeViewOvertime)
                : getTimeInformationBox(context, remainingHours,
                    AppLocalizations.of(context)!.homeViewRemainingHours),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.homeViewWorkProgress,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
                letterSpacing: -1.5,
              ),
            ),
            Text(
              NumberFormat.decimalPercentPattern(decimalDigits: 2)
                  .format(indicatorValue),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 20,
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                minWidth: 0,
                maxWidth: width,
              ),
              height: 20,
              width: width * (trackedHours / requiredHoursPerWeek),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.red.shade200,
                  )
                ],
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.orange,
                    Colors.red,
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.clip,
                text: TextSpan(
                  style: TextStyle(
                    height: 1.2,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!
                          .homeViewMoneyInformationPart1,
                    ),
                    TextSpan(
                      text: previousEarnings,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!
                          .homeViewMoneyInformationPart2,
                    ),
                    TextSpan(text: motivationMessage),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                emoji,
                style: TextStyle(fontSize: 40),
              ),
            )
          ],
        ),
      ],
    );
  }
}
