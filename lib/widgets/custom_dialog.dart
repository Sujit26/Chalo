import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, description;
  final Widget icon;
  final buttons;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttons,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      content: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        icon,
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 16.0),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 16.0),
        Align(alignment: Alignment.bottomCenter, child: buttons),
      ],
    );
  }
}
