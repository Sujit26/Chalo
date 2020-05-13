import 'package:flutter/material.dart';
import 'package:shared_transport/ride_search/booking_card.dart';
import 'package:shared_transport/models/models.dart';

class BookingPage extends StatefulWidget {
  final String name = 'Book';
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
      return SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              color: Theme.of(context).backgroundColor,
              height: 700,
            ),
            Container(
              color: Theme.of(context).accentColor,
              width: MediaQuery.of(context).size.width,
              height: 200.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          drive.from.name.split(',')[0],
                          style: TextStyle(color: Colors.white, fontSize: 22.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.white),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          drive.to.name.split(',')[0],
                          style: TextStyle(color: Colors.white, fontSize: 22.0),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            drive.driveDate.split('/')[0],
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          Text(
                            drive.driveDate.split('/')[0] == '01'
                                ? 'st'
                                : drive.driveDate.split('/')[0] == '02'
                                    ? 'nd'
                                    : drive.driveDate.split('/')[0] == '03'
                                        ? 'rd'
                                        : 'th',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${getMonthOfYear(drive.driveDate)}, ${getDayOfWeek(drive.driveDate)}',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100.0,
              left: 0.0,
              right: 0.0,
              child: BookingCard(ride: widget.ride),
            ),
            Positioned(
              left: 50,
              right: 50,
              top: 90,
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.name),
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
