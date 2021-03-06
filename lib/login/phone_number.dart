import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_transport/config/keys.dart';
import 'otp_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class NumberPage extends StatefulWidget {
  final String name = 'Rider';
  final userData;

  NumberPage({
    Key key,
    @required this.userData,
  }) : super(key: key);

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
      'name': widget.userData['name'],
      'email': widget.userData['email'],
      'photoUrl': widget.userData['photoUrl'],
      'token': widget.userData['token'],
      'phone': phone,
    };
    final response = await post(Keys.serverURL + 'phone/',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200)
      _navigateToConverter(context, data);
    else
      _validError(true);
  }

  /// Navigates to the [RiderHome].
  void _navigateToConverter(BuildContext context, data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpPage(userData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        color: Theme.of(context).primaryColor,
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
                    fillColor: Theme.of(context).backgroundColor.withOpacity(0.5),
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
                            color: Theme.of(context).accentColor,
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
      backgroundColor: Theme.of(context).primaryColor,
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
