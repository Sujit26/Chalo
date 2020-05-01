import 'package:flutter/material.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/bottom_navigation.dart';

class DriveDetails extends StatefulWidget {
  final RideModel ride;

  DriveDetails({Key key, @required this.ride}) : super(key: key);
  @override
  _DriveDetailsState createState() => _DriveDetailsState();
}

class _DriveDetailsState extends State<DriveDetails> {
  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(widget.ride.driveDate.split('/')[2]),
      int.parse(widget.ride.driveDate.split('/')[1]),
      int.parse(widget.ride.driveDate.split('/')[0]),
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
      int.parse(widget.ride.driveDate.split('/')[2]),
      int.parse(widget.ride.driveDate.split('/')[1]),
      int.parse(widget.ride.driveDate.split('/')[0]),
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
        image: NetworkImage(widget.ride.vehicle.pic),
      )),
    );
  }

  showSeats() {
    List<Widget> seats = List();
    for (var i = 0; i < widget.ride.vehicle.seats - widget.ride.slots; i++)
      seats.add(Icon(Icons.person, color: buttonColor, size: 18));
    for (var i = 0; i < widget.ride.slots; i++)
      seats.add(Icon(Icons.person_outline, color: buttonColor, size: 18));

    return Row(
      children: seats,
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
          title: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              Text(
                "10 April ",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "5:00 pm",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Text(
            "Trip to driver's destination",
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
              },
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'SOS',
                style: TextStyle(
                  color: buttonColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget appBar1 = Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 30, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
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
                      '${widget.ride.vehicle.name} ${widget.ride.vehicle.modelName}',
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
                      '${widget.ride.vehicle.number}',
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

    Widget _routeInfo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 20,
            left: 27,
            child: Container(
              width: 7,
              height: 230,
              color: buttonColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                  '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
                ),
                trailing: Text(
                  TimeOfDay(
                    hour: int.parse(widget.ride.fromTime.split(':')[0]),
                    minute: int.parse(widget.ride.fromTime.split(':')[1]),
                  ).format(context),
                ),
              ),
              ListTile(
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
                title: Text('Source Location'),
                subtitle: Text(
                  '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
                ),
                trailing: Text(
                  TimeOfDay(
                    hour: int.parse(widget.ride.fromTime.split(':')[0]),
                    minute: int.parse(widget.ride.fromTime.split(':')[1]),
                  ).format(context),
                ),
              ),
              ListTile(
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
                title: Text('Source Location'),
                subtitle: Text(
                  '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
                ),
                trailing: Text(
                  TimeOfDay(
                    hour: int.parse(widget.ride.fromTime.split(':')[0]),
                    minute: int.parse(widget.ride.fromTime.split(':')[1]),
                  ).format(context),
                ),
              ),
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
                  '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
                ),
                trailing: Text(
                  TimeOfDay(
                    hour: int.parse(widget.ride.fromTime.split(':')[0]),
                    minute: int.parse(widget.ride.fromTime.split(':')[1]),
                  ).format(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget _userInfo = ListTile(
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
                'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'Sidhant Jain',
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Row(
        children: <Widget>[
          _starFilling(4.5),
          _starFilling(4.5 - 1),
          _starFilling(4.5 - 2),
          _starFilling(4.5 - 3),
          _starFilling(4.5 - 4),
        ],
      ),
      trailing: Wrap(
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
      ),
    );

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
                        color: buttonColor,
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
                        _routeInfo,
                        Divider(),
                        _userInfo,
                        Divider(),
                        _userInfo,
                        Divider(),
                        _userInfo,
                        Divider(),
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
