import 'package:flutter/material.dart';
import 'package:time24/app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(App());
}

const List<Locale> supportedLocales = [
  const Locale('en', ''),
  const Locale('de', ''),
];

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _defaultLanguage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time24',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (_defaultLanguage != null) {
          Intl.defaultLocale = _defaultLanguage!.toLanguageTag();
          return _defaultLanguage;
        }
        if (locale == null) {
          Intl.defaultLocale = supportedLocales.first.toLanguageTag();
          return supportedLocales.first;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            Intl.defaultLocale = supportedLocale.toLanguageTag();
            return supportedLocale;
          }
        }
        Intl.defaultLocale = supportedLocales.first.toLanguageTag();
        return supportedLocales.first;
      },
      home: Time24(),
    );
  }
}
