import 'package:flutter/material.dart';
import 'package:shared_transport/login/login_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class PoliciesPage extends StatefulWidget {
  final String name = 'Policies';
  final Color color = mainColor;

  @override
  _PoliciesPageState createState() =>
      _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      elevation: 0,
      title: Text(
        widget.name,
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
      centerTitle: true,
      backgroundColor: mainColor,
    );
    
    Widget createBody() {
      return Container(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            color: bgColor,
            child: Text('data'),
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
