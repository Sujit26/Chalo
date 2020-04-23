import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/driver_home.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/widgets/custom_dialog.dart';

class AddAdditionalInfo extends StatefulWidget {
  final drive;
  AddAdditionalInfo({@required this.drive});
  _AddAdditionalInfoState createState() => _AddAdditionalInfoState();
}

class _AddAdditionalInfoState extends State<AddAdditionalInfo> {
  var _n = 0;
  var _isDistance = false;
  var _isDuration = false;
  var _isSaving = false;

  _makePostRequest(drive) async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'drive': drive,
    };

    final response = await post(serverURL + 'driver/add',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        _isSaving = false;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          icon: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: buttonColor),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done,
              size: 40,
              color: buttonColor,
            ),
          ),
          title: 'Saved',
          description:
              'Thank you for driving with us.\n\nYou will be notified when someone request to ride with you.',
          buttons: FlatButton(
            onPressed: () {
              // find a better way
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => DriverHome()));
            },
            child: Text(
              'OK',
              style: TextStyle(color: buttonColor, fontSize: 20),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          icon: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: buttonColor,
            ),
          ),
          title: 'Invalid Request',
          description:
              'This incident will be reported.\nYou will be redireted to the login page.',
          buttons: FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()),
                ModalRoute.withName(''),
              );
            },
            child: Text(
              'OK',
              style: TextStyle(color: buttonColor, fontSize: 20),
            ),
          ),
        ),
      );

      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Your Trip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Distance',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Text(
                            '${(widget.drive['routeDetail']['distance']).toStringAsFixed(2)} km',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Text(
                            '${widget.drive['routeDetail']['duration'].toStringAsFixed(2)} HH',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Additional',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Distance(km)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  !_isDistance
                      ? FlatButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: buttonColor,
                          textColor: Colors.white,
                          child: Text('Add'),
                          onPressed: () {
                            setState(() {
                              _n = 5;
                              _isDistance = true;
                              _isDuration = false;
                            });
                          },
                        )
                      : Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _n += 5;
                                });
                              },
                            ),
                            Text(
                              _n.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _n > 0 ? _n -= 5 : _n;
                                  if (_n == 0) _isDistance = false;
                                });
                              },
                            )
                          ],
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Duration(mins)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  !_isDuration
                      ? FlatButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: buttonColor,
                          textColor: Colors.white,
                          child: Text('Add'),
                          onPressed: () {
                            setState(() {
                              _n = 15;
                              _isDistance = false;
                              _isDuration = true;
                            });
                          },
                        )
                      : Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _n += 15;
                                });
                              },
                            ),
                            Text(
                              _n.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _n > 0 ? _n -= 15 : _n;
                                  if (_n == 0) _isDuration = false;
                                });
                              },
                            )
                          ],
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      color: buttonColor,
                      textColor: Colors.white,
                      child: _isSaving
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                valueColor: 
                                AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Save'),
                      onPressed: _isSaving
                          ? () {}
                          : () {
                              setState(() {
                                _isSaving = true;
                              });
                              widget.drive['routeDetail']['distance'] +=
                                  _isDistance ? _n : 0;
                              widget.drive['routeDetail']['duration'] +=
                                  _isDuration ? _n / 60 : 0;
                              if (!_isDistance && !_isDuration)
                                widget.drive['routeDetail']['distance'] += 5;
                              print(widget.drive);
                              _makePostRequest(widget.drive);
                            },
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Text(
                  'The more distance / duration you add the more you rides you will get.\n By default 5kms will be added.'),
            ),
          ],
        ),
      ),
    );
  }
}
