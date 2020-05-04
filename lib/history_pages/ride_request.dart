import 'package:flutter/material.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';

class RideRequest extends StatefulWidget {
  final HistoryModel ride;
  final User reqUsrInfo;

  RideRequest({Key key, @required this.ride, @required this.reqUsrInfo})
      : super(key: key);
  @override
  _RideRequestState createState() => _RideRequestState();
}

class _RideRequestState extends State<RideRequest> {
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
      trailing: Text(
        TimeOfDay(
          hour: int.parse(time.split(':')[0]),
          minute: int.parse(time.split(':')[1]),
        ).format(context),
      ),
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

  Widget _buildRouteInfo() {
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
            children: <Widget>[
              // Source Location
              ListTile(
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
                title: Text('Source Location'),
                subtitle: Text(
                  '${widget.ride.rideInfo.from.name.split(',')[0]},${widget.ride.rideInfo.from.name.split(',')[1]}',
                ),
                trailing: Text(
                  TimeOfDay(
                    hour:
                        int.parse(widget.ride.rideInfo.fromTime.split(':')[0]),
                    minute:
                        int.parse(widget.ride.rideInfo.fromTime.split(':')[1]),
                  ).format(context),
                ),
              ),
              // Additional Stop Points
              _addAcceptedPoint(
                'Pick Up Sidhant',
                'Sidhant, from location',
                '13:00',
              ),
              _addNewPoint(
                'Pick Up ${widget.reqUsrInfo.name.split(' ')[0]}',
                '${widget.reqUsrInfo.from.name}',
                'Detour: 0.4 km',
              ),
              _addAcceptedPoint(
                'Drop off Sidhant',
                'Sidhant, to location',
                '15:00',
              ),
              _addNewPoint(
                'Drop off ${widget.reqUsrInfo.name.split(' ')[0]}',
                '${widget.reqUsrInfo.to.name}',
                TimeOfDay(
                  hour: int.parse('01:00'.split(':')[0]),
                  minute: int.parse('01:00'.split(':')[1]),
                ).format(context),
              ),
              // Destination Location
              ListTile(
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
                title: Text('Destination Location'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${widget.ride.rideInfo.to.name.split(',')[0]},${widget.ride.rideInfo.to.name.split(',')[1]}',
                    ),
                    Text(
                      'Arrival: +10 mins',
                      style: TextStyle(color: buttonColor),
                    ),
                  ],
                ),
                trailing: Text(
                  TimeOfDay(
                    hour: int.parse(widget.ride.rideInfo.toTime.split(':')[0]),
                    minute:
                        int.parse(widget.ride.rideInfo.toTime.split(':')[1]),
                  ).format(context),
                ),
              ),
            ],
          ),
        ],
      ),
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

    Widget map = Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: mainColor,
      child: Image(
        fit: BoxFit.cover,
        image: NetworkImage(
            'https://www.theinformationlab.co.uk/wp-content/uploads/2016/02/Basic.png'),
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
                          toFill: widget.ride.rideInfo.slots,
                          filled: widget.ride.acceptedRiders.length,
                          req: widget.reqUsrInfo.slots),
                      Text(
                          '  ${widget.ride.rideInfo.slots - widget.ride.acceptedRiders.length} Seats Available'),
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
      initialChildSize: 0.7,
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
                  onPressed: () {},
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
                            onPressed: () {},
                            child: Text('Reject'),
                          ),
                        ),
                        Expanded(
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textColor: Colors.white,
                            color: buttonColor,
                            onPressed: () {},
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
              map,
              bottomSheet,
              appBar,
            ],
          ),
        ),
      ),
    );
  }
}
