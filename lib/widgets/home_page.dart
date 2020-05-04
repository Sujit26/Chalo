import 'package:flutter/material.dart';
import 'package:shared_transport/history_pages/notification_page.dart';
import 'package:shared_transport/login/login_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class HomePage extends StatefulWidget {
  final String name = 'Home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            elevation: 2,
            titleSpacing: 0,
            backgroundColor: buttonColor,
            title: Text(
              widget.name,
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          body: Container(
            color: bgColor,
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }
}
