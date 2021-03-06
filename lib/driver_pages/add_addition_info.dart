import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/utils/localizations.dart';
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

    final response = await post(Keys.serverURL + 'driver/add',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
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
              border:
                  Border.all(width: 2, color: Theme.of(context).accentColor),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done,
              size: 40,
              color: Theme.of(context).accentColor,
            ),
          ),
          title: AppLocalizations.of(context).localisedText['saved'],
          description:
              AppLocalizations.of(context).localisedText['drive_saved_message'],
          buttons: FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'clear');
            },
            child: Text(
              AppLocalizations.of(context).localisedText['ok'],
              style:
                  TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
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
              color: Theme.of(context).accentColor,
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
              AppLocalizations.of(context).localisedText['ok'],
              style:
                  TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
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
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
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
                    AppLocalizations.of(context).localisedText['your_trips'],
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
                          AppLocalizations.of(context)
                              .localisedText['distance'],
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
                          AppLocalizations.of(context)
                              .localisedText['duration'],
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
                  AppLocalizations.of(context).localisedText['additional'],
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
                    AppLocalizations.of(context).localisedText['distance'] +
                        '(km)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  !_isDistance
                      ? FlatButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          child: Text(AppLocalizations.of(context)
                              .localisedText['add']),
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
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _n -= _n > 0 ? 5 : 0;
                                  if (_n == 0) _isDistance = false;
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
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _n += 5;
                                });
                              },
                            ),
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
                    AppLocalizations.of(context).localisedText['duration'] +
                        '(mins)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  !_isDuration
                      ? FlatButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          child: Text(AppLocalizations.of(context)
                              .localisedText['add']),
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
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _n -= _n > 0 ? 15 : 0;
                                  if (_n == 0) _isDuration = false;
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
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _n += 15;
                                });
                              },
                            ),
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
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: _isSaving
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(AppLocalizations.of(context)
                              .localisedText['save']),
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
              child: Text(AppLocalizations.of(context)
                  .localisedText['additional_info_message']),
            ),
          ],
        ),
      ),
    );
  }
}
