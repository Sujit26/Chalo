import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_transport/login_page.dart';
import 'package:shared_transport/profile_verification.dart';

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

class ProfilePage extends StatefulWidget {
  final String name = 'Profile';
  final Color color = mainColor;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  get _profilePic {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'))),
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => {exit(0)},
                ),
              ],
            ),
          );
        });
  }

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
      actions: <Widget>[
        GestureDetector(
            onTap: () {
              _settingModalBottomSheet(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:20.0),
              child: Icon(
                Icons.more_horiz,
                size: 26.0,
              ),
            )),
      ],
      centerTitle: true,
      backgroundColor: mainColor,
    );

    Widget profileBody = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: <Widget>[
                _profilePic,
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.person),
                        border: InputBorder.none,
                        labelText: 'Name',
                        // errorText: _showValidationError ? 'Invalid number entered' : null,
                      ),
                      keyboardType: TextInputType.text,

                      // onChanged: _updateInputValue,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        labelText: 'Email',
                        // errorText: _showValidationError ? 'Invalid number entered' : null,
                      ),
                      keyboardType: TextInputType.text,

                      // onChanged: _updateInputValue,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: DropdownButton<String>(
                        items: <String>['Male', 'Female', 'Other']
                            .map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        hint: Text('Gender'),
                        onChanged: (_) {},
                        isExpanded: true,
                      )),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.phone),
                        border: InputBorder.none,
                        labelText: 'Phone',
                        // errorText: _showValidationError ? 'Invalid number entered' : null,
                      ),
                      keyboardType: TextInputType.text,

                      // onChanged: _updateInputValue,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: InkWell(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileVerificationPage()),
                        )
                      },
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.verified_user),
                          border: InputBorder.none,
                          labelText: 'Profile Verification',
                          enabled: false,
                          // errorText: _showValidationError ? 'Invalid number entered' : null,
                        ),
                        keyboardType: TextInputType.text,

                        // onChanged: _updateInputValue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget createBody() {
      return Container(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            color: bgColor,
            child: profileBody,
          ),
          bottomSheet: Container(
            color: buttonColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
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
