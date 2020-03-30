import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  @override
  Widget build(BuildContext context) {
    /// Navigates to the [RiderHome].
    void _navigateToConverter(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpPage()),
      );
    }

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
                    // errorText: _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.number,

                  // onChanged: _updateInputValue,
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
                    GestureDetector(
                      onTap: (){
                        _navigateToConverter(context);
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
