import 'package:flutter/material.dart';
import 'package:shared_transport/history_pages/drive_details.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/login/login_page.dart';

class TripSummaryDriver extends StatefulWidget {
  final HistoryModel ride;

  TripSummaryDriver({Key key, @required this.ride}) : super(key: key);
  @override
  _TripSummaryDriverState createState() => _TripSummaryDriverState();
}

class _TripSummaryDriverState extends State<TripSummaryDriver> {
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
      trailing: Text(timeConversion(time)),
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
                trailing: Text(timeConversion(widget.ride.rideInfo.fromTime)),
              ),
              // TODO: Additional Stop Points
              _addAcceptedPoint(
                  'Pick Up Sidhant', 'Sidhant, from location', '13:00'),
              _addAcceptedPoint(
                  'Pick Up Sandy', 'Sandy, from location', '14:00'),
              _addAcceptedPoint(
                  'Drop off Sidhant', 'Sidhant, to location', '15:00'),
              _addAcceptedPoint(
                  'Drop off Sandy', 'Sandy, to location', '01:00'),
              // Destination Location
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
                title: Text('Destination Location'),
                subtitle: Text(
                  '${widget.ride.rideInfo.to.name.split(',')[0]},${widget.ride.rideInfo.to.name.split(',')[1]}',
                ),
                trailing: Text(timeConversion(widget.ride.rideInfo.toTime)),
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
                    builder: (context) =>
                        DriveDetails(ride: widget.ride.rideInfo),
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
                // TODO: update route info in models
                '40 Kms',
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
      initialChildSize: 0.6,
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
