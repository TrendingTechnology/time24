import 'package:flutter/material.dart';
import 'package:time24/page/home_page.dart';
import 'package:time24/page/setting_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The default minimum padding value for the left and right side.
const double MIN_PADDING = 20;

class Time24 extends StatefulWidget {
  Time24({Key? key}) : super(key: key);

  @override
  _Time24State createState() => _Time24State();
}

class _Time24State extends State<Time24> {
  int _index = 0;
  PageController? _bottomNavigationController;

  @override
  void initState() {
    super.initState();
    _bottomNavigationController = PageController();
  }

  @override
  void dispose() {
    _bottomNavigationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _bottomNavigationController,
        onPageChanged: _onPageChanged,
        children: [
          new HomePage(),
          new SettingPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _navigationTapped,
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)!.homeView,
          ),
          // ToDo: coming soon...
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.bar_chart_rounded),
          //   label: "Statistics",
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications_rounded),
            label: AppLocalizations.of(context)!.settingsView,
          ),
        ],
      ),
    );
  }

  void _navigationTapped(int index) {
    _bottomNavigationController!.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
    });
  }
}
