import 'package:flutter/material.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/login/login_page.dart';

class TripSummaryRider extends StatefulWidget {
  final HistoryModel ride;

  TripSummaryRider({Key key, @required this.ride}) : super(key: key);
  @override
  _TripSummaryRiderState createState() => _TripSummaryRiderState();
}

class _TripSummaryRiderState extends State<TripSummaryRider> {
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
        fit: BoxFit.fill,
        image: NetworkImage(widget.ride.rideInfo.vehicle.pic),
      )),
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
              fit: BoxFit.fill,
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
      'Passenger',
      widget.ride.rider.pic,
      Row(
        children: <Widget>[
          Text('You ', style: TextStyle(color: buttonColor)),
          Text('were passenger of the trip',
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
                  '${widget.ride.rideFrom.name.split(',')[0]},${widget.ride.rideFrom.name.split(',')[1]}',
                ),
                trailing: Text(timeConversion(widget.ride.rideFromTime)),
              ),
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
                  '${widget.ride.rideTo.name.split(',')[0]},${widget.ride.rideTo.name.split(',')[1]}',
                ),
                trailing: Text(timeConversion(widget.ride.rideToTime)),
              ),
            ],
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
                ? 'Upcoming ride'
                : 'Completed ride',
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
      title: Text(
        'Trip to ${widget.ride.rideTo.name}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
          '${widget.ride.rideInfo.driveDate.split('/')[0]} ${getMonthOfYear(widget.ride.rideInfo.driveDate)} ${widget.ride.rideInfo.driveDate.split('/')[2]}, ${timeConversion(widget.ride.rideFromTime)}'),
      trailing: Text(
        '${widget.ride.rideStatus}',
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
                '0 Kms',
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