import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_transport/history_pages/drive_details.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/widgets/custom_tooltip.dart';

class TripSummaryDriver extends StatefulWidget {
  final HistoryModel ride;

  TripSummaryDriver({Key key, @required this.ride}) : super(key: key);
  @override
  _TripSummaryDriverState createState() => _TripSummaryDriverState();
}

class _TripSummaryDriverState extends State<TripSummaryDriver> {
  List<Widget> listTiles;
  var _requestRoute = true;
  var dis = 0.0;
  List<LatLng> line = [];
  List<Marker> markers = [];
  List<CircleMarker> circleMarkers = [];
  MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
            color: buttonColor,
            size: 20,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: buttonColor,
                size: 20,
              )
            : Icon(
                Icons.star_border,
                color: buttonColor,
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

  showSeats() {
    List<Widget> seats = List();
    for (var i = 0;
        i < widget.ride.rideInfo.total - widget.ride.rideInfo.slots;
        i++) seats.add(Icon(Icons.person, color: buttonColor, size: 18));
    for (var i = 0; i < widget.ride.rideInfo.slots; i++)
      seats.add(Icon(Icons.person_outline, color: buttonColor, size: 18));

    return Row(
      children: seats,
    );
  }

  showCarSeats() {
    List<Widget> seats = List();
    for (var i = 0;
        i < widget.ride.rideInfo.vehicle.seats - widget.ride.rideInfo.slots;
        i++) seats.add(Icon(Icons.person, color: buttonColor, size: 18));
    for (var i = 0; i < widget.ride.rideInfo.slots; i++)
      seats.add(Icon(Icons.person_outline, color: buttonColor, size: 18));

    return Row(
      children: seats,
    );
  }

  _addAcceptedPoint(IconData icon, String name, String from, String time) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        child: Material(
          shape: CircleBorder(),
          elevation: 5,
          color: Colors.white,
          child: Icon(
            icon,
            color: buttonColor,
          ),
        ),
      ),
      title: Text('$name'),
      subtitle: Text(
        '${from.split(',')[0]},${from.split(',')[1]}',
      ),
      trailing: Text(time),
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
            border: Border.all(color: buttonColor, width: 2),
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
                  color: buttonColor,
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {},
                  color: mainColor,
                ),
              ],
            )
          : Wrap(),
    );
  }

  Widget _driveUsers() {
    List<Widget> users = [];

    users.add(_userInfo(
      'Driver',
      widget.ride.rideInfo.driver.pic,
      Row(
        children: <Widget>[
          Text('You ', style: TextStyle(color: buttonColor)),
          Text('were driver of the trip',
              style: TextStyle(color: Colors.black)),
        ],
      ),
    ));
    users.add(Divider());
    widget.ride.acceptedRiders.forEach((rider) {
      users.add(_userInfo('Rider', rider.pic,
          Text('${rider.name}', style: TextStyle(color: Colors.black)),
          rating: rider.rating, phone: rider.phone));
      users.add(Divider());
    });

    return Wrap(
      children: users,
    );
  }

  int waypointSorter(a, b) => a['index'].compareTo(b['index']);

  Widget _buildRouteInfo() {
    if (_requestRoute) {
      listTiles = [];
      List tileData = [];
      // Driver From Coordinates
      var coordinates =
          '${widget.ride.rideInfo.from.lon},${widget.ride.rideInfo.from.lat};';
      tileData.add({
        'info': 'src',
        'title': 'Source Location',
        'subtitle':
            '${widget.ride.rideInfo.from.name.split(',')[0]},${widget.ride.rideInfo.from.name.split(',')[1]}',
        'trailing': widget.ride.rideInfo.fromTime,
      });
      var distributions = '';
      var count = 1;

      // Accepted Riders Coordinates
      widget.ride.acceptedRiders.forEach((rider) {
        coordinates +=
            '${rider.from.lon},${rider.from.lat};${rider.to.lon},${rider.to.lat};';
        distributions += count == 1 ? '$count' : ';$count';
        count++;
        distributions += ',$count';
        count++;
        tileData.add({
          'info': 'old',
          'title': 'Pick Up ${rider.name.split(' ')[0]}',
          'subtitle':
              '${rider.from.name.split(',')[0]},${rider.from.name.split(',')[1]}',
          'trailing': widget.ride.rideInfo.fromTime,
        });
        tileData.add({
          'info': 'old',
          'title': 'Drop off ${rider.name.split(' ')[0]}',
          'subtitle':
              '${rider.to.name.split(',')[0]},${rider.to.name.split(',')[1]}',
          'trailing': widget.ride.rideInfo.fromTime,
        });
      });

      // Driver To Coordinates
      coordinates +=
          '${widget.ride.rideInfo.to.lon},${widget.ride.rideInfo.to.lat}';
      tileData.add({
        'info': 'des',
        'title': 'Destination Location',
        'subtitle':
            '${widget.ride.rideInfo.to.name.split(',')[0]},${widget.ride.rideInfo.to.name.split(',')[1]}',
        'trailing': widget.ride.rideInfo.fromTime,
      });

      _makeRouteRequest(coordinates, distributions).then((onValue) {
        List temp = [];
        for (var i = 0; i < tileData.length; i++) {
          if (i == 0 || i == tileData.length - 1) continue;
          temp.add({
            'index': onValue['waypoints'][i]['waypoint_index'],
            'value': tileData[i],
          });
        }
        temp.sort(waypointSorter);

        Widget src = _addAcceptedPoint(
          Icons.location_on,
          tileData.first['title'],
          tileData.first['subtitle'],
          TimeOfDay(
            hour: int.parse(tileData.first['trailing'].split(':')[0]),
            minute: int.parse(tileData.first['trailing'].split(':')[1]),
          ).format(context),
        );
        Widget des = _addAcceptedPoint(
          Icons.location_on,
          tileData.last['title'],
          tileData.last['subtitle'],
          TimeOfDay(
            hour: int.parse(tileData.last['trailing'].split(':')[0]) +
                (onValue['trips'][0]['duration'] / 3600).toInt(),
            minute: int.parse(tileData.last['trailing'].split(':')[1]) +
                ((onValue['trips'][0]['duration'] % 3600) / 60).toInt(),
          ).format(context),
        );

        setState(() {
          int i = -1;
          var addSec = 0.0;
          listTiles = temp.map<Widget>((pair) {
            i++;
            addSec += onValue['trips'][0]['legs'][i]['duration'];
            return _addAcceptedPoint(
              pair['value']['title'].contains('Drop off')
                  ? Icons.remove
                  : Icons.add,
              pair['value']['title'],
              pair['value']['subtitle'],
              TimeOfDay(
                hour: int.parse(pair['value']['trailing'].split(':')[0]) +
                    addSec ~/ 3600,
                minute: int.parse(pair['value']['trailing'].split(':')[1]) +
                    (addSec % 3600) ~/ 60,
              ).format(context),
            );
          }).toList();
          listTiles.insert(0, src);
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
              color: buttonColor,
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

  _makeRouteRequest(coordinates, distributions) async {
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    var mode = 'driving';
    var url =
        'https://api.mapbox.com/optimized-trips/v1/mapbox/$mode/$coordinates?&distributions=$distributions&source=first&destination=last&roundtrip=false&access_token=$accessToken&geometries=geojson';
    var res = await get(url);
    var jsonResponse = jsonDecode(res.body);
    setState(() {
      dis = jsonResponse['trips'][0]['distance'] / 1000;

      line =
          jsonResponse['trips'][0]['geometry']['coordinates'].map<LatLng>((g) {
        return LatLng(g[1], g[0]);
      }).toList();

      markers = widget.ride.acceptedRiders.map((rider) {
        return Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(rider.from.lat, rider.from.lon),
          builder: (context) => CustomTooltip(
            message: rider.name.split(' ')[0],
            bgColor: buttonColor,
            photoUrl: rider.pic,
          ),
        );
      }).toList();
      markers.insert(
        0,
        Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(
              widget.ride.rideInfo.from.lat, widget.ride.rideInfo.from.lon),
          builder: (context) => Material(
            shape: CircleBorder(),
            elevation: 5,
            color: buttonColor,
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
      markers.insert(
        0,
        Marker(
          width: 30.0,
          height: 30.0,
          point:
              LatLng(widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
          builder: (context) => Material(
            shape: CircleBorder(),
            elevation: 5,
            color: buttonColor,
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

      circleMarkers = widget.ride.acceptedRiders.map((rider) {
        return CircleMarker(
          point: LatLng(rider.from.lat, rider.from.lon),
          color: buttonColor.withOpacity(0.3),
          radius: 30,
        );
      }).toList();
      circleMarkers.insert(
        0,
        CircleMarker(
          point: LatLng(
              widget.ride.rideInfo.from.lat, widget.ride.rideInfo.from.lon),
          color: buttonColor.withOpacity(0.3),
          radius: 25,
        ),
      );
      circleMarkers.insert(
        0,
        CircleMarker(
          point:
              LatLng(widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
          color: buttonColor.withOpacity(0.3),
          radius: 25,
        ),
      );

      var bounds = LatLngBounds();
      bounds.extend(
        LatLng(widget.ride.rideInfo.from.lat, widget.ride.rideInfo.from.lon),
      );
      bounds.extend(
        LatLng(widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
      );
      _mapController.fitBounds(
        bounds,
        options: FitBoundsOptions(
          padding: const EdgeInsets.symmetric(horizontal: 50),
        ),
      );
    });
    return jsonResponse;
  }

  Widget map() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(
          widget.ride.rideInfo.from.lat,
          widget.ride.rideInfo.from.lon,
        ),
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
            Polyline(points: line, strokeWidth: 2, color: buttonColor),
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
      color: buttonColor,
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
            'Trip Summary',
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
                ? 'Upcoming drive'
                : 'Completed drive',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    Widget _tripDestination = ListTile(
      isThreeLine: true,
      title: Text(
        'Trip to ${widget.ride.rideInfo.to.name}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              '${widget.ride.rideInfo.driveDate.split('/')[0]} ${getMonthOfYear(widget.ride.rideInfo.driveDate)} ${widget.ride.rideInfo.driveDate.split('/')[2]}, ${timeConversion(widget.ride.rideInfo.fromTime)}'),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                showSeats(),
                Text(
                    '  ${widget.ride.rideInfo.total - widget.ride.rideInfo.slots} Slots Filled'),
              ],
            ),
          ),
        ],
      ),
      trailing: DateTime.utc(
                int.parse(widget.ride.rideInfo.driveDate.split('/')[2]),
                int.parse(widget.ride.rideInfo.driveDate.split('/')[1]),
                int.parse(widget.ride.rideInfo.driveDate.split('/')[0]),
              ).compareTo(DateTime.now()) ==
              1
          ? OutlineButton(
              child: Text(
                'Start Trip',
                style: TextStyle(color: buttonColor),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriveDetails(ride: widget.ride),
                  ),
                );
              },
              highlightedBorderColor: buttonColor,
              borderSide: BorderSide(
                color: buttonColor,
                style: BorderStyle.solid,
                width: 0.8,
              ),
            )
          : Wrap(),
    );

    Widget _tripRatingAndDis = Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: Text(
                'Your Rating',
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
              title: Text('Distance Covered'),
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
                    border: Border.all(width: 2, color: buttonColor),
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
                    color: buttonColor,
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
                    border: Border.all(width: 2, color: buttonColor),
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
                      'Car Model',
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
                      'Registration no.',
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
                      'Seats',
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
      initialChildSize: 0.2,
      minChildSize: 0.2,
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
      backgroundColor: bgColor,
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
