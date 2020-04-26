import 'package:flutter/material.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'dart:math' as math;

import 'package:shared_transport/widgets/custom_dialog.dart';

class BookingCard extends StatefulWidget {
  final RideModel ride;

  BookingCard({Key key, @required this.ride})
      : super(key: key);
  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  int bookSeats = 1;

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
            size: 15,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: buttonColor,
                size: 15,
              )
            : Icon(
                Icons.star_border,
                color: buttonColor,
                size: 15,
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

  Widget build(BuildContext context) {
    Widget _carName = Center(
      child: Column(
        children: <Widget>[
          Text(
            '${widget.ride.vehicle.name} ${widget.ride.vehicle.modelName}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('${widget.ride.slots} Seats'),
        ],
      ),
    );

    Widget _driverInfo = Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(widget.ride.driver.pic),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    widget.ride.driver.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 15,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  _starFilling(widget.ride.driver.rating),
                  _starFilling(widget.ride.driver.rating - 1),
                  _starFilling(widget.ride.driver.rating - 2),
                  _starFilling(widget.ride.driver.rating - 3),
                  _starFilling(widget.ride.driver.rating - 4),
                ],
              ),
            ],
          ),
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(width: .8, color: buttonColor),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${widget.ride.driver.nod} Rides',
            style: TextStyle(color: buttonColor),
          ),
        )
      ],
    );

    Widget _carInfo = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.ride.vehicle.number,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.ride.vehicle.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      ' ${widget.ride.vehicle.modelName}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              showSeats(),
            ],
          ),
        ),
        Expanded(
          child: showCarPic(),
        ),
      ],
    );

    Widget _routeInfo = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pickup',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drop',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'End',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fiber_manual_record,
              color: buttonColor.withOpacity(.3),
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: buttonColor.withOpacity(.3),
                size: 15,
              ),
            ),
            Icon(
              Icons.fiber_manual_record,
              color: buttonColor,
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: buttonColor.withAlpha(150),
                size: 15,
              ),
            ),
            Icon(
              Icons.location_on,
              color: mainColor,
              size: 15,
            ),
            Transform.rotate(
              angle: 90 * math.pi / 180,
              child: Icon(
                Icons.linear_scale,
                color: mainColor.withOpacity(.3),
                size: 15,
              ),
            ),
            Icon(
              Icons.location_on,
              color: mainColor.withOpacity(.5),
              size: 15,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(widget.ride.fromTime.split(':')[0]),
                      minute: int.parse(widget.ride.fromTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(widget.ride.fromTime.split(':')[0]) + 1,
                      minute: int.parse(widget.ride.fromTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(widget.ride.toTime.split(':')[0]) - 1,
                      minute: int.parse(widget.ride.toTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay(
                      hour: int.parse(widget.ride.toTime.split(':')[0]),
                      minute: int.parse(widget.ride.toTime.split(':')[1]),
                    ).format(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              children: <Widget>[
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
                  ),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text('Rider\'s from Location'),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rider\'s To Loaction',
                  ),
                ),
                Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Text(
                      '${widget.ride.to.name.split(',')[0]},${widget.ride.to.name.split(',')[1]}'),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget _seats = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: buttonColor.withAlpha(150)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MaterialButton(
            onPressed: () {
              setState(() {
                if (bookSeats < widget.ride.slots)
                  bookSeats++;
                else {
                  final scaffold = Scaffold.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      backgroundColor: mainColor,
                      content: const Text(
                        'Maximum seats selected.',
                      ),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }
              });
            },
            color: buttonColor,
            textColor: Colors.white,
            child: Icon(
              Icons.add,
            ),
            shape: CircleBorder(),
          ),
          Text(
            '$bookSeats Seats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MaterialButton(
            onPressed: () {
              setState(() {
                if (bookSeats > 1)
                  bookSeats--;
                else {
                  final scaffold = Scaffold.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      backgroundColor: mainColor,
                      content: const Text(
                        'Minmum seats selected.',
                      ),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }
              });
            },
            color: buttonColor,
            textColor: Colors.white,
            child: Icon(
              Icons.remove,
            ),
            shape: CircleBorder(),
          ),
        ],
      ),
    );

    Widget _submitButton = Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            color: buttonColor,
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => CustomDialog(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: buttonColor),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.done,
                      size: 40,
                      color: buttonColor,
                    ),
                  ),
                  title: 'Awesome',
                  description:
                      'Thank you choosing us.\n\nYou will be provided with drivers contact detail as soon as your ride accepts.',
                  buttons: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: buttonColor, fontSize: 20),
                    ),
                  ),
                ),
              );
            },
            child: Text(
              'CONFIRM REQUEST',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 560,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          color: Colors.white,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                _carName,
                Spacer(),
                _driverInfo,
                Divider(),
                Spacer(),
                _carInfo,
                Divider(),
                Spacer(),
                _routeInfo,
                Divider(),
                Spacer(),
                _seats,
                Spacer(),
                _submitButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
