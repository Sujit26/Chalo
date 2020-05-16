import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/history_pages/history_card.dart';
import 'package:shared_transport/history_pages/notification_page.dart';
import 'package:shared_transport/history_pages/trip_summary_driver.dart';
import 'package:shared_transport/history_pages/trip_summary_rider.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/widgets/empty_state.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class MyTripsPage extends StatefulWidget {
  @override
  _MyTripsPageState createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage>
    with SingleTickerProviderStateMixin {
  var _isLoading = true;
  TabController _tabController;
  // to store all the histories
  List<HistoryModel> completedList;
  List<HistoryModel> upcomingList;
  // history Views
  ListView upcomingResultListView;
  ListView completedResultListView;
  // should rebuild the view
  var _upcomingRefreshRequired = true;
  var _completedRefreshRequired = false;
  // Filters
  var _upcomingType = ['Riding', 'Driving'];
  // Notification
  List<HistoryModel> notifications = [];
  var notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _makeGetRequest('upcoming');
    _tabController = new TabController(initialIndex: 1, length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && completedList == null) {
        _makeGetRequest('completed');
        _isLoading = true;
      }
    });
  }

  _updateRideTimes(jsonData) async {
    for (var data in jsonData['rides']) {
      {
        if (data['action'] == 'Riding') {
          // Rider Coordinates
          var mode = 'driving';
          var accessToken =
              'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
          var coordinates =
              '${data['rideInfo']['from']['lon']},${data['rideInfo']['from']['lat']};${data['rideFrom']['lon']},${data['rideFrom']['lat']};${data['rideTo']['lon']},${data['rideTo']['lat']}';
          var url =
              'https://api.mapbox.com/optimized-trips/v1/mapbox/$mode/$coordinates?&source=first&destination=last&roundtrip=false&access_token=$accessToken&geometries=geojson';
          var res = await get(url);
          var jsonResponse = jsonDecode(res.body);

          var ftime = TimeOfDay(
            hour: int.parse(data['rideInfo']['fromTime'].split(':')[0]) +
                (jsonResponse['trips'][0]['legs'][0]['duration'] / 3600)
                    .toInt(),
            minute: int.parse(data['rideInfo']['fromTime'].split(':')[1]) +
                ((jsonResponse['trips'][0]['legs'][0]['duration'] % 3600) / 60)
                    .toInt(),
          );
          data['rideFromTime'] =
              (ftime.hour + ((ftime.period == DayPeriod.am) ? 0 : 12))
                      .toString() +
                  ':' +
                  ftime.minute.toString();

          var ttime = TimeOfDay(
            hour: int.parse(data['rideInfo']['fromTime'].split(':')[0]) +
                (jsonResponse['trips'][0]['duration'] / 3600).toInt(),
            minute: int.parse(data['rideInfo']['fromTime'].split(':')[1]) +
                ((jsonResponse['trips'][0]['duration'] % 3600) / 60).toInt(),
          );
          data['rideToTime'] =
              (ttime.hour + ((ttime.period == DayPeriod.am) ? 0 : 12))
                      .toString() +
                  ':' +
                  ttime.minute.toString();
        } else {
          // Rider Coordinates
          var mode = 'driving';
          var accessToken =
              'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
          var coordinates =
              '${data['rideInfo']['from']['lon']},${data['rideInfo']['from']['lat']};';
          data['acceptedRiders'].forEach((rider) {
            coordinates += '${rider['from']['lon']},${rider['from']['lat']};';
          });
          coordinates +=
              '${data['rideInfo']['to']['lon']},${data['rideInfo']['to']['lat']}';
          var url =
              'https://api.mapbox.com/optimized-trips/v1/mapbox/$mode/$coordinates?&source=first&destination=last&roundtrip=false&access_token=$accessToken&geometries=geojson';
          var res = await get(url);
          var jsonResponse = jsonDecode(res.body);

          var ttime = TimeOfDay(
            hour: int.parse(data['rideInfo']['fromTime'].split(':')[0]) +
                (jsonResponse['trips'][0]['duration'] / 3600).toInt(),
            minute: int.parse(data['rideInfo']['fromTime'].split(':')[1]) +
                ((jsonResponse['trips'][0]['duration'] % 3600) / 60).toInt(),
          );
          data['rideInfo']['toTime'] =
              (ttime.hour + ((ttime.period == DayPeriod.am) ? 0 : 12))
                      .toString() +
                  ':' +
                  ttime.minute.toString();
        }
      }
    }
    return jsonData;
  }

  _makeGetRequest(trip) async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    final response = await get(Keys.serverURL + 'profile/history', headers: {
      'token': prefs.getString('token'),
      'email': prefs.getString('email'),
      'status': prefs.getString('approveStatus'),
      'trip': trip
    });
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      jsonData = await _updateRideTimes(jsonData);
      setState(() {
        if (trip == 'upcoming') {
          notifications = [];
          notificationCount = 0;
          upcomingList = jsonData['rides'].map<HistoryModel>((data) {
            HistoryModel formatted = data['action'] == 'Riding'
                ? HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: LocationLatLng(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: LocationLatLng(
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
                      driver: data['rideStatus'] == 'Accepted'
                          ? User(
                              name: data['rideInfo']['driver']['name'],
                              email: data['rideInfo']['driver']['email'],
                              rating:
                                  data['rideInfo']['driver']['rating'] * 1.0,
                              pic: data['rideInfo']['driver']['pic'],
                              nod: data['rideInfo']['driver']['nod'],
                              phone: data['rideInfo']['driver']['phone'],
                            )
                          : User(
                              name: data['rideInfo']['driver']['name'],
                              email: data['rideInfo']['driver']['email'],
                              rating:
                                  data['rideInfo']['driver']['rating'] * 1.0,
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
                    rideFrom: LocationLatLng(
                      data['rideFrom']['name'],
                      data['rideFrom']['lat'],
                      data['rideFrom']['lon'],
                    ),
                    rideTo: LocationLatLng(
                      data['rideTo']['name'],
                      data['rideTo']['lat'],
                      data['rideTo']['lon'],
                    ),
                    rideFromTime: data['rideFromTime'],
                    rideToTime: data['rideToTime'],
                    rideSlots: data['rideSlots'],
                    rideStatus: data['rideStatus'],
                  )
                : HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: LocationLatLng(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: LocationLatLng(
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
                      total: data['rideInfo']['total'],
                      dId: data['rideInfo']['dId'],
                      currentDis:
                          data['rideInfo']['route_detail']['dis'].toDouble(),
                      currentDur:
                          data['rideInfo']['route_detail']['dur'].toDouble(),
                      driver: User(
                        name: data['rideInfo']['driver']['name'],
                        email: data['rideInfo']['driver']['email'],
                        rating: data['rideInfo']['driver']['rating'] * 1.0,
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
                            rideId: rider['rideId'],
                            from: LocationLatLng(
                              rider['from']['name'],
                              rider['from']['lat'],
                              rider['from']['lon'],
                            ),
                            to: LocationLatLng(
                              rider['to']['name'],
                              rider['to']['lat'],
                              rider['to']['lon'],
                            ),
                            slots: rider['slots'],
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
                            rideId: rider['rideId'],
                            from: LocationLatLng(
                              rider['from']['name'],
                              rider['from']['lat'],
                              rider['from']['lon'],
                            ),
                            to: LocationLatLng(
                              rider['to']['name'],
                              rider['to']['lat'],
                              rider['to']['lon'],
                            ),
                            slots: rider['slots'],
                          ),
                        )
                        .toList(),
                  );

            if (formatted.action != 'Riding' &&
                formatted.requestFromRiders.length > 0) {
              notifications.add(formatted);
              notificationCount += formatted.requestFromRiders.length;
            }

            return formatted;
          }).toList();
          _upcomingRefreshRequired = true;
        } else if (trip == 'completed') {
          completedList = jsonData['rides'].map<HistoryModel>((data) {
            return data['action'] == 'Riding'
                ? HistoryModel(
                    action: data['action'],
                    rideInfo: RideModel(
                      type: data['rideInfo']['type'],
                      from: LocationLatLng(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: LocationLatLng(
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
                    rideFrom: LocationLatLng(
                      data['rideFrom']['name'],
                      data['rideFrom']['lat'],
                      data['rideFrom']['lon'],
                    ),
                    rideTo: LocationLatLng(
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
                      from: LocationLatLng(
                        data['rideInfo']['from']['name'],
                        data['rideInfo']['from']['lat'],
                        data['rideInfo']['from']['lon'],
                      ),
                      to: LocationLatLng(
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
        }
      });
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
        _isLoading = false;
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
        return drive;
      }).toList();
      setState(() {
        completedResultListView = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          children: results,
        );
        _completedRefreshRequired = false;
        _isLoading = false;
      });
    }
    return completedResultListView;
  }

  Widget build(BuildContext context) {
    Widget completedRide = Scaffold(
      body: Container(
        child: completedList == null || completedList.length <= 0
            ? Center(
                child: EmptyState(
                  title: AppLocalizations.of(context).localisedText['oops'],
                  message: AppLocalizations.of(context)
                      .localisedText['no_rides_found'],
                ),
              )
            : completedResults(),
      ),
    );
    Widget upcomingRide = Scaffold(
      body: Container(
        child: upcomingList == null || upcomingList.length == 0
            ? Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : EmptyState(
                        title:
                            AppLocalizations.of(context).localisedText['oops'],
                        message: AppLocalizations.of(context)
                            .localisedText['no_rides_found'],
                      ),
              )
            : upcomingResults(),
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
            title: Text(AppLocalizations.of(context).localisedText['my_trips']),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black38,
              indicator: CircleTabIndicator(color: Colors.white, radius: 3),
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  text: AppLocalizations.of(context).localisedText['completed'],
                ),
                Tab(
                  text: AppLocalizations.of(context).localisedText['upcoming'],
                ),
              ],
            ),
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
                                        color: Theme.of(context).accentColor,
                                      ),
                                    )
                                  : null,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .localisedText['riding'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).accentColor),
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
                                        color: Theme.of(context).accentColor,
                                      ),
                                    )
                                  : null,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .localisedText['driving'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).accentColor),
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
                    });
                  });
                },
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (build) => NotificationPage(
                            notifications: notifications,
                          ),
                        ),
                      ).then((onValue) {
                        _makeGetRequest('upcoming');
                      });
                    },
                  ),
                  notificationCount != 0
                      ? Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
            centerTitle: true,
          ),
          body: Container(
            child: TabBarView(
              controller: _tabController,
              children: [
                completedRide,
                upcomingRide,
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
