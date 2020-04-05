import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'phone_number.dart';

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
Color fbColor = hexToColor("#4267B2");
Color gColor = hexToColor("#de5246");
String serverURL = 'http://localhost:3002/';

class LoginPage extends StatefulWidget {
  final String name = 'Rider';
  final Color color = mainColor;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _makeGetRequest();
  }

  _makeGetRequest() async {
    final response = await get(serverURL);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['type'] == 'server' &&
          jsonData['info'] == 'Connection successful')
        setState(() {
          _isLoading = false;
        });
    }
  }

  _makePostRequest(data) async {
    final response = await post(serverURL,
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
      _navigateToConverter(context);
    }
  }

  /// Navigates to the [RiderHome].
  void _navigateToConverter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NumberPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        color: mainColor,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(children: <Widget>[
                  Positioned(
                      child: Align(
                    alignment: FractionalOffset.center,
                    child: Image.asset('assets/images/logo.png'),
                  )),
                  Positioned(
                      child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Wrap(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () {
                              var data = {
                                'type': 'login_method',
                                'info': 'facebook',
                              };
                              _makePostRequest(data);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: fbColor,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(40.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0.0, 28.0, 0.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.facebookF,
                                        size: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Continue with facebook',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () {
                              var data = {
                                'type': 'login_method',
                                'info': 'Google',
                              };
                              _makePostRequest(data);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: gColor,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(40.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0.0, 28.0, 0.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.google,
                                        size: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ]),
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
