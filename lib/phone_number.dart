import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_transport/login_page.dart';
import 'otp_page.dart';

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

Color mainColor = hexToColor("#708690");
Color buttonColor = hexToColor("#A65A7B");
Color bgColor = hexToColor("#F7FAFB");
Color borderColor = hexToColor("#EBEBEB");

class NumberPage extends StatefulWidget {
  final String name = 'Rider';
  final Color color = mainColor;

  @override
  _NumberPageState createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  String phone = "";
  var _showValidationError = false;

  _updatePhone(String s) {
    _validError(false);
    setState(() {
      phone = s;
    });
  }

  _validError(var b) {
    setState(() {
      _showValidationError = b;
    });
  }

  _makePostRequest() async {
    var data = {
      'phone': phone,
    };
    final response = await post(serverURL + 'phone/',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200)
      _navigateToConverter(context);
    else
      _validError(true);
  }

  /// Navigates to the [RiderHome].
  void _navigateToConverter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpPage(phone: phone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        color: mainColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: <Widget>[
              Text(
                'Enter your mobile number',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    filled: true,
                    fillColor: borderColor.withOpacity(0.5),
                    labelText: 'Phone',
                    errorText:
                        _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _updatePhone,
                ),
              ),
              Positioned(
                  child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                          'By continuing you may recive an SMS for verification. Message and data rates may apply.'),
                    ),
                    InkWell(
                      onTap: phone.length == 10
                          ? () {
                              _makePostRequest();
                            }
                          : () {
                              _validError(true);
                            },
                      child: Container(
                        padding: const EdgeInsets.all(13.0),
                        decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(40.0))),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          size: 35.0,
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    }

    final appBar = AppBar(
      elevation: 0.0,
      backgroundColor: widget.color,
    );

    return Scaffold(
      appBar: appBar,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }
}
