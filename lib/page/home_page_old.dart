import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time24/app.dart';
import 'package:time24/constrant/app_themes.dart';

import 'package:time24/constrant/profile_settings.dart';

import 'package:time24/constrant/time_history.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/constrant/time_utils.dart';
import 'package:time24/page/add_stamp_time.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:math' as math;

import 'edit_stamp_time.dart';

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

  late final DateTime today;
  var weekBegin;
  var weekEnd;
  var week;

  _HomePageState() {
    today = DateTime.now();
    weekBegin = today.subtract(Duration(days: today.weekday - 1));
    weekEnd = today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
    week = DateFormat.MMMMEEEEd().format(weekBegin) +
        " - " +
        DateFormat.MMMMEEEEd().format(weekEnd);
  }

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

  List<int> items = List<int>.generate(100, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),
          FutureBuilder(
            future: historyFile!.getContentAsMap,
            builder: (context, snapshot) {
              final content = snapshot.data as Map<String, dynamic>;

              TimeStampHistory history = TimeStampHistory.fromJson(content);
              AnnualHistory annual = history.yearHistory[today.year]!;
              WeekHistory week = annual.weekHistory[weekNumber(today)]!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: week.dailyHistory.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var key = week.dailyHistory.keys.elementAt(index);
                  DailyTimeStamp stamp = week.dailyHistory[key]!;
                  String weekday = DateFormat.E().format(stamp.workTime.begin!);

                  return Dismissible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    background: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppThemes.blurple,
                        // borderRadius: BorderRadius.only(
                        //   topRight: Radius.circular(8),
                        //   bottomRight: Radius.circular(8),
                        // ),
                        //borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        // borderRadius: BorderRadius.only(
                        //   topRight: Radius.circular(8),
                        //   bottomRight: Radius.circular(8),
                        // ),
                        //borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Move to trash",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    key: UniqueKey(),
                    // background: Container(
                    //   color: Colors.green,
                    // ),
                    // key: UniqueKey(),
                    // onDismissed: (DismissDirection direction) {
                    //   // setState(() {
                    //   //   items.removeAt(index);
                    //   // });
                    // },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ToDo: FutureBuilder for the build method with a custom future method which
  //       loads all the data above. ???MAYBE???
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     resizeToAvoidBottomInset: false,
  //     body: SafeArea(
  //       minimum: const EdgeInsets.only(left: 20, right: 20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             AppLocalizations.of(context)!.homeViewPageTitle,
  //             style: Theme.of(context).textTheme.headline1,
  //           ),
  //           Text(
  //             week,
  //             style: Theme.of(context).textTheme.bodyText1,
  //           ),
  //           SizedBox(height: 15),
  //           buildWeeklyInformation(context),
  //           SizedBox(height: 10),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 AppLocalizations.of(context)!.homeViewStampTimes,
  //                 style: Theme.of(context).textTheme.headline3,
  //               ),
  //               TextButton.icon(
  //                 onPressed: () => Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => AddStampTime(),
  //                   ),
  //                 ),
  //                 icon: Icon(Icons.library_add_outlined),
  //                 label: Text(
  //                   AppLocalizations.of(context)!.homeViewAddNewEntry,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 5),
  //           Expanded(
  //             flex: 1,
  //             child: FutureBuilder(
  //               future: historyFile!.getContentAsMap,
  //               builder: (context, snapshot) {
  //                 if (snapshot.connectionState != ConnectionState.done) {
  //                   return Center(
  //                     child: CircularProgressIndicator(
  //                       backgroundColor: Colors.orange,
  //                     ),
  //                   );
  //                 }

  //                 if (!snapshot.hasData) {
  //                   return Container(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           String.fromCharCode(0x1F629),
  //                           style: TextStyle(
  //                             fontSize: 50,
  //                           ),
  //                         ),
  //                         Center(
  //                           child: Text(
  //                             AppLocalizations.of(context)!
  //                                 .homeViewStampTimeError,
  //                             style: TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w700,
  //                               letterSpacing: 1,
  //                               color: Colors.red.shade700,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }

  //                 final content = snapshot.data as Map<String, dynamic>;
  //                 if (content.isEmpty) {
  //                   return Container(
  //                     child: Center(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Transform.rotate(
  //                                 angle: 270 * math.pi / 180,
  //                                 child: Text(
  //                                   String.fromCharCode(0x1F389),
  //                                   style: TextStyle(
  //                                     fontSize: 30,
  //                                   ),
  //                                 ),
  //                               ),
  //                               SizedBox(width: 5),
  //                               Text(
  //                                 AppLocalizations.of(context)!
  //                                     .homeViewStampTimeEmpty1,
  //                                 style: TextStyle(
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: "Roboto",
  //                                   letterSpacing: 2.5,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 5),
  //                               Text(
  //                                 String.fromCharCode(0x1F389),
  //                                 style: TextStyle(
  //                                   fontSize: 30,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           RichText(
  //                             text: TextSpan(
  //                               style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 16,
  //                                 letterSpacing: 1,
  //                               ),
  //                               children: [
  //                                 TextSpan(
  //                                   text: AppLocalizations.of(context)!
  //                                       .homeViewStampTimeEmpty2,
  //                                 ),
  //                                 WidgetSpan(
  //                                   alignment: PlaceholderAlignment.middle,
  //                                   child: Icon(Icons.add_box_rounded),
  //                                 ),
  //                                 TextSpan(
  //                                   text: AppLocalizations.of(context)!
  //                                       .homeViewStampTimeEmpty3,
  //                                 ),
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 }

  //                 TimeStampHistory history = TimeStampHistory.fromJson(content);
  //                 AnnualHistory annual = history.yearHistory[today.year]!;
  //                 WeekHistory week = annual.weekHistory[weekNumber(today)]!;

  //                 return FadingEdgeScrollView.fromScrollView(
  //                   child: ListView.builder(
  //                     controller: ScrollController(),
  //                     itemCount: week.dailyHistory.length,
  //                     itemBuilder: (context, index) {
  //                       var value = week.dailyHistory.values.elementAt(index);
  //                       return GestureDetector(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(5),
  //                           child: getStampTimeInformationBox(value, context),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
}

Dismissible getStampTimeInformationBox(
    DailyTimeStamp info, BuildContext context) {
  String weekday =
      DateFormat.E(Platform.localeName).format(info.workTime.begin!);
  return Dismissible(
    movementDuration: Duration(milliseconds: 500),
    confirmDismiss: (direction) {
      if (direction == DismissDirection.endToStart) {
        // ToDo: remove it

        return Future.value(true);
      }

      if (direction == DismissDirection.startToEnd) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditStampTime(
              date: info.currentDay,
            ),
          ),
        );
      }

      return Future.value(false);
    },
    key: UniqueKey(),
    onDismissed: (direction) {
      // if (direction == DismissDirection.startToEnd) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => EditStampTime(
      //         date: info.currentDay,
      //       ),
      //     ),
      //   );
      //   setState(() {});
      // }
    },
    background: Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemes.blurple,
        // borderRadius: BorderRadius.only(
        //   topRight: Radius.circular(8),
        //   bottomRight: Radius.circular(8),
        // ),
        //borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_rounded,
            color: Colors.white,
          ),
          SizedBox(width: 7),
          Text(
            "Edit",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
    secondaryBackground: Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red,
        // borderRadius: BorderRadius.only(
        //   topRight: Radius.circular(8),
        //   bottomRight: Radius.circular(8),
        // ),
        //borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
          SizedBox(width: 7),
          Text(
            "Move to trash",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
    child: Container(
      //padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade300,
      //   borderRadius: BorderRadius.circular(10),
      //   boxShadow: [
      //     BoxShadow(
      //       blurRadius: 5,
      //       color: Colors.grey.shade300,
      //     ),
      //   ],
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${info.workTime.begin!.day}",
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                weekday,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headline5,
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
                  ],
                ),
                Text(
                  info.notes,
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
            style: Theme.of(context).textTheme.headline1,
          ),
          Text(
            information,
            style: Theme.of(context).textTheme.headline6,
          )
        ],
      ),
    ),
  );
}

// Column buildWeeklyInformation(BuildContext context) {
//   num remainingHours = requiredHoursPerWeek - trackedHours;
//   double width = MediaQuery.of(context).size.width * 1;
//   num indicatorValue = (trackedHours / requiredHoursPerWeek);
//   var previousEarnings =
//       NumberFormat.simpleCurrency().format(loanPerHour * trackedHours);
//   String? motivationMessage;
//   String? emoji;

//   if (indicatorValue > 1.1) {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage110;
//     emoji = String.fromCharCode(0x1F92F);
//   } else if (indicatorValue > 1) {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage100;
//     emoji = String.fromCharCode(0x1F973);
//   } else if (indicatorValue > 0.75) {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage75;
//     emoji = String.fromCharCode(0x231B);
//   } else if (indicatorValue > 0.5) {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage50;
//     emoji = String.fromCharCode(0x1F917);
//   } else if (indicatorValue > 0.1) {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage10;
//     emoji = String.fromCharCode(0x1F971);
//   } else {
//     motivationMessage =
//         AppLocalizations.of(context)!.homeViewMotivationMessage0;
//     emoji = String.fromCharCode(0x1F971);
//   }

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           getTimeInformationBox(context, trackedHours,
//               AppLocalizations.of(context)!.homeViewHoursTracked),
//           SizedBox(width: 25),
//           (remainingHours.isNegative)
//               ? getTimeInformationBox(context, remainingHours.abs(),
//                   AppLocalizations.of(context)!.homeViewOvertime)
//               : getTimeInformationBox(context, remainingHours,
//                   AppLocalizations.of(context)!.homeViewRemainingHours),
//         ],
//       ),
//       SizedBox(height: 20),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             AppLocalizations.of(context)!.homeViewWorkProgress,
//             style: Theme.of(context).textTheme.headline3,
//           ),
//           Text(
//             NumberFormat.decimalPercentPattern(decimalDigits: 2)
//                 .format(indicatorValue),
//             style: Theme.of(context).textTheme.bodyText1,
//           ),
//         ],
//       ),
//       SizedBox(height: 10),
//       Stack(
//         children: [
//           Container(
//             height: 20,
//             width: width,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           Container(
//             constraints: BoxConstraints(
//               minWidth: 0,
//               maxWidth: width,
//             ),
//             height: 20,
//             width: width * (trackedHours / requiredHoursPerWeek),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade300,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 8,
//                   color: AppThemes.blue,
//                 )
//               ],
//               gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.topRight,
//                 colors: [
//                   AppThemes.neonBlue,
//                   AppThemes.primaryColor,
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 8),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: RichText(
//               overflow: TextOverflow.clip,
//               text: TextSpan(
//                 style: Theme.of(context).textTheme.headline6,
//                 children: [
//                   TextSpan(
//                     text: AppLocalizations.of(context)!
//                         .homeViewMoneyInformationPart1,
//                   ),
//                   TextSpan(
//                     text: previousEarnings,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextSpan(
//                     text: AppLocalizations.of(context)!
//                         .homeViewMoneyInformationPart2,
//                   ),
//                   TextSpan(text: motivationMessage),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               emoji,
//               style: TextStyle(
//                 fontSize: 40,
//                 color: Colors.black,
//               ),
//             ),
//           )
//         ],
//       ),
//     ],
//   );
// }
