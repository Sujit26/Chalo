import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/config/keys.dart';
import 'dart:math' as math;

import 'package:shared_transport/widgets/custom_dialog.dart';

class BookingCard extends StatefulWidget {
  final ride;

  BookingCard({Key key, @required this.ride}) : super(key: key);
  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  int bookSeats = 1;
  var _isSaving = false;
  RideModel drive;

  @override
  void initState() {
    super.initState();
    drive = widget.ride['ride'];
  }

  _makePostRequest(data) async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var sendData = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'data': data,
    };

    final response = await post(
      Keys.serverURL + 'ride/request',
      headers: {"Content-type": "application/json"},
      body: jsonEncode(sendData),
    );
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
              border: Border.all(width: 2, color: Theme.of(context).accentColor),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done,
              size: 40,
              color: Theme.of(context).accentColor,
            ),
          ),
          title: 'Awesome',
          description:
              'Thank you choosing us.\n\nYou will be provided with drivers contact details once your request get approved.',
          buttons: FlatButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pop(context);
              // Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
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
          title: 'Error',
          description:
              'Seems like your request got into a conflict please retry again.',
          buttons: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _makePostRequest(data);
                },
                child: Text(
                  'Retry',
                  style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(drive.driveDate.split('/')[2]),
      int.parse(drive.driveDate.split('/')[1]),
      int.parse(drive.driveDate.split('/')[0]),
    ).weekday;
    var days = [
      'Monday',
      'Tuesday',
      'Wednusday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dNum - 1];
  }

  String getMonthOfYear(date) {
    int mNum = DateTime.utc(
      int.parse(drive.driveDate.split('/')[2]),
      int.parse(drive.driveDate.split('/')[1]),
      int.parse(drive.driveDate.split('/')[0]),
    ).month;
    var months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[mNum - 1];
  }

  Widget _starFilling(double fill) {
    return fill >= 1.0
        ? Icon(
            Icons.star,
            color: Theme.of(context).accentColor,
            size: 15,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: Theme.of(context).accentColor,
                size: 15,
              )
            : Icon(
                Icons.star_border,
                color: Theme.of(context).accentColor,
                size: 15,
              );
  }

  showCarPic() {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.fill,
        image: NetworkImage(drive.vehicle.pic),
      )),
    );
  }

  showSeats() {
    List<Widget> seats = List();
    for (var i = 0; i < drive.vehicle.seats - drive.slots; i++)
      seats.add(Icon(Icons.person, color: Theme.of(context).accentColor, size: 18));
    for (var i = 0; i < drive.slots; i++)
      seats.add(Icon(Icons.person_outline, color: Theme.of(context).accentColor, size: 18));

    return Row(
      children: seats,
    );
  }

  Widget build(BuildContext context) {
    Widget _carName = Center(
      child: Column(
        children: <Widget>[
          Text(
            '${drive.vehicle.name} ${drive.vehicle.modelName}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('${drive.slots} Seats'),
        ],
      ),
    );

    Widget _driverInfo = Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(drive.driver.pic),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    drive.driver.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 15,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  _starFilling(drive.driver.rating),
                  _starFilling(drive.driver.rating - 1),
                  _starFilling(drive.driver.rating - 2),
                  _starFilling(drive.driver.rating - 3),
                  _starFilling(drive.driver.rating - 4),
                ],
              ),
            ],
          ),
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(width: .8, color: Theme.of(context).accentColor),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${drive.driver.nod} Rides',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
        )
      ],
    );

    Widget _carInfo = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                drive.vehicle.number,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      drive.vehicle.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      ' ${drive.vehicle.modelName}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              showSeats(),
            ],
          ),
        ),
        Expanded(
          child: showCarPic(),
        ),
      ],
    );

    Widget _routeInfo = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pickup',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drop',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'End',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fiber_manual_record,
              color: Theme.of(context).accentColor.withOpacity(.3),
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: Theme.of(context).accentColor.withOpacity(.3),
                size: 15,
              ),
            ),
            Icon(
              Icons.fiber_manual_record,
              color: Theme.of(context).accentColor,
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: Theme.of(context).accentColor.withAlpha(150),
                size: 15,
              ),
            ),
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: Theme.of(context).primaryColor.withOpacity(.3),
                size: 15,
              ),
            ),
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor.withOpacity(.5),
              size: 15,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(drive.fromTime.split(':')[0]),
                      minute: int.parse(drive.fromTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(drive.fromTime.split(':')[0]) + 1,
                      minute: int.parse(drive.fromTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(drive.toTime.split(':')[0]) - 1,
                      minute: int.parse(drive.toTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(drive.toTime.split(':')[0]),
                      minute: int.parse(drive.toTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              children: <Widget>[
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${drive.from.name.split(',')[0]},${drive.from.name.split(',')[1]}',
                  ),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text('Rider\'s from Location'),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rider\'s To Loaction',
                  ),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                      '${drive.to.name.split(',')[0]},${drive.to.name.split(',')[1]}'),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget _seats = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor.withAlpha(150)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MaterialButton(
            onPressed: () {
              setState(() {
                if (bookSeats < drive.slots)
                  bookSeats++;
                else {
                  final scaffold = Scaffold.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: const Text(
                        'Maximum seats selected.',
                      ),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }
              });
            },
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            child: Icon(
              Icons.add,
            ),
            shape: CircleBorder(),
          ),
          Text(
            '$bookSeats Seats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MaterialButton(
            onPressed: () {
              setState(() {
                if (bookSeats > 1)
                  bookSeats--;
                else {
                  final scaffold = Scaffold.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: const Text(
                        'Minmum seats selected.',
                      ),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }
              });
            },
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            child: Icon(
              Icons.remove,
            ),
            shape: CircleBorder(),
          ),
        ],
      ),
    );

    Widget _submitButton = Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            color: Theme.of(context).accentColor,
            onPressed: () {
              if (_isSaving) return;
              setState(() {
                _isSaving = true;
              });
              var data = {
                'rider': widget.ride['rider'],
                'slots': bookSeats,
                'dId': widget.ride['ride'].dId,
              };
              _makePostRequest(data);
            },
            child: _isSaving
                ? SizedBox(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    height: 35.0,
                    width: 35.0,
                  )
                : Text(
                    'CONFIRM REQUEST',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(12),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 560,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          color: Colors.white,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                _carName,
                Spacer(),
                _driverInfo,
                Divider(),
                Spacer(),
                _carInfo,
                Divider(),
                Spacer(),
                _routeInfo,
                Divider(),
                Spacer(),
                _seats,
                Spacer(),
                _submitButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
