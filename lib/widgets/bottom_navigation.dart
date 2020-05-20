import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_transport/chat_facitility/main.dart';
import 'package:shared_transport/driver_pages/driver_home.dart';
import 'package:shared_transport/history_pages/my_trips.dart';
import 'package:shared_transport/profile.dart';
import 'package:shared_transport/rider_home.dart';
import 'package:shared_transport/utils/localizations.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTab = 0;
  Widget build(BuildContext context) {
    Widget child;
    switch (_currentTab) {
      case 0:
        child = MyTripsPage();
        break;
      case 1:
        child = DriverHome();
        break;
      case 2:
        child = SearchPage();
        break;
      case 3:
        child = MyChatPage();
        break;
      case 4:
        child = ProfilePage();
        break;
    }
    return Scaffold(
      body: SizedBox.expand(child: child),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBackgroundColor: Theme.of(context).accentColor,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: _currentTab,
        onSelectTab: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.home,
            label: AppLocalizations.of(context).localisedText['my_trips'],
          ),
          FFNavigationBarItem(
            iconData: Icons.directions_car,
            label: AppLocalizations.of(context).localisedText['drive'],
          ),
          FFNavigationBarItem(
            iconData: Icons.search,
            label: AppLocalizations.of(context).localisedText['search'],
          ),
          FFNavigationBarItem(
            iconData: Icons.chat,
            label: AppLocalizations.of(context).localisedText['chat'],
          ),
          FFNavigationBarItem(
            iconData: Icons.person,
            label: AppLocalizations.of(context).localisedText['profile'],
          ),
        ],
      ),
    );
  }
}
