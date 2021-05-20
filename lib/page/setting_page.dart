import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:time24/app.dart';
import 'package:time24/constrant/profile_settings.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:time24/page/set_hours_per_week.dart';
import 'package:time24/page/set_hourly_wages.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  JsonFile? settingFile;

  num requiredHoursPerWeek = 0;
  String currency = "EUR";
  num loanPerHour = 0;
  bool receivesPaidOvertime = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  _loadPrefs() async {
    settingFile = new JsonFile("settings");
    ProfileSettings settings =
        ProfileSettings.fromJson(await settingFile!.getContentAsMap);

    setState(() {
      requiredHoursPerWeek = settings.requiredHoursPerWeek;
      currency = settings.currency;
      loanPerHour = settings.loanPerHour;
      receivesPaidOvertime = settings.receivesPaidOvertime;
    });
  }

  /// Saves the file
  void save() async {
    ProfileSettings settings =
        ProfileSettings.fromJson(await settingFile!.getContentAsMap);

    settings.requiredHoursPerWeek = requiredHoursPerWeek;
    settings.currency = currency;
    settings.loanPerHour = loanPerHour;
    settings.receivesPaidOvertime = receivesPaidOvertime;

    settingFile!.writeAll(settings.toJson());
  }

  @override
  void dispose() {
    save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(left: MIN_PADDING, right: MIN_PADDING),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.settingsViewPageTitle,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                  letterSpacing: -2.5,
                ),
              ),
              SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.settingsViewWorkInformation,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .settingsViewRequiredHoursPerWeek,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        sprintf(
                          AppLocalizations.of(context)!.settingsViewHoursSet,
                          [requiredHoursPerWeek],
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded),
                    onPressed: () async {
                      String value = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetHoursPerWeekPage(),
                        ),
                      );

                      if (value.isNotEmpty) {
                        setState(() {
                          requiredHoursPerWeek = num.parse(value);
                        });
                      }
                    },
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       AppLocalizations.of(context)!.settingsCurrency,
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         showCupertinoModalPopup(
              //           context: context,
              //           builder: (context) => Container(
              //             height: 500,
              //             color: Color.fromARGB(255, 255, 255, 255),
              //             child: Column(
              //               children: [
              //                 Container(
              //                   height: 400,
              //                   child: CupertinoPicker(
              //                     itemExtent: 32.0,
              //                     onSelectedItemChanged: (value) {
              //                       print(value);
              //                     },
              //                     children: [
              //                       Text("EUR"), // ToDo: but how?
              //                     ],
              //                   ),
              //                 ),
              //                 CupertinoButton(
              //                   child: Text("Ok"),
              //                   onPressed: () => Navigator.of(context).pop(),
              //                 )
              //               ],
              //             ),
              //           ),
              //         );
              //       },
              //       child: Text(currency),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.settingsViewHourlyWages,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                                locale: Platform.localeName, decimalDigits: 2)
                            .format(loanPerHour),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded),
                    onPressed: () async {
                      String value = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetHourlyWages(),
                        ),
                      );

                      if (value.isNotEmpty) {
                        setState(() {
                          loanPerHour = num.parse(value);
                        });
                      }
                    },
                  ),
                ],
              ),
              // Container(
              //   child: MergeSemantics(
              //     child: ListTile(
              //       contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              //       title: Text(
              //         "Paid Overtime",
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       trailing: CupertinoSwitch(
              //         value: receivesPaidOvertime,
              //         onChanged: (value) {
              //           setState(() {
              //             receivesPaidOvertime = value;
              //           });
              //         },
              //       ),
              //       onTap: () {
              //         setState(() {
              //           receivesPaidOvertime = !receivesPaidOvertime;
              //         });
              //       },
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
