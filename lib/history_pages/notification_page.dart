import 'package:flutter/material.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/history_pages/ride_request.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/loacation.dart';

class NotificationPage extends StatefulWidget {
  final HistoryModel history = HistoryModel(
    action: 'Driving',
    rideInfo: RideModel(
      type: 'ride',
      fromTime: "12:00",
      toTime: "02:00",
      from: Location("Driver, from location", 32.132254, 75.707455),
      to: Location("Driver, to location", 22.72056, 75.84722),
      driveDate: "11/10/2020",
      dId: "asd324424@gmail.com_0",
      vehicle: Vehicle(
        name: 'Audi',
        modelName: 'A6',
        seats: 4,
        number: 'MP45AB1234',
        pic:
            'https://pictures.topspeed.com/IMG/crop/201706/audi-a5-cabriolet-dr_1600x0w.jpg',
        type: 'Sedan',
        index: 0,
      ),
      driver: User(
        name: 'Sidhant Jain',
        email: 'sidhantjain456@gmail.com',
        rating: 5.0,
        pic:
            'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
        nod: 5,
      ),
      slots: 3,
    ),
    requestFromRiders: [],
    acceptedRiders: [
      User(
        name: 'Request Rider 1',
        email: 'request_rider_1@gmail.com',
        rating: 5.0,
        pic:
            'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
      ),
      User(
        name: 'Accepted Rider 1',
        email: 'accepted_rider_1@gmail.com',
        rating: 5.0,
        pic:
            'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
        phone: '8989145987',
      ),
    ],
  );
  final name = 'Notifications';

  NotificationPage({Key key}) : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  showSeats() {
    List<Widget> seats = List();
    for (var i = 0; i < widget.history.rideInfo.slots; i++)
      seats.add(Icon(Icons.person, color: buttonColor, size: 12));

    return Row(
      children: seats,
    );
  }

  Widget _notification() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Material(
        color: Colors.white,
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (build) => RideRequest(ride: widget.history.rideInfo),
              ),
            );
          },
          child: Column(
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: Material(
                  shape: CircleBorder(),
                  elevation: 5,
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: 80,
                    height: 80,
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
                title: Text('Sidhant Jain'),
                subtitle: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 10,
                      left: 3.5,
                      child: Container(
                        width: 2,
                        height: 20,
                        color: buttonColor,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Material(
                              elevation: 3,
                              shape: CircleBorder(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: buttonColor),
                                ),
                                child: Icon(
                                  Icons.fiber_manual_record,
                                  size: 5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Riders from location',
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Material(
                                elevation: 3,
                                shape: CircleBorder(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: buttonColor),
                                  ),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    size: 5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Riders to location',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      '4.5',
                      style: TextStyle(
                        color: buttonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      Icons.star,
                      size: 22,
                      color: buttonColor,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        Icon(
                          Icons.calendar_today,
                          color: buttonColor,
                          size: 12,
                        ),
                        Text(
                          ' 30/04/2020',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        Container(
                          color: Colors.black45,
                          height: 20,
                          width: 1,
                        ),
                        Spacer(),
                        showSeats(),
                        Text(
                          ' Seats',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      'Accept',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 2,
      titleSpacing: 0,
      title: Text(
        widget.name,
        style: TextStyle(fontSize: 25.0),
      ),
      backgroundColor: buttonColor,
    );
    
    Widget body = ListView(
      children: <Widget>[
        _notification(),
        _notification(),
        _notification(),
        _notification(),
        _notification(),
        _notification(),
        _notification(),
        _notification(),
      ],
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: body,
        ),
      ),
    );
  }
}
