import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/history_pages/ride_request.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';

class NotificationPage extends StatefulWidget {
  final List<HistoryModel> notifications;
  final name = 'Notifications';

  NotificationPage({Key key, @required this.notifications}) : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var _refreshRequired = true;
  ListView notificationListView;

  _makePostRequest(res, HistoryModel ride, int upSlots, User remUsr) async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'data': res,
    };
    final response = await post(
      serverURL + 'driver/response',
      headers: {"Content-type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      if (res['status'] == 'Accepted') {
        List<User> tempReq = List.from(ride.requestFromRiders);
        var ava = ride.rideInfo.slots - upSlots;
        ride.requestFromRiders.forEach((req) {
          if (req.rideId == res['rideId']) ride.acceptedRiders.add(req);
          if (req.slots > ava || req.rideId == res['rideId'])
            tempReq.remove(req);
        });
        setState(() {
          ride.requestFromRiders = List.from(tempReq);
          ride.rideInfo.slots = ava;
          _refreshRequired = true;
        });
      } else {
        setState(() {
          ride.requestFromRiders.remove(remUsr);
          _refreshRequired = true;
        });
      }
    } else {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  showSeats(int slots) {
    List<Widget> seats = List();
    for (var i = 0; i < slots; i++)
      seats.add(Icon(Icons.person, color: buttonColor, size: 12));

    return Row(
      children: seats,
    );
  }

  Widget _notification(User req, HistoryModel ride) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Material(
        color: Colors.white,
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (build) => RideRequest(
                  ride: ride,
                  reqUsrInfo: req,
                ),
              ),
            ).then((onValue) {
              if (onValue == 'Accept') {
                var res = {
                  'status': 'Accepted',
                  'd_id': ride.rideInfo.dId,
                  'rideId': req.rideId,
                };
                _makePostRequest(res, ride, req.slots, req);
              }
              if (onValue == 'Reject') {
                var res = {
                  'status': 'Rejected',
                  'd_id': ride.rideInfo.dId,
                  'rideId': req.rideId,
                };
                _makePostRequest(res, ride, req.slots, req);
              }
            });
          },
          child: Column(
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: Material(
                  shape: CircleBorder(),
                  elevation: 5,
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: buttonColor, width: 2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(req.pic),
                      ),
                    ),
                  ),
                ),
                title: Text(req.name),
                subtitle: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 10,
                      left: 3.5,
                      child: Container(
                        width: 2,
                        height: 20,
                        color: buttonColor,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Material(
                              elevation: 3,
                              shape: CircleBorder(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: buttonColor),
                                ),
                                child: Icon(
                                  Icons.fiber_manual_record,
                                  size: 5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${req.from.name.split(',')[0]},${req.from.name.split(',')[1]}',
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Material(
                                elevation: 3,
                                shape: CircleBorder(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: buttonColor),
                                  ),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    size: 5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${req.to.name.split(',')[0]},${req.to.name.split(',')[1]}',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      req.rating.toString(),
                      style: TextStyle(
                        color: buttonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      Icons.star,
                      size: 22,
                      color: buttonColor,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        Icon(
                          Icons.calendar_today,
                          color: buttonColor,
                          size: 12,
                        ),
                        Text(
                          ' ${ride.rideInfo.driveDate}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        showSeats(req.slots),
                        Text(
                          ' Seats',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      'Accept',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      var res = {
                        'status': 'Accepted',
                        'd_id': ride.rideInfo.dId,
                        'rideId': req.rideId,
                      };
                      _makePostRequest(res, ride, req.slots, req);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      var res = {
                        'status': 'Rejected',
                        'd_id': ride.rideInfo.dId,
                        'rideId': req.rideId,
                      };
                      _makePostRequest(res, ride, req.slots, req);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _resultSorter(HistoryModel a, HistoryModel b) {
    var dateA = DateTime.utc(
      int.parse(a.rideInfo.driveDate.split('/')[2]),
      int.parse(a.rideInfo.driveDate.split('/')[1]),
      int.parse(a.rideInfo.driveDate.split('/')[0]),
    );
    var dateB = DateTime.utc(
      int.parse(b.rideInfo.driveDate.split('/')[2]),
      int.parse(b.rideInfo.driveDate.split('/')[1]),
      int.parse(b.rideInfo.driveDate.split('/')[0]),
    );
    return dateA.compareTo(dateB);
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 2,
      titleSpacing: 0,
      title: Text(
        widget.name,
        style: TextStyle(fontSize: 25.0),
      ),
      backgroundColor: buttonColor,
    );

    Widget createBody() {
      if (_refreshRequired) {
        List<Widget> list = [];
        widget.notifications.sort(_resultSorter);
        widget.notifications.forEach((notification) {
          notification.requestFromRiders.forEach((request) {
            list.add(_notification(
              request,
              notification,
            ));
          });
        });
        setState(() {
          notificationListView = ListView(
            padding: const EdgeInsets.symmetric(vertical: 15),
            children: list,
          );
          _refreshRequired = false;
        });
      }

      return notificationListView;
    }

    return Scaffold(
      appBar: appBar,
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: createBody(),
        ),
      ),
    );
  }
}
