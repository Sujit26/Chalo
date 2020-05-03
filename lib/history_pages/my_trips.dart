import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/history_pages/history_card.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/history_pages/trip_summary_driver.dart';
import 'package:shared_transport/history_pages/trip_summary_rider.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/empty_state.dart';
import 'package:shared_transport/widgets/loacation.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class MyTripsPage extends StatefulWidget {
  final String name = 'My Trips';
  final Color color = mainColor;

  @override
  _MyTripsPageState createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  // to store all the histories
  List<HistoryModel> completedList;
  List<HistoryModel> cancelledList;
  List<HistoryModel> upcomingList;
  // history Views
  ListView upcomingResultListView;
  ListView completedResultListView;
  // should rebuild the view
  var _upcomingRefreshRequired = true;
  var _completedRefreshRequired = false;
  var _cancelledRefreshRequired = true;
  // Filters
  var _upcomingType = ['Riding', 'Driving'];

  @override
  void initState() {
    super.initState();
    _makeGetRequest('upcoming');
    _tabController = new TabController(initialIndex: 1, length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && completedList == null) {
        _makeGetRequest('completed');
      }
      if (_tabController.index == 2 && cancelledList == null) {
        cancelledList = [];
        _makeGetRequest('cancelled');
      }
    });
  }

  _makeGetRequest(trip) async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    final response = await get(serverURL + 'profile/history', headers: {
      'token': prefs.getString('token'),
      'email': prefs.getString('email'),
      'status': prefs.getString('approveStatus'),
      'trip': trip
    });
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        if (trip == 'upcoming') {
          upcomingList = jsonData['rides'].map<HistoryModel>((data) {
            return data['action'] == 'Riding'
                ? HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: Location(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: Location(
                        data['rideInfo']['to']['name'],
                        data['rideInfo']['to']['lat'],
                        data['rideInfo']['to']['lon'],
                      ),
                      driveDate: data['rideInfo']['driveDate'],
                      fromTime: data['rideInfo']['fromTime'],
                      toTime: data['rideInfo']['toTime'],
                      vehicle: Vehicle(
                        name: data['rideInfo']['vehicle']['name'],
                        modelName: data['rideInfo']['vehicle']['modelName'],
                        seats: data['rideInfo']['vehicle']['seats'],
                        number: data['rideInfo']['vehicle']['number'],
                        pic: data['rideInfo']['vehicle']['pic'],
                        type: data['rideInfo']['vehicle']['type'],
                        index: data['rideInfo']['vehicle']['index'],
                      ),
                      slots: data['rideInfo']['slots'],
                      dId: data['rideInfo']['dId'],
                      driver: User(
                        name: data['rideInfo']['driver']['name'],
                        email: data['rideInfo']['driver']['email'],
                        rating: data['rideInfo']['driver']['rating'],
                        pic: data['rideInfo']['driver']['pic'],
                        nod: data['rideInfo']['driver']['nod'],
                      ),
                    ),
                    rider: User(
                      name: 'Sidhant Jain',
                      email: 'sidhantjain456@gmail.com',
                      rating: 5.0,
                      pic:
                          'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
                      nod: 5,
                      phone: '0987654321',
                    ),
                    rideFrom: Location(
                      data['rideFrom']['name'],
                      data['rideFrom']['lat'],
                      data['rideFrom']['lon'],
                    ),
                    rideTo: Location(
                      data['rideTo']['name'],
                      data['rideTo']['lat'],
                      data['rideTo']['lon'],
                    ),
                    rideFromTime: "00:00",
                    rideToTime: "00:00",
                    rideSlots: data['rideSlots'],
                    rideStatus: data['rideStatus'],
                  )
                : HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: Location(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: Location(
                        data['rideInfo']['to']['name'],
                        data['rideInfo']['to']['lat'],
                        data['rideInfo']['to']['lon'],
                      ),
                      driveDate: data['rideInfo']['driveDate'],
                      fromTime: data['rideInfo']['fromTime'],
                      toTime: data['rideInfo']['toTime'],
                      vehicle: Vehicle(
                        name: data['rideInfo']['vehicle']['name'],
                        modelName: data['rideInfo']['vehicle']['modelName'],
                        seats: data['rideInfo']['vehicle']['seats'],
                        number: data['rideInfo']['vehicle']['number'],
                        pic: data['rideInfo']['vehicle']['pic'],
                        type: data['rideInfo']['vehicle']['type'],
                        index: data['rideInfo']['vehicle']['index'],
                      ),
                      slots: data['rideInfo']['slots'],
                      dId: data['rideInfo']['dId'],
                      driver: User(
                        name: data['rideInfo']['driver']['name'],
                        email: data['rideInfo']['driver']['email'],
                        rating: data['rideInfo']['driver']['rating'],
                        pic: data['rideInfo']['driver']['pic'],
                        nod: data['rideInfo']['driver']['nod'],
                      ),
                    ),
                    requestFromRiders: data['requestFromRiders']
                        .map<User>(
                          (rider) => User(
                            name: rider['name'],
                            email: rider['email'],
                            rating: rider['rating'] * 1.0,
                            pic: rider['pic'],
                          ),
                        )
                        .toList(),
                    acceptedRiders: data['acceptedRiders']
                        .map<User>(
                          (rider) => User(
                            name: rider['name'],
                            email: rider['email'],
                            rating: rider['rating'] * 1.0,
                            pic: rider['pic'],
                            phone: rider['phone'],
                          ),
                        )
                        .toList(),
                  );
          }).toList();
          _upcomingRefreshRequired = true;
        } else if (trip == 'completed') {
          completedList = jsonData['rides'].map<HistoryModel>((data) {
            return data['action'] == 'Riding'
                ? HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: Location(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: Location(
                        data['rideInfo']['to']['name'],
                        data['rideInfo']['to']['lat'],
                        data['rideInfo']['to']['lon'],
                      ),
                      driveDate: data['rideInfo']['driveDate'],
                      fromTime: data['rideInfo']['fromTime'],
                      toTime: data['rideInfo']['toTime'],
                      vehicle: Vehicle(
                        name: data['rideInfo']['vehicle']['name'],
                        modelName: data['rideInfo']['vehicle']['modelName'],
                        seats: data['rideInfo']['vehicle']['seats'],
                        number: data['rideInfo']['vehicle']['number'],
                        pic: data['rideInfo']['vehicle']['pic'],
                        type: data['rideInfo']['vehicle']['type'],
                        index: data['rideInfo']['vehicle']['index'],
                      ),
                      slots: data['rideInfo']['slots'],
                      dId: data['rideInfo']['dId'],
                      driver: User(
                        name: data['rideInfo']['driver']['name'],
                        email: data['rideInfo']['driver']['email'],
                        rating: data['rideInfo']['driver']['rating'],
                        pic: data['rideInfo']['driver']['pic'],
                        nod: data['rideInfo']['driver']['nod'],
                      ),
                    ),
                    rider: User(
                      name: 'Sidhant Jain',
                      email: 'sidhantjain456@gmail.com',
                      rating: 5.0,
                      pic:
                          'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
                      nod: 5,
                      phone: '0987654321',
                    ),
                    rideFrom: Location(
                      data['rideFrom']['name'],
                      data['rideFrom']['lat'],
                      data['rideFrom']['lon'],
                    ),
                    rideTo: Location(
                      data['rideTo']['name'],
                      data['rideTo']['lat'],
                      data['rideTo']['lon'],
                    ),
                    rideFromTime: "00:00",
                    rideToTime: "00:00",
                    rideSlots: data['rideSlots'],
                    rideStatus: data['rideStatus'],
                  )
                : HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: Location(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: Location(
                        data['rideInfo']['to']['name'],
                        data['rideInfo']['to']['lat'],
                        data['rideInfo']['to']['lon'],
                      ),
                      driveDate: data['rideInfo']['driveDate'],
                      fromTime: data['rideInfo']['fromTime'],
                      toTime: data['rideInfo']['toTime'],
                      vehicle: Vehicle(
                        name: data['rideInfo']['vehicle']['name'],
                        modelName: data['rideInfo']['vehicle']['modelName'],
                        seats: data['rideInfo']['vehicle']['seats'],
                        number: data['rideInfo']['vehicle']['number'],
                        pic: data['rideInfo']['vehicle']['pic'],
                        type: data['rideInfo']['vehicle']['type'],
                        index: data['rideInfo']['vehicle']['index'],
                      ),
                      slots: data['rideInfo']['slots'],
                      dId: data['rideInfo']['dId'],
                      driver: User(
                        name: data['rideInfo']['driver']['name'],
                        email: data['rideInfo']['driver']['email'],
                        rating: data['rideInfo']['driver']['rating'],
                        pic: data['rideInfo']['driver']['pic'],
                        nod: data['rideInfo']['driver']['nod'],
                      ),
                    ),
                    requestFromRiders: data['requestFromRiders']
                        .map<User>(
                          (rider) => User(
                            name: rider['name'],
                            email: rider['email'],
                            rating: rider['rating'] * 1.0,
                            pic: rider['pic'],
                          ),
                        )
                        .toList(),
                    acceptedRiders: data['acceptedRiders']
                        .map<User>(
                          (rider) => User(
                            name: rider['name'],
                            email: rider['email'],
                            rating: rider['rating'] * 1.0,
                            pic: rider['pic'],
                            phone: rider['phone'],
                          ),
                        )
                        .toList(),
                  );
          }).toList();
          _completedRefreshRequired = true;
        } else if (trip == 'cancelled') {}
      });
    } else {
      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (context) => CustomDialog(
      //     icon: Container(
      //       padding: const EdgeInsets.symmetric(vertical: 10),
      //       child: Icon(
      //         Icons.error_outline,
      //         size: 40,
      //         color: buttonColor,
      //       ),
      //     ),
      //     title: 'Invalid Request',
      //     description:
      //         'This incident will be reported.\nYou will be redireted to the login page.',
      //     buttons: FlatButton(
      //       onPressed: () {
      //         Navigator.pushAndRemoveUntil(
      //           context,
      //           MaterialPageRoute(
      //               builder: (BuildContext context) => LoginPage()),
      //           ModalRoute.withName(''),
      //         );
      //       },
      //       child: Text(
      //         'OK',
      //         style: TextStyle(color: buttonColor, fontSize: 20),
      //       ),
      //     ),
      //   ),
      // );
    }
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

  Widget upcomingResults() {
    if (_upcomingRefreshRequired) {
      upcomingList.sort(_resultSorter);
      List<Widget> results = upcomingList.map((ride) {
        Widget drive = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ride.action == 'Driving'
                    ? TripSummaryDriver(ride: ride)
                    : TripSummaryRider(ride: ride),
              ),
            );
          },
          child: HistoryCard(history: ride),
        );

        drive = _upcomingType.contains(ride.action) ? drive : Container();

        // drive = ride.driver.rating >= _filterMinRating ? drive : Container();

        // drive = _filterCarTypes.contains(ride.vehicle.type) ? drive : Container();

        return drive;
      }).toList();
      setState(() {
        upcomingResultListView = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          children: results,
        );
        _upcomingRefreshRequired = false;
      });
    }
    return upcomingResultListView;
  }

  Widget completedResults() {
    if (_completedRefreshRequired) {
      completedList.sort(_resultSorter);
      List<Widget> results = completedList.map((ride) {
        Widget drive = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ride.action == 'Driving'
                    ? TripSummaryDriver(ride: ride)
                    : TripSummaryRider(ride: ride),
              ),
            );
          },
          child: HistoryCard(history: ride),
        );

        // drive =
        //     (_filterSeatsSelected != null && ride.slots != _filterSeatsSelected)
        //         ? Container()
        //         : drive;

        // drive = ride.driver.rating >= _filterMinRating ? drive : Container();

        // drive = _filterCarTypes.contains(ride.vehicle.type) ? drive : Container();

        return drive;
      }).toList();
      setState(() {
        completedResultListView = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          children: results,
        );
        _completedRefreshRequired = false;
      });
    }
    return completedResultListView;
  }

  Widget build(BuildContext context) {
    Widget completedRide = Scaffold(
      body: Container(
        color: borderColor,
        child: completedList == null || completedList.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'No Completed Rides Found',
                ),
              )
            : completedResults(),
      ),
    );
    Widget upcomingRide = Scaffold(
      body: Container(
        color: borderColor,
        child: upcomingList == null || upcomingList.length == 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'No Upcoming Rides Found',
                ),
              )
            : upcomingResults(),
      ),
    );
    final cancelledRide = Scaffold(
      body: Container(
        color: borderColor,
        child: cancelledList == null || cancelledList.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'No Cancelled Rides Found',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: cancelledList.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            cancelledList[i].action == 'Driving'
                                ? TripSummaryDriver(ride: cancelledList[i])
                                : TripSummaryRider(ride: cancelledList[i]),
                      ),
                    );
                  },
                  child: HistoryCard(history: cancelledList[i]),
                ),
              ),
      ),
    );

    Widget createBody() {
      return DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            elevation: 2,
            title: Text(
              widget.name,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black38,
              indicator: CircleTabIndicator(color: Colors.white, radius: 3),
              controller: _tabController,
              tabs: <Widget>[
                Tab(text: 'COMPLETED'),
                Tab(text: 'UPCOMING'),
                Tab(text: 'CANCELLED'),
              ],
            ),
            backgroundColor: buttonColor,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter sheetState) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                sheetState(() {
                                  if (_upcomingType.contains('Riding'))
                                    _upcomingType.remove('Riding');
                                  else
                                    _upcomingType.add('Riding');
                                });
                              },
                              trailing: _upcomingType.contains('Riding')
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.done,
                                        color: buttonColor,
                                      ),
                                    )
                                  : null,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  'Riding',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: buttonColor),
                                ),
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                sheetState(() {
                                  if (_upcomingType.contains('Driving'))
                                    _upcomingType.remove('Driving');
                                  else
                                    _upcomingType.add('Driving');
                                });
                              },
                              trailing: _upcomingType.contains('Driving')
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.done,
                                        color: buttonColor,
                                      ),
                                    )
                                  : null,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  'Driving',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: buttonColor),
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                    },
                  ).then((onValue) {
                    setState(() {
                      if (_tabController.index == 0)
                        _completedRefreshRequired = true;
                      else if (_tabController.index == 1)
                        _upcomingRefreshRequired = true;
                      else if (_tabController.index == 2)
                        _cancelledRefreshRequired = true;
                    });
                  });
                },
              )
            ],
          ),
          body: Container(
            color: bgColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                completedRide,
                upcomingRide,
                cancelledRide,
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

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius * 3);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
