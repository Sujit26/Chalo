import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'package:shared_transport/models/models.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_transport/utils/localizations.dart';

class TripSummaryRider extends StatefulWidget {
  final HistoryModel ride;

  TripSummaryRider({Key key, @required this.ride}) : super(key: key);
  @override
  _TripSummaryRiderState createState() => _TripSummaryRiderState();
}

class _TripSummaryRiderState extends State<TripSummaryRider> {
  List<Widget> listTiles = [];
  var _requestRoute = true;
  List<LatLng> line = [];
  List<Marker> markers = [];
  List<CircleMarker> circleMarkers = [];
  MapController _mapController;

  var dis = 0.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapController.onReady.then((onValue) {
      var bounds = LatLngBounds();
      bounds.extend(LatLng(widget.ride.rideFrom.lat, widget.ride.rideFrom.lon));
      bounds.extend(LatLng(widget.ride.rideTo.lat, widget.ride.rideTo.lon));
      _mapController.fitBounds(
        bounds,
        options: FitBoundsOptions(
          padding: const EdgeInsets.symmetric(horizontal: 50),
        ),
      );
    });
  }

  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(widget.ride.rideInfo.driveDate.split('/')[2]),
      int.parse(widget.ride.rideInfo.driveDate.split('/')[1]),
      int.parse(widget.ride.rideInfo.driveDate.split('/')[0]),
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
      int.parse(widget.ride.rideInfo.driveDate.split('/')[2]),
      int.parse(widget.ride.rideInfo.driveDate.split('/')[1]),
      int.parse(widget.ride.rideInfo.driveDate.split('/')[0]),
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

  String timeConversion(time) {
    return TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    ).format(context);
  }

  Widget _starFilling(double fill) {
    return fill >= 1.0
        ? Icon(
            Icons.star,
            color: Theme.of(context).accentColor,
            size: 20,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: Theme.of(context).accentColor,
                size: 20,
              )
            : Icon(
                Icons.star_border,
                color: Theme.of(context).accentColor,
                size: 20,
              );
  }

  showCarPic() {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: NetworkImage(widget.ride.rideInfo.vehicle.pic),
      )),
    );
  }

  showCarSeats() {
    List<Widget> seats = List();
    for (var i = 0;
        i < widget.ride.rideInfo.vehicle.seats - widget.ride.rideInfo.slots;
        i++)
      seats.add(
          Icon(Icons.person, color: Theme.of(context).accentColor, size: 18));
    for (var i = 0; i < widget.ride.rideInfo.slots; i++)
      seats.add(Icon(Icons.person_outline,
          color: Theme.of(context).accentColor, size: 18));

    return Row(
      children: seats,
    );
  }

  Widget _userInfo(action, image, name, {rating, phone}) {
    return ListTile(
      leading: Material(
        shape: CircleBorder(),
        elevation: 5,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).accentColor, width: 2),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                image,
              ),
            ),
          ),
        ),
      ),
      title: name,
      subtitle: rating != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(action),
                Row(
                  children: <Widget>[
                    _starFilling(rating),
                    _starFilling(rating - 1),
                    _starFilling(rating - 2),
                    _starFilling(rating - 3),
                    _starFilling(rating - 4),
                  ],
                ),
              ],
            )
          : null,
      trailing: phone != null
          ? Wrap(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {},
                  color: Theme.of(context).accentColor,
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {},
                  color: Theme.of(context).primaryColor,
                ),
              ],
            )
          : Wrap(),
    );
  }

  Widget _driveUsers() {
    List<Widget> users = [];

    users.add(_userInfo(
      'Passenger',
      widget.ride.rider.pic,
      Row(
        children: <Widget>[
          Text(AppLocalizations.of(context).localisedText['you'],
              style: TextStyle(color: Theme.of(context).accentColor)),
          Text(
              AppLocalizations.of(context)
                  .localisedText['were_passenger_of_the_trip'],
              style: TextStyle(color: Colors.black)),
        ],
      ),
    ));
    users.add(Divider());

    users.add(_userInfo(
        'Driver',
        widget.ride.rideInfo.driver.pic,
        Text('${widget.ride.rideInfo.driver.name}',
            style: TextStyle(color: Colors.black)),
        rating: widget.ride.rideInfo.driver.rating,
        phone: widget.ride.rideInfo.driver.phone));
    users.add(Divider());

    return Wrap(
      children: users,
    );
  }

  _makeRouteRequest() async {
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    var mode = 'driving';
    // Rider Coordinates
    var coordinates =
        '${widget.ride.rideFrom.lon},${widget.ride.rideFrom.lat};${widget.ride.rideTo.lon},${widget.ride.rideTo.lat}';
    var url =
        'https://api.mapbox.com/optimized-trips/v1/mapbox/$mode/$coordinates?&source=first&destination=last&roundtrip=false&access_token=$accessToken&geometries=geojson';
    var res = await get(url);
    var jsonResponse = jsonDecode(res.body);
    setState(() {
      dis = jsonResponse['trips'][0]['distance'] / 1000;

      line =
          jsonResponse['trips'][0]['geometry']['coordinates'].map<LatLng>((g) {
        return LatLng(g[1], g[0]);
      }).toList();

      markers = [];
      markers.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(widget.ride.rideFrom.lat, widget.ride.rideFrom.lon),
          builder: (context) => Material(
            shape: CircleBorder(),
            elevation: 5,
            color: Theme.of(context).accentColor,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.directions_car,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      markers.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(widget.ride.rideTo.lat, widget.ride.rideTo.lon),
          builder: (context) => Material(
            shape: CircleBorder(),
            elevation: 5,
            color: Theme.of(context).accentColor,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.done,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      circleMarkers = [];
      circleMarkers.add(
        CircleMarker(
          point: LatLng(widget.ride.rideFrom.lat, widget.ride.rideFrom.lon),
          color: Theme.of(context).accentColor.withOpacity(0.3),
          radius: 25,
        ),
      );
      circleMarkers.add(
        CircleMarker(
          point: LatLng(widget.ride.rideTo.lat, widget.ride.rideTo.lon),
          color: Theme.of(context).accentColor.withOpacity(0.3),
          radius: 25,
        ),
      );
    });
    return jsonResponse;
  }

  Widget _buildRouteInfo() {
    if (_requestRoute) {
      _makeRouteRequest().then((onValue) {
        Widget src = ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Colors.white,
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          title: Text(
              AppLocalizations.of(context).localisedText['source_location']),
          subtitle: Text(
            '${widget.ride.rideFrom.name.split(',')[0]},${widget.ride.rideFrom.name.split(',')[1]}',
          ),
          trailing: Text(
            TimeOfDay(
              hour: int.parse(widget.ride.rideFromTime.split(':')[0]),
              minute: int.parse(widget.ride.rideFromTime.split(':')[1]),
            ).format(context),
          ),
        );
        Widget des = ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Colors.white,
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)
              .localisedText['destination_location']),
          subtitle: Text(
            '${widget.ride.rideTo.name.split(',')[0]},${widget.ride.rideTo.name.split(',')[1]}',
          ),
          trailing: Text(
            TimeOfDay(
              hour: int.parse(widget.ride.rideToTime.split(':')[0]),
              minute: int.parse(widget.ride.rideToTime.split(':')[1]),
            ).format(context),
          ),
        );

        setState(() {
          listTiles = [];
          listTiles.add(src);
          listTiles.add(des);
          _requestRoute = false;
        });
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 28,
            bottom: 50,
            left: 27,
            child: Container(
              width: 7,
              height: 1000,
              color: Theme.of(context).accentColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listTiles,
          ),
        ],
      ),
    );
  }

  Color statusColor(status) {
    if (status == 'Accepted')
      return Colors.green[300];
    else if (status == 'Rejected')
      return Colors.red[300];
    else if (status == 'Requested')
      return Colors.amber[300];
    else
      return Colors.black;
  }

  Widget map() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(widget.ride.rideFrom.lat, widget.ride.rideFrom.lon),
        minZoom: 3.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/paradox-sid/ck9vf9nq008b81ip8myceai04/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig',
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig',
            'id': 'mapbox.streets'
          },
        ),
        PolylineLayerOptions(
          polylines: [
            Polyline(
                points: line,
                strokeWidth: 2,
                color: Theme.of(context).accentColor),
          ],
        ),
        CircleLayerOptions(circles: circleMarkers),
        MarkerLayerOptions(markers: markers),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = Material(
      elevation: 2,
      color: Theme.of(context).appBarTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 95,
        padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          leading: Container(
            width: 20,
            height: 100,
            alignment: Alignment.topLeft,
            child: Icon(
              Icons.navigate_before,
              size: 40,
              color: Colors.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).localisedText['trip_summary'],
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateTime.utc(
                      int.parse(widget.ride.rideInfo.driveDate.split('/')[2]),
                      int.parse(widget.ride.rideInfo.driveDate.split('/')[1]),
                      int.parse(widget.ride.rideInfo.driveDate.split('/')[0]),
                    ).compareTo(DateTime.now()) ==
                    1
                ? AppLocalizations.of(context).localisedText['upcoming_ride']
                : AppLocalizations.of(context).localisedText['completed_ride'],
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    Widget _tripDestination = ListTile(
      title: Text(
        '${AppLocalizations.of(context).localisedText['trip_to']} ${widget.ride.rideTo.name}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
          '${widget.ride.rideInfo.driveDate.split('/')[0]} ${getMonthOfYear(widget.ride.rideInfo.driveDate)} ${widget.ride.rideInfo.driveDate.split('/')[2]}, ${timeConversion(widget.ride.rideFromTime)}'),
      trailing: Text(
        '${AppLocalizations.of(context).localisedText[widget.ride.rideStatus.toLowerCase()]}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor(widget.ride.rideStatus),
        ),
      ),
    );

    Widget _tripRatingAndDis = Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: Text(
                AppLocalizations.of(context).localisedText['your_rating'],
              ),
              subtitle: Row(
                children: <Widget>[
                  _starFilling(0),
                  _starFilling(0),
                  _starFilling(0),
                  _starFilling(0),
                  _starFilling(0),
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: ListTile(
              title: Text(AppLocalizations.of(context)
                  .localisedText['distance_covered']),
              subtitle: Text(
                '${dis.toStringAsFixed(2)} Kms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget _carInfo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                elevation: 3,
                shape: CircleBorder(),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2, color: Theme.of(context).accentColor),
                  ),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 5,
                    color: Colors.white,
                  ),
                ),
              ),
              Material(
                elevation: 3,
                shape: CircleBorder(),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1, color: Colors.white),
                  ),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 7,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Material(
                elevation: 3,
                shape: CircleBorder(),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2, color: Theme.of(context).accentColor),
                  ),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 45,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      AppLocalizations.of(context).localisedText['car_model'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.ride.rideInfo.vehicle.name} ${widget.ride.rideInfo.vehicle.modelName}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      AppLocalizations.of(context)
                          .localisedText['registration_number'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.ride.rideInfo.vehicle.number}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      AppLocalizations.of(context).localisedText['seats'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                    ),
                    subtitle: showCarSeats(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: showCarPic(),
          ),
        ],
      ),
    );

    Widget bottomSheet = DraggableScrollableSheet(
      initialChildSize: 0.16,
      minChildSize: 0.16,
      maxChildSize: 0.6,
      builder: (BuildContext context, myscrollController) {
        return Wrap(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      alignment: Alignment.topCenter,
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.black38,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .57,
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      controller: myscrollController,
                      children: <Widget>[
                        _tripDestination,
                        Divider(),
                        _tripRatingAndDis,
                        Divider(),
                        _carInfo,
                        Divider(),
                        _buildRouteInfo(),
                        Divider(),
                        _driveUsers(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              map(),
              bottomSheet,
              appBar,
            ],
          ),
        ),
      ),
    );
  }
}
