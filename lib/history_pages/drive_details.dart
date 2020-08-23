import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/chat_facitility/chat.dart';
import 'package:shared_transport/chat_facitility/chat_bloc.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/widgets/custom_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriveDetails extends StatefulWidget {
  final HistoryModel ride;

  DriveDetails({Key key, @required this.ride}) : super(key: key);
  @override
  _DriveDetailsState createState() => _DriveDetailsState();
}

class _DriveDetailsState extends State<DriveDetails> {
  WebSocketChannel channel;
  List<Widget> listTiles;
  var _requestRoute = true;
  List<LatLng> line = [];
  List<Marker> markers = [];
  List<CircleMarker> circleMarkers = [];
  MapController _mapController;
  Map userLocations = {};
  Location location;
  LocationData _myLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.ride.action == 'Driving')
      widget.ride.acceptedRiders.forEach((rider) {
        userLocations.putIfAbsent(
          rider.email,
          () => {
            'lat': rider.from.lat,
            'lon': rider.from.lon,
          },
        );
      });
    else
      userLocations.putIfAbsent(
        widget.ride.rideInfo.driver.email,
        () => {
          'lat': widget.ride.rideInfo.from.lat,
          'lon': widget.ride.rideInfo.from.lon,
        },
      );

    _locationShare();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _locationShare() async {
    // Setting up my locations
    location = new Location();
    var tempLoc = await location.getLocation();
    setState(() {
      _myLocation = tempLoc;
    });

    // Conneting to a socket to share live location
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'action': widget.ride.action,
      'driveID': widget.ride.rideInfo.dId,
    };

    channel = IOWebSocketChannel.connect(
        Keys.locationSocket + '?data=${jsonEncode(data)}');
    channel.stream.listen((onData) {
      onData = jsonDecode(onData);
      print('Socket Says: ' + onData.toString());
      if (onData['msg'] != null && onData['msg'] == 'Drive Not Started yet')
        print(onData['msg']);
      if (onData['loc'] != null || onData['driver'] != null) {
        if (widget.ride.action == 'Driving')
          userLocations[onData['email']] = {
            'lat': onData['loc']['lat'],
            'lon': onData['loc']['lon'],
          };
        else
          userLocations[widget.ride.rideInfo.driver.email] = {
            'lat': onData['driver']['lat'],
            'lon': onData['driver']['lon'],
          };
      }
    });

    location.onLocationChanged.listen((newLocation) {
      if (mounted)
        setState(() {
          _myLocation = newLocation;
        });

      channel.sink.add(jsonEncode({
        'msg': {
          'lat': newLocation.latitude,
          'lon': newLocation.longitude,
        }
      }));
    });
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
        fit: BoxFit.fill,
        image: NetworkImage(widget.ride.rideInfo.vehicle.pic),
      )),
    );
  }

  showSeats() {
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
            color: Theme.of(context).accentColor,
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
        'title': AppLocalizations.of(context).localisedText['source_location'],
        'subtitle': widget.ride.action == 'Driving'
            ? '${widget.ride.rideInfo.from.name.split(',')[0]},${widget.ride.rideInfo.from.name.split(',')[1]}'
            : '${widget.ride.rideFrom.name.split(',')[0]},${widget.ride.rideFrom.name.split(',')[1]}',
        'trailing': widget.ride.action == 'Driving'
            ? widget.ride.rideInfo.fromTime
            : widget.ride.rideFromTime,
      });
      var distributions = '';
      var count = 1;

      // Accepted Riders Coordinates
      if (widget.ride.action == 'Driving')
        widget.ride.acceptedRiders.forEach((rider) {
          coordinates +=
              '${rider.from.lon},${rider.from.lat};${rider.to.lon},${rider.to.lat};';
          distributions += count == 1 ? '$count' : ';$count';
          count++;
          distributions += ',$count';
          count++;
          tileData.add({
            'info': 'old',
            'title':
                '${AppLocalizations.of(context).localisedText['pick_up']} ${rider.name.split(' ')[0]}',
            'subtitle':
                '${rider.from.name.split(',')[0]},${rider.from.name.split(',')[1]}',
            'trailing': widget.ride.rideInfo.fromTime,
          });
          tileData.add({
            'info': 'old',
            'title':
                '${AppLocalizations.of(context).localisedText['drop_off']} ${rider.name.split(' ')[0]}',
            'subtitle':
                '${rider.to.name.split(',')[0]},${rider.to.name.split(',')[1]}',
            'trailing': widget.ride.rideInfo.fromTime,
          });
        });
      else {
        coordinates +=
            ('${widget.ride.rideFrom.lon},${widget.ride.rideFrom.lat};' +
                '${widget.ride.rideTo.lon},${widget.ride.rideTo.lat};');
        distributions += count == 1 ? '$count' : ';$count';
        count++;
        distributions += ',$count';
        count++;
      }
      // Driver To Coordinates
      coordinates +=
          '${widget.ride.rideInfo.to.lon},${widget.ride.rideInfo.to.lat}';
      tileData.add({
        'info': 'des',
        'title':
            AppLocalizations.of(context).localisedText['destination_location'],
        'subtitle': widget.ride.action == 'Driving'
            ? '${widget.ride.rideInfo.to.name.split(',')[0]},${widget.ride.rideInfo.to.name.split(',')[1]}'
            : '${widget.ride.rideTo.name.split(',')[0]},${widget.ride.rideTo.name.split(',')[1]}',
        'trailing': widget.ride.action == 'Driving'
            ? widget.ride.rideInfo.fromTime
            : widget.ride.rideToTime,
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
                (widget.ride.action == 'Driving'
                    ? (onValue['trips'][0]['duration'] / 3600).toInt()
                    : 0),
            minute: int.parse(tileData.last['trailing'].split(':')[1]) +
                (widget.ride.action == 'Driving'
                    ? ((onValue['trips'][0]['duration'] % 3600) / 60).toInt()
                    : 0),
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

  _drawLocations() {
    if (widget.ride.action == 'Driving')
      setState(() {
        // Accepted riders location
        markers = widget.ride.acceptedRiders.map((rider) {
          return Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(userLocations[rider.email]['lat'],
                userLocations[rider.email]['lon']),
            builder: (context) => CustomTooltip(
              message: rider.name.split(' ')[0],
              bgColor: Theme.of(context).accentColor,
              photoUrl: rider.pic,
            ),
          );
        }).toList();
        // Driver from to location
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
        markers.insert(
          0,
          Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(
                widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
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

        // Driver (current user) location
        markers.add(
          Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(_myLocation.latitude, _myLocation.longitude),
            builder: (context) => Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Theme.of(context).accentColor,
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Icon(
                  Icons.drive_eta,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

        circleMarkers = widget.ride.acceptedRiders.map((rider) {
          return CircleMarker(
            point: LatLng(userLocations[rider.email]['lat'],
                userLocations[rider.email]['lon']),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 30,
          );
        }).toList();
        circleMarkers.insert(
          0,
          CircleMarker(
            point: LatLng(
                widget.ride.rideInfo.from.lat, widget.ride.rideInfo.from.lon),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );
        circleMarkers.insert(
          0,
          CircleMarker(
            point: LatLng(
                widget.ride.rideInfo.to.lat, widget.ride.rideInfo.to.lon),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );

        circleMarkers.add(
          CircleMarker(
            point: LatLng(_myLocation.latitude, _myLocation.longitude),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );
      });
    else
      setState(() {
        markers = [];
        // Rider to location
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
        // Rider (current user) location
        markers.add(
          Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(_myLocation.latitude, _myLocation.longitude),
            builder: (context) => Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Theme.of(context).accentColor,
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Icon(
                  Icons.my_location,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
        // Driver location
        markers.add(
          Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(
              userLocations[widget.ride.rideInfo.driver.email]['lat'],
              userLocations[widget.ride.rideInfo.driver.email]['lon'],
            ),
            builder: (context) => Material(
              shape: CircleBorder(),
              elevation: 5,
              color: Theme.of(context).accentColor,
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Icon(
                  Icons.drive_eta,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

        circleMarkers = [];
        // Rider to location
        circleMarkers.add(
          CircleMarker(
            point: LatLng(widget.ride.rideTo.lat, widget.ride.rideTo.lon),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );
        // Rider (current user) location
        circleMarkers.add(
          CircleMarker(
            point: LatLng(_myLocation.latitude, _myLocation.longitude),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );
        // Driver location
        circleMarkers.add(
          CircleMarker(
            point: LatLng(
              userLocations[widget.ride.rideInfo.driver.email]['lat'],
              userLocations[widget.ride.rideInfo.driver.email]['lon'],
            ),
            color: Theme.of(context).accentColor.withOpacity(0.3),
            radius: 25,
          ),
        );
      });
  }

  Widget map() {
    if (_myLocation != null) _drawLocations();
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
    Widget appBar = Column(
      children: <Widget>[
        Material(
          color: Theme.of(context).accentColor,
          elevation: 2,
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
              title: Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: <Widget>[
                  Text(
                    '${widget.ride.rideInfo.driveDate.split('/')[0]} ${getMonthOfYear(widget.ride.rideInfo.driveDate)} ',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.ride.action == 'Driving'
                        ? TimeOfDay(
                            hour: int.parse(
                                widget.ride.rideInfo.fromTime.split(':')[0]),
                            minute: int.parse(
                                widget.ride.rideInfo.fromTime.split(':')[1]),
                          ).format(context)
                        : TimeOfDay(
                            hour: int.parse(
                                widget.ride.rideFromTime.split(':')[0]),
                            minute: int.parse(
                                widget.ride.rideFromTime.split(':')[1]),
                          ).format(context),
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Text(
                '${AppLocalizations.of(context).localisedText['trip_to']} ' +
                    (widget.ride.action == 'Driving'
                        ? '${widget.ride.rideInfo.to.name}'
                        : '${widget.ride.rideTo.name}'),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              trailing: Container(
                margin: const EdgeInsets.only(right: 10, top: 5),
                width: 50,
                height: 40,
                child: MaterialButton(
                  padding: const EdgeInsets.all(0),
                  color: Colors.white,
                  onPressed: () {
                    print('send sos');
                    channel.sink.add(jsonEncode({'msg': 'sos'}));
                  },
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: widget.ride.action == 'Driving'
              ? Container(
                  margin: const EdgeInsets.only(right: 10, top: 5),
                  width: 50,
                  height: 40,
                  child: MaterialButton(
                    padding: const EdgeInsets.all(0),
                    color: Colors.white,
                    onPressed: () {
                      print('Finish Trip');
                      channel.sink.add(jsonEncode({'msg': 'finish'}));
                    },
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                )
              : Container(),
        ),
      ],
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
                    subtitle: showSeats(),
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

    Widget _userInfo(image, name, {rating, phone, user}) {
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
              border:
                  Border.all(color: Theme.of(context).accentColor, width: 2),
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
            ? Row(
                children: <Widget>[
                  _starFilling(rating),
                  _starFilling(rating - 1),
                  _starFilling(rating - 2),
                  _starFilling(rating - 3),
                  _starFilling(rating - 4),
                ],
              )
            : null,
        trailing: phone != null
            ? Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      var link = 'tel:$phone';
                      launch(link);
                    },
                    color: Theme.of(context).accentColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () {
                      ChatBloc _chatBloc = ChatBloc();
                      ChatModel _chatModel =
                          ChatModel(user, '', true, DateTime.now());
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Chat(
                                    chat: _chatModel,
                                    chatBloc: _chatBloc,
                                  )));
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              )
            : Wrap(),
      );
    }

    Widget _driveUsers() {
      if (widget.ride.action == 'Driving') {
        List<Widget> users = [];
        widget.ride.acceptedRiders.forEach((rider) {
          users.add(_userInfo(rider.pic,
              Text('${rider.name}', style: TextStyle(color: Colors.black)),
              rating: rider.rating, phone: rider.phone, user: rider));
          users.add(Divider());
        });
        return Wrap(
          children: users,
        );
      } else {
        return Wrap(
          children: <Widget>[
            _userInfo(
              widget.ride.rideInfo.driver.pic,
              Text('${widget.ride.rideInfo.driver.name}',
                  style: TextStyle(color: Colors.black)),
              rating: widget.ride.rideInfo.driver.rating,
              phone: widget.ride.rideInfo.driver.phone,
              user: widget.ride.rideInfo.driver,
            ),
            Divider(),
          ],
        );
      }
    }

    Widget bottomSheet = DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (BuildContext context, myscrollController) {
        return Wrap(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                children: <Widget>[
                  Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height / 10,
                    padding: const EdgeInsets.all(10.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {},
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ],
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
                    height: MediaQuery.of(context).size.height * .57,
                    child: ListView(
                      controller: myscrollController,
                      children: <Widget>[
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
