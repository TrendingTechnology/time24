import 'package:flutter/material.dart';
import 'package:time24/constrant/app_themes.dart';
import 'package:time24/constrant/profile_settings.dart';
import 'package:time24/constrant/json_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SetHourlyWages extends StatefulWidget {
  SetHourlyWages({Key? key}) : super(key: key);

  @override
  _SetHourlyWagesState createState() => _SetHourlyWagesState();
}

class _SetHourlyWagesState extends State<SetHourlyWages> {
  TextEditingController weeklyWorkTimeController = new TextEditingController();
  JsonFile? settingsFile;
  num loanPerHour = 0;

  @override
  void initState() {
    _loadPrefs();
    super.initState();
  }

  _loadPrefs() async {
    settingsFile = new JsonFile("settings");
    ProfileSettings settings =
        ProfileSettings.fromJson(await settingsFile!.getContentAsMap);

    setState(() {
      loanPerHour = settings.loanPerHour;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Row(
                children: [
                  Icon(Icons.chevron_left_rounded, size: 30),
                  Text(
                    AppLocalizations.of(context)!.basicLeavePageText,
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
              onTap: () =>
                  Navigator.pop(context, weeklyWorkTimeController.text),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hourlyWagesTitle,
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)!.hourlyWagesDescription,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    child: TextField(
                      controller: weeklyWorkTimeController,
                      textAlign: TextAlign.center,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      cursorColor: AppThemes.primaryColor,
                      decoration: InputDecoration(
                        hintText: loanPerHour.toString(),
                        focusedBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(
                            color: AppThemes.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
