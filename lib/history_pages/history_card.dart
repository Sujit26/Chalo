import 'package:flutter/material.dart';
import 'package:shared_transport/history_pages/drive_details.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/history_pages/my_trips.dart';
import 'package:shared_transport/history_pages/profile_card.dart';
import 'dart:math' as math;

class HistoryCard extends StatelessWidget {
  final HistoryModel history;

  HistoryCard({Key key, @required this.history}) : super(key: key);

  void _showRidersInfo(BuildContext context, List<User> riders, int index) {
    List<Widget> _tabs = List<Widget>.generate(
      riders.length,
      (i) => Text('.', style: TextStyle(fontSize: 70)),
    );
    List<Widget> _tabViews = List<Widget>.generate(
      riders.length,
      (i) => Center(child: ProfileCard(user: riders[i])),
    );

    showDialog(
      context: context,
      builder: (b) => DefaultTabController(
        length: riders.length,
        initialIndex: index,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onVerticalDragUpdate: (details) {
              Navigator.pop(context);
            },
            child: Column(
              children: <Widget>[
                Expanded(child: TabBarView(children: _tabViews)),
                Text(
                  'Swipe Up/Down To Close',
                  style: TextStyle(color: Colors.white),
                ),
                IgnorePointer(
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black38,
                    indicator: CircleTabIndicator(
                      color: Colors.transparent,
                      radius: 0,
                    ),
                    tabs: _tabs,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserInfo(BuildContext context, User _user) {
    showDialog(
      context: context,
      builder: (b) => Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            Navigator.pop(context);
          },
          child: Column(
            children: <Widget>[
              Expanded(child: Center(child: ProfileCard(user: _user))),
              Text(
                'Swipe Up/Down To Close',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(date.split('/')[2]),
      int.parse(date.split('/')[1]),
      int.parse(date.split('/')[0]),
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
      int.parse(date.split('/')[2]),
      int.parse(date.split('/')[1]),
      int.parse(date.split('/')[0]),
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

  Widget _starFilling(double fill, context) {
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

  List<Widget> _ridersProfilePics(context) {
    var posLeft = -30.0;
    List<Widget> pics =
        List<Widget>.generate(history.acceptedRiders.length, (i) {
      posLeft += 30;
      return Positioned(
        left: posLeft,
        child: InkWell(
          onTap: () {
            _showRidersInfo(
              context,
              history.acceptedRiders,
              i,
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(history.acceptedRiders[i].pic),
              ),
            ),
          ),
        ),
      );
    });
    return pics;
  }

  _vehicleInfo(slots) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            '${history.rideInfo.vehicle.name} ${history.rideInfo.vehicle.modelName}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
          ),
          Text('$slots Seats | ${history.rideInfo.vehicle.type}'),
        ],
      ),
    );
  }

  _columnTime(context, fromTime, toTime) {
    return Padding(
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
                    fromTime.split(':')[0],
                  ),
                  minute: int.parse(
                    fromTime.split(':')[1],
                  ),
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
                  hour: int.parse(
                    toTime.split(':')[0],
                  ),
                  minute: int.parse(
                    toTime.split(':')[1],
                  ),
                ).format(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _columnLocation(context, fromLoc, toLoc) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          children: <Widget>[
            Container(
              height: 30.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${fromLoc.name.split(',')[0]},${fromLoc.name.split(',')[1]}',
                ),
              ),
            ),
            Container(
              height: 30.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '${toLoc.name.split(',')[0]},${toLoc.name.split(',')[1]}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Material(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 250,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                                    history.rideInfo.driveDate.split('/')[0],
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(history.rideInfo.driveDate
                                              .split('/')[0] ==
                                          '01'
                                      ? 'st'
                                      : history.rideInfo.driveDate
                                                  .split('/')[0] ==
                                              '02'
                                          ? 'nd'
                                          : history.rideInfo.driveDate
                                                      .split('/')[0] ==
                                                  '03'
                                              ? 'rd'
                                              : 'th'),
                                ],
                              ),
                              Text(
                                  '${getMonthOfYear(history.rideInfo.driveDate)}, ${getDayOfWeek(history.rideInfo.driveDate)}'),
                            ],
                          ),
                          history.action == 'Driving'
                              ? _vehicleInfo(history.rideInfo.total)
                              : _vehicleInfo(history.rideSlots),
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
                                color: Theme.of(context).accentColor,
                                size: 15,
                              ),
                              Transform.rotate(
                                angle: 90 * math.pi / 180,
                                child: Icon(
                                  Icons.linear_scale,
                                  color: Theme.of(context)
                                      .accentColor
                                      .withAlpha(150),
                                  size: 15,
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 15,
                              ),
                            ],
                          ),
                          history.action == 'Driving'
                              ? _columnTime(context, history.rideInfo.fromTime,
                                  history.rideInfo.toTime)
                              : _columnTime(context, history.rideFromTime,
                                  history.rideToTime),
                          history.action == 'Driving'
                              ? _columnLocation(context, history.rideInfo.from,
                                  history.rideInfo.to)
                              : _columnLocation(
                                  context, history.rideFrom, history.rideTo),
                        ],
                      ),
                      Spacer(),
                      Divider(),
                      Row(
                        children: <Widget>[
                          history.action == 'Driving'
                              ? Container(
                                  width: (40.0 +
                                      (history.acceptedRiders.length - 1) * 30),
                                  height: 40,
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: _ridersProfilePics(context),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    _showUserInfo(
                                      context,
                                      history.rideInfo.driver,
                                    );
                                  },
                                  child: Wrap(
                                    children: <Widget>[
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                              history.rideInfo.driver.pic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  history.rideInfo.driver.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 4.0,
                                                  ),
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
                                                _starFilling(
                                                  history
                                                      .rideInfo.driver.rating,
                                                  context,
                                                ),
                                                _starFilling(
                                                  history.rideInfo.driver
                                                          .rating -
                                                      1,
                                                  context,
                                                ),
                                                _starFilling(
                                                  history.rideInfo.driver
                                                          .rating -
                                                      2,
                                                  context,
                                                ),
                                                _starFilling(
                                                  history.rideInfo.driver
                                                          .rating -
                                                      3,
                                                  context,
                                                ),
                                                _starFilling(
                                                  history.rideInfo.driver
                                                          .rating -
                                                      4,
                                                  context,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          Spacer(),
                          OutlineButton(
                            child: Text(
                              history.action == 'Riding'
                                  ? history.rideStatus
                                  : 'Start Trip',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DriveDetails(ride: history)),
                              );
                            },
                            highlightedBorderColor:
                                Theme.of(context).accentColor,
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
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
          ),
          Positioned(
            left: 50,
            right: 50,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Text(
                history.action == 'Driving' ? 'D' : 'R',
                style: TextStyle(
                    color: Theme.of(context).accentColor, fontSize: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
