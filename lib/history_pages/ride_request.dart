import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/custom_tooltip.dart';

class RideRequest extends StatefulWidget {
  final HistoryModel ride;
  final User reqUsrInfo;

  RideRequest({Key key, @required this.ride, @required this.reqUsrInfo})
      : super(key: key);
  @override
  _RideRequestState createState() => _RideRequestState();
}

class _RideRequestState extends State<RideRequest> {
  List<Widget> listTiles;
  var _requestRoute = true;
  List<LatLng> line = [];
  MapController _mapController;
  GlobalKey<State<Tooltip>> _tipKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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

  String getMonthOfYear(date, short) {
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
    if (!short) return months[mNum - 1];
    return months[mNum - 1] == 'May'
        ? months[mNum - 1]
        : '${months[mNum - 1].substring(0, 3)}.';
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
        fit: BoxFit.fill,
        image: NetworkImage(widget.ride.rideInfo.vehicle.pic),
      )),
    );
  }

  showSeats({total, toFill, filled, req}) {
    List<Widget> seats = List();
    for (var i = 0; i < total - toFill + filled; i++)
      seats.add(Icon(Icons.person, color: buttonColor, size: 18));
    for (var i = 0; i < req; i++)
      seats.add(Icon(Icons.person_outline, color: buttonColor, size: 18));
    for (var i = 0; i < toFill - filled - req; i++)
      seats.add(Icon(Icons.person_outline, size: 18));

    return Row(
      children: seats,
    );
  }

  _addAcceptedPoint(String name, String from, String time) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        child: Material(
          shape: CircleBorder(),
          elevation: 5,
          color: Colors.white,
          child: Icon(
            Icons.done,
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

  _addNewPoint(String name, String from, String extra) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        child: Material(
          shape: CircleBorder(),
          elevation: 5,
          color: Colors.white,
          child: Icon(
            Icons.person,
            color: buttonColor,
          ),
        ),
      ),
      title: Text(
        '$name',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
        '${from.split(',')[0]},${from.split(',')[1]}',
      ),
      trailing: Text(
        '$extra',
        style: TextStyle(color: buttonColor),
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
      line =
          jsonResponse['trips'][0]['geometry']['coordinates'].map<LatLng>((g) {
        return LatLng(g[1], g[0]);
      }).toList();
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
      // Req Coordinates
      coordinates +=
          '${widget.reqUsrInfo.from.lon},${widget.reqUsrInfo.from.lat};${widget.reqUsrInfo.to.lon},${widget.reqUsrInfo.to.lat};';
      tileData.add({
        'info': 'newPickup',
        'title': 'Pick Up ${widget.reqUsrInfo.name.split(' ')[0]}',
        'subtitle':
            '${widget.reqUsrInfo.from.name.split(',')[0]},${widget.reqUsrInfo.from.name.split(',')[1]}',
        'trailing': 'Detour: 0.0 km',
      });
      tileData.add({
        'info': 'newDrop',
        'title': 'Drop off ${widget.reqUsrInfo.name.split(' ')[0]}',
        'subtitle':
            '${widget.reqUsrInfo.to.name.split(',')[0]},${widget.reqUsrInfo.to.name.split(',')[1]}',
        'trailing': widget.ride.rideInfo.fromTime,
      });
      var distributions = '1,2';
      var count = 3;

      // Accepted Riders Coordinates
      widget.ride.acceptedRiders.forEach((rider) {
        coordinates +=
            '${rider.from.lon},${rider.from.lat};${rider.to.lon},${rider.to.lat};';
        distributions += ';$count';
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
        'extra': 'Arrival: +0 mins',
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
                color: buttonColor,
              ),
            ),
          ),
          title: Text(tileData.first['title']),
          subtitle: Text(tileData.first['subtitle']),
          trailing: Text(
            TimeOfDay(
              hour: int.parse(tileData.first['trailing'].split(':')[0]),
              minute: int.parse(tileData.first['trailing'].split(':')[1]),
            ).format(context),
          ),
        );
        Widget des = ListTile(
          isThreeLine: true,
          leading: Container(
            width: 30,
            height: 30,
            child: Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Colors.white,
              child: Icon(
                Icons.location_on,
                color: buttonColor,
              ),
            ),
          ),
          title: Text(tileData.last['title']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tileData.last['subtitle']),
              Text(
                'Arrival: +${(onValue['trips'][0]['duration'] / 60 - widget.ride.rideInfo.currentDur * 60).toStringAsFixed(0)} mins',
                style: TextStyle(color: buttonColor),
              ),
            ],
          ),
          trailing: Text(
            TimeOfDay(
              hour: int.parse(widget.ride.rideInfo.toTime.split(':')[0]) +
                  (onValue['trips'][0]['duration'] / 3600).toInt(),
              minute: int.parse(widget.ride.rideInfo.toTime.split(':')[1]) +
                  ((onValue['trips'][0]['duration'] % 3600) / 60).toInt(),
            ).format(context),
          ),
        );
        setState(() {
          int i = -1;
          var addSec = 0.0;
          listTiles = temp.map<Widget>((pair) {
            i++;
            addSec += onValue['trips'][0]['legs'][i]['duration'];
            if (pair['value']['info'] == 'newPickup')
              return _addNewPoint(
                pair['value']['title'],
                pair['value']['subtitle'],
                'Detour: ${(onValue['trips'][0]['distance'] / 1000 - widget.ride.rideInfo.currentDis).toStringAsFixed(2)} km',
              );
            if (pair['value']['info'] == 'newDrop')
              return _addNewPoint(
                pair['value']['title'],
                pair['value']['subtitle'],
                TimeOfDay(
                  hour: int.parse(pair['value']['trailing'].split(':')[0]) +
                      addSec ~/ 3600,
                  minute: int.parse(pair['value']['trailing'].split(':')[1]) +
                      (addSec % 3600) ~/ 60,
                ).format(context),
              );

            return _addAcceptedPoint(
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

  int waypointSorter(a, b) => a['index'].compareTo(b['index']);

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
        CircleLayerOptions(
          circles: [
            CircleMarker(
              point: LatLng(
                  widget.ride.rideInfo.from.lat, widget.ride.rideInfo.from.lon),
              color: buttonColor.withOpacity(0.3),
              radius: 25,
            ),
            CircleMarker(
              point: LatLng(
                  widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
              color: buttonColor.withOpacity(0.3),
              radius: 25,
            ),
            CircleMarker(
              point: LatLng(
                  widget.reqUsrInfo.from.lat, widget.reqUsrInfo.from.lon),
              color: buttonColor.withOpacity(0.3),
              radius: 30,
            ),
          ],
        ),
        MarkerLayerOptions(
          markers: [
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
            Marker(
              width: 30.0,
              height: 30.0,
              point: LatLng(
                  widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
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
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(
                  widget.reqUsrInfo.from.lat, widget.reqUsrInfo.from.lon),
              builder: (context) => Tooltip(
                key: _tipKey,
                showDuration: Duration(seconds: 10),
                preferBelow: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                message: widget.reqUsrInfo.name.split(' ')[0],
                textStyle: TextStyle(color: buttonColor),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: TooltipShapeBorder(arrowArc: 0.5),
                  shadows: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: Offset(2, 2))
                  ],
                ),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    final dynamic tooltip = _tipKey.currentState;
                    tooltip.ensureTooltipVisible();
                  },
                  shape: CircleBorder(),
                  elevation: 5,
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.reqUsrInfo.pic),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          contentPadding: const EdgeInsets.only(left: 5, right: 20),
          leading: Container(
            width: 40,
            height: 100,
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.navigate_before,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          title: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              Text(
                '${widget.ride.rideInfo.driveDate.split('/')[0]} ${getMonthOfYear(widget.ride.rideInfo.driveDate, false)} ',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                TimeOfDay(
                  hour: int.parse(widget.ride.rideInfo.toTime.split(':')[0]),
                  minute: int.parse(widget.ride.rideInfo.toTime.split(':')[1]),
                ).format(context),
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Text(
            'Trip to ${widget.ride.rideInfo.from.name.split(',')[0]},${widget.ride.rideInfo.from.name.split(',')[1]}',
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    Widget _tripInfo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 90,
      child: Row(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            child: Image(
              color: buttonColor,
              image: NetworkImage(
                  'https://www.laguardiaairport.com/static/img/Icon-PickDrop.png'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Ride request',
                    style: TextStyle(
                      color: buttonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${getDayOfWeek(widget.ride.rideInfo.driveDate)}, ${getMonthOfYear(widget.ride.rideInfo.driveDate, true)} ${widget.ride.rideInfo.driveDate.split('/')[0]}, ${widget.ride.rideInfo.driveDate.split('/')[2]} | ' +
                        TimeOfDay(
                          hour: int.parse(
                              widget.ride.rideInfo.fromTime.split(':')[0]),
                          minute: int.parse(
                              widget.ride.rideInfo.fromTime.split(':')[1]),
                        ).format(context),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      showSeats(
                        total: widget.ride.rideInfo.vehicle.seats,
                        toFill: widget.ride.rideInfo.total,
                        filled: widget.ride.rideInfo.total -
                            widget.ride.rideInfo.slots,
                        req: widget.reqUsrInfo.slots,
                      ),
                      Text('  ${widget.ride.rideInfo.slots} Seats Available'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget _userInfo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.reqUsrInfo.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
              Row(
                children: <Widget>[
                  _starFilling(widget.reqUsrInfo.rating),
                  _starFilling(widget.reqUsrInfo.rating - 1),
                  _starFilling(widget.reqUsrInfo.rating - 2),
                  _starFilling(widget.reqUsrInfo.rating - 3),
                  _starFilling(widget.reqUsrInfo.rating - 4),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.reqUsrInfo.email,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Material(
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
                  image: NetworkImage(widget.reqUsrInfo.pic),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget bottomSheet = DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (BuildContext context, myscrollController) {
        return Wrap(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height / 10,
                padding: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    var bounds = LatLngBounds();
                    bounds.extend(
                      LatLng(widget.ride.rideInfo.from.lat,
                          widget.ride.rideInfo.from.lon),
                    );
                    bounds.extend(
                      LatLng(widget.ride.rideInfo.to.lat,
                          widget.ride.rideInfo.to.lon),
                    );
                    _mapController.fitBounds(
                      bounds,
                      options: FitBoundsOptions(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.my_location,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
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
                    height: MediaQuery.of(context).size.height * .57 - 56,
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      controller: myscrollController,
                      children: <Widget>[
                        _userInfo,
                        Divider(),
                        _tripInfo,
                        Divider(),
                        _buildRouteInfo(),
                        Divider(),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15.0,
                          offset: Offset(0.0, 0.75),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textColor: buttonColor,
                            color: Colors.white,
                            onPressed: () => Navigator.pop(context, 'Reject'),
                            child: Text('Reject'),
                          ),
                        ),
                        Expanded(
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textColor: Colors.white,
                            color: buttonColor,
                            onPressed: () => Navigator.pop(context, 'Accept'),
                            child: Text('Accept'),
                          ),
                        ),
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
