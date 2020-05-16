import 'package:flutter/material.dart';
import 'package:shared_transport/ride_search/booking_card.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/utils/localizations.dart';

class BookingPage extends StatefulWidget {
  final ride;
  BookingPage({Key key, @required this.ride}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  RideModel drive;
  @override
  void initState() {
    super.initState();
    drive = widget.ride['ride'];
  }

  String getDayOfWeek(date) {
    int dNum = DateTime.utc(
      int.parse(drive.driveDate.split('/')[2]),
      int.parse(drive.driveDate.split('/')[1]),
      int.parse(drive.driveDate.split('/')[0]),
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
      int.parse(drive.driveDate.split('/')[2]),
      int.parse(drive.driveDate.split('/')[1]),
      int.parse(drive.driveDate.split('/')[0]),
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

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.elliptical(30, 20),
                bottomRight: Radius.elliptical(30, 20),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: 200.0,
          ),
          ListView(
            padding: const EdgeInsets.only(top: 20),
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  BookingCard(ride: widget.ride),
                  Positioned(
                    left: 50,
                    right: 50,
                    top: -20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.directions_car,
                        color: Theme.of(context).accentColor,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context).localisedText['book']),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
//          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }
}
