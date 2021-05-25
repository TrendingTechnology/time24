import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:time24/app.dart';
import 'package:time24/constrant/app_themes.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/profile_settings.dart';
import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/time_utils.dart';
import 'package:time24/page/add_stamp_time.dart';
import 'package:time24/page/edit_stamp_time.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final today = DateTime.now();
  var week;

  num requiredHoursPerWeek = 0;
  num trackedHours = 0;
  num trackedHoursFromLastWeek = 0;
  num hourlyWages = 0;

  final JsonFile historyJson = new JsonFile("history");
  final JsonFile settingJson = new JsonFile("settings");

  _HomePageState() {
    var weekBegin = today.subtract(Duration(days: today.weekday - 1));
    var weekEnd = today.add(
      Duration(days: DateTime.daysPerWeek - today.weekday),
    );

    week = sprintf(
      "%s - %s",
      [
        DateFormat.MMMMEEEEd().format(weekBegin),
        DateFormat.MMMMEEEEd().format(weekEnd),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    var history = TimeStampHistory.fromJson(await historyJson.getContentAsMap);
    var settings = ProfileSettings.fromJson(await settingJson.getContentAsMap);

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
      hourlyWages = settings.loanPerHour;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: MIN_PADDING),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeViewPageTitle,
                  style: Theme.of(context).textTheme.headline1,
                ),
                Text(
                  week,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 15),
                buildTimeInformation(),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.homeViewStampTimes,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddStampTime(),
                        ),
                      ),
                      icon: Icon(Icons.library_add_outlined),
                      label: Text(
                        AppLocalizations.of(context)!.homeViewAddNewEntry,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          FutureBuilder(
            future: historyJson.getContentAsMap,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: AppThemes.primaryColor,
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
                          AppLocalizations.of(context)!.homeViewStampTimeError,
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
                  shrinkWrap: true,
                  controller: ScrollController(),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  itemCount: week.dailyHistory.length,
                  itemBuilder: (context, index) {
                    var key = week.dailyHistory.keys.elementAt(index);
                    DailyTimeStamp stamp = week.dailyHistory[key]!;
                    var weekday = DateFormat.E().format(stamp.workTime.begin!);

                    int breakTime = 0;
                    stamp.breakTime.forEach((element) {
                      if (element.begin != null && element.end != null) {
                        breakTime +=
                            element.begin!.difference(element.end!).inMinutes;
                      }
                    });

                    return Column(
                      children: [
                        if (index != 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: MIN_PADDING,
                            ),
                            child: Divider(
                              height: 1,
                              // color: Colors.grey.shade200,
                            ),
                          ),
                        Dismissible(
                          key: UniqueKey(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: MIN_PADDING,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "${stamp.workTime.begin!.day}",
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                    Text(
                                      weekday,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                              children: [
                                                TextSpan(
                                                  text: DateFormat.Hm().format(
                                                      stamp.workTime.begin!),
                                                ),
                                                TextSpan(text: " - "),
                                                TextSpan(
                                                  text: DateFormat.Hm().format(
                                                      stamp.workTime.end!),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              sprintf(
                                                AppLocalizations.of(context)!
                                                    .homeViewStampTimeBreaks,
                                                [breakTime.abs()],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        stamp.notes,
                                        maxLines: 5,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.more_horiz_rounded),
                                  splashRadius: 20,
                                )
                              ],
                            ),
                          ),
                          background: Container(
                            padding: const EdgeInsets.fromLTRB(
                              MIN_PADDING,
                              10,
                              0,
                              10,
                            ),
                            decoration: BoxDecoration(
                              color: AppThemes.primaryColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  //size: 18,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  AppLocalizations.of(context)!.basicTextEdit,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            padding: const EdgeInsets.fromLTRB(
                                0, 10, MIN_PADDING, 10),
                            decoration: BoxDecoration(
                              color: AppThemes.red,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.white,
                                  //size: 18,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  AppLocalizations.of(context)!.basicTextDelete,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          movementDuration: Duration(milliseconds: 500),
                          confirmDismiss: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              week.dailyHistory.remove(key);

                              annual.weekHistory
                                  .update(weekNumber(today), (value) => week);
                              history.yearHistory
                                  .update(today.year, (value) => annual);
                              historyJson.writeAll(history.toJson());

                              setState(() {
                                // ToDo: update the complete state right
                              });

                              return Future.value(true);
                            }

                            if (direction == DismissDirection.startToEnd) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditStampTime(
                                    date: stamp.currentDay,
                                  ),
                                ),
                              );
                            }

                            return Future.value(false);
                          },
                        )
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Column buildTimeInformation() {
    num remainingHours = requiredHoursPerWeek - trackedHours;
    num indicatorValue = (trackedHours / requiredHoursPerWeek);
    double width = MediaQuery.of(context).size.width - (MIN_PADDING * 2);

    var previousEarnings =
        NumberFormat.simpleCurrency().format(hourlyWages * trackedHours);

    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTimeInformationBox(
              context,
              trackedHours,
              AppLocalizations.of(context)!.homeViewHoursTracked,
            ),
            SizedBox(width: 15),
            (remainingHours.isNegative)
                ? buildTimeInformationBox(context, remainingHours.abs(),
                    AppLocalizations.of(context)!.homeViewOvertime)
                : buildTimeInformationBox(context, remainingHours,
                    AppLocalizations.of(context)!.homeViewRemainingHours),
          ],
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.homeViewWorkProgress,
              style: Theme.of(context).textTheme.headline2,
            ),
            Text(
              NumberFormat.decimalPercentPattern(decimalDigits: 2)
                  .format(indicatorValue),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 20,
              width: width,
              decoration: BoxDecoration(
                color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
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
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: AppThemes.blue,
                  )
                ],
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    AppThemes.neonBlue,
                    AppThemes.primaryColor,
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.clip,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headline6,
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
            // SizedBox(width: 10),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Text(
            //     emoji,
            //     style: TextStyle(
            //       fontSize: 40,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Expanded buildTimeInformationBox(
    BuildContext context,
    num value,
    String text,
  ) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 110,
        decoration: BoxDecoration(
          color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: darkModeOn ? AppThemes.richBlack : Colors.grey.shade300,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headline1,
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
