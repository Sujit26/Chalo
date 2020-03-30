import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class LoginPage extends StatefulWidget {
  final String name = 'Rider';
  final Color color = mainColor;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        color: mainColor,
        child: Padding(
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
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: InkWell(
                      onTap: () {
                        print('Facebook Clicked');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: fbColor,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(40.0))),
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
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: InkWell(
                      onTap: () {
                        print('Google clicked');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: gColor,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(40.0))),
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
