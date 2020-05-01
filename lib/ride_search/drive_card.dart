import 'package:flutter/material.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/new_ride.dart';
import 'dart:math' as math;

class DriveCard extends StatelessWidget {
  final ride;

  DriveCard({Key key, @required this.ride}) : super(key: key);

  void _navigateToConverter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingPage(ride: ride)),
    );
  }

  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(ride['ride'].driveDate.split('/')[2]),
      int.parse(ride['ride'].driveDate.split('/')[1]),
      int.parse(ride['ride'].driveDate.split('/')[0]),
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
      int.parse(ride['ride'].driveDate.split('/')[2]),
      int.parse(ride['ride'].driveDate.split('/')[1]),
      int.parse(ride['ride'].driveDate.split('/')[0]),
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
            color: buttonColor,
            size: 15,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: buttonColor,
                size: 15,
              )
            : Icon(
                Icons.star_border,
                color: buttonColor,
                size: 15,
              );
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Material(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 250,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              color: Colors.white,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  ride['ride'].driveDate.split('/')[0],
                                  style: TextStyle(fontSize: 25),
                                ),
                                Text(ride['ride'].driveDate.split('/')[0] == '01'
                                    ? 'st'
                                    : ride['ride'].driveDate.split('/')[0] == '02'
                                        ? 'nd'
                                        : ride['ride'].driveDate.split('/')[0] == '03'
                                            ? 'rd'
                                            : 'th'),
                              ],
                            ),
                            Text(
                                '${getMonthOfYear(ride['ride'].driveDate)}, ${getDayOfWeek(ride['ride'].driveDate)}'),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${ride['ride'].vehicle.name} ${ride['ride'].vehicle.modelName}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text('${ride['ride'].slots} Seats | ${ride['ride'].vehicle.type}'),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.fiber_manual_record,
                              color: buttonColor,
                              size: 15,
                            ),
                            Transform.rotate(
                              angle: 90 * math.pi / 180,
                              child: Icon(
                                Icons.linear_scale,
                                color: buttonColor.withAlpha(150),
                                size: 15,
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: mainColor,
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
                                      hour: int.parse(
                                          ride['ride'].fromTime.split(':')[0]),
                                      minute: int.parse(
                                          ride['ride'].fromTime.split(':')[1]),
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
                                      hour:
                                          int.parse(ride['ride'].toTime.split(':')[0]),
                                      minute:
                                          int.parse(ride['ride'].toTime.split(':')[1]),
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${ride['ride'].from.name.split(',')[0]},${ride['ride'].from.name.split(',')[1]}',
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 30.0,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '${ride['ride'].to.name.split(',')[0]},${ride['ride'].to.name.split(',')[1]}'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(ride['ride'].driver.pic),
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
                                    ride['ride'].driver.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
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
                                  _starFilling(ride['ride'].driver.rating),
                                  _starFilling(ride['ride'].driver.rating - 1),
                                  _starFilling(ride['ride'].driver.rating - 2),
                                  _starFilling(ride['ride'].driver.rating - 3),
                                  _starFilling(ride['ride'].driver.rating - 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        OutlineButton(
                          child: Text('Request',
                              style: TextStyle(color: buttonColor)),
                          onPressed: () {
                            _navigateToConverter(context);
                          },
                          highlightedBorderColor: buttonColor,
                          borderSide: BorderSide(
                            color: buttonColor,
                            style: BorderStyle.solid,
                            width: 0.8,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            top: -20,
            child: CircleAvatar(
              backgroundColor: bgColor,
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }
}
