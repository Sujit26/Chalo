import 'package:flutter/material.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/history_pages/history_card.dart';
import 'package:shared_transport/history_pages/history_model.dart';
import 'package:shared_transport/history_pages/notification_page.dart';
import 'package:shared_transport/history_pages/trip_summary_driver.dart';
import 'package:shared_transport/history_pages/trip_summary_rider.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/empty_state.dart';
import 'package:shared_transport/widgets/loacation.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class MyTripsPage extends StatefulWidget {
  final String name = 'My Trips';
  final Color color = mainColor;

  @override
  _MyTripsPageState createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  List<HistoryCard> completedList = [];
  List<HistoryCard> cancelledList = [];
  List<Widget> upcomingList = [];

  Widget build(BuildContext context) {
    final completedRide = Scaffold(
      body: Container(
        color: borderColor,
        child: completedList.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: completedList.length,
                itemBuilder: (_, i) => completedList[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addCompletedRide,
        foregroundColor: Colors.white,
      ),
    );
    final upcomingRide = Scaffold(
      body: Container(
        color: borderColor,
        child: upcomingList.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: upcomingList.length,
                itemBuilder: (_, i) => upcomingList[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addUpcomingRide,
        foregroundColor: Colors.white,
      ),
    );
    final cancelledRide = Scaffold(
      body: Container(
        color: borderColor,
        child: cancelledList.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: cancelledList.length,
                itemBuilder: (_, i) => cancelledList[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addCancelledRide,
        foregroundColor: Colors.white,
      ),
    );

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.notifications_none),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (build) => NotificationPage(),
                      ),
                    );
                  },
                )
              ],
              title: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black38,
                indicator: CircleTabIndicator(color: buttonColor, radius: 3),
                tabs: <Widget>[
                  Tab(text: 'COMPLETED'),
                  Tab(text: 'UPCOMING'),
                  Tab(text: 'CANCELLED'),
                ],
              ),
              centerTitle: true,
              backgroundColor: mainColor,
            ),
            body: Container(
              color: bgColor,
              child: TabBarView(
                children: [
                  completedRide,
                  upcomingRide,
                  cancelledRide,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }

  ///on add form
  addCompletedRide() {
    print('addCompletedRide');
    // setState(() {
    //   var _user = HistoryModel(
    //     type: 'ride',
    //     action: 'Driving',
    //     fromTime: "12:00",
    //     toTime: "02:00",
    //     from: Location("Jhabua, Madhaya Pradesh, India", 32.132254, 75.707455),
    //     to: Location("Indore, Himachal Pradesh, India", 22.72056, 75.84722),
    //     driveDate: "11/10/2020",
    //     dId: "asd324424@gmail.com_0",
    //     vehicle: Vehicle(
    //         name: 'Audi',
    //         modelName: 'A6',
    //         seats: 4,
    //         number: 'MP45AB1234',
    //         pic:
    //             'https://pictures.topspeed.com/IMG/crop/201706/audi-a5-cabriolet-dr_1600x0w.jpg',
    //         type: 'Sedan',
    //         index: 0),
    //     slots: 1,
    //     requestFromRiders: [
    //       User(
    //         name: 'Request Rider 1',
    //         email: 'request_rider_1@gmail.com',
    //         rating: 5.0,
    //         pic:
    //             'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
    //       ),
    //     ],
    //     acceptedRiders: [
    //       User(
    //         name: 'Accepted Rider 1',
    //         email: 'accepted_rider_1@gmail.com',
    //         rating: 5.0,
    //         pic:
    //             'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
    //         phone: '8989145987',
    //       ),
    //       User(
    //         name: 'Request Rider 1',
    //         email: 'request_rider_1@gmail.com',
    //         rating: 5.0,
    //         pic:
    //             'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
    //       ),
    //     ],
    //   );
    //   completedList.add(HistoryCard(ride: _user));
    // });
  }

  addCancelledRide() {
    setState(() {
      var _history = HistoryModel(
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
      cancelledList.add(HistoryCard(history: _history));
    });
  }

  addUpcomingRide() {
    setState(() {
      var _history = HistoryModel(
        action: 'Riding',
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
            phone: '0987654321',
          ),
          slots: 3,
        ),
        rider: User(
          name: 'Sidhant Jain',
          email: 'sidhantjain456@gmail.com',
          rating: 5.0,
          pic:
              'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
          nod: 5,
          phone: '0987654321',
        ),
        rideFrom: Location("Rider, from Location", 32.132254, 75.707455),
        rideTo: Location("Rider, to Location", 32.132254, 75.707455),
        rideFromTime: "12:00",
        rideToTime: "02:00",
        rideSlots: 2,
        rideStatus: 'Accepted',
      );
      upcomingList.add(
        GestureDetector(
          // onLongPressStart: (details) async {
          //   final RenderBox referenceBox = context.findRenderObject();
          //   Offset _tapPosition =
          //       referenceBox.globalToLocal(details.globalPosition);
          //   final RelativeRect position = RelativeRect.fromLTRB(
          //       _tapPosition.dx, _tapPosition.dy, _tapPosition.dx, 0);

          //   final result = await showMenu(
          //     context: context,
          //     position: position,
          //     items: <PopupMenuItem<String>>[
          //       const PopupMenuItem<String>(
          //           child: Text('test1'), value: 'test1'),
          //       const PopupMenuItem<String>(
          //           child: Text('test2'), value: 'test2'),
          //     ],
          //   );
          // },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _history.action == 'Driving'
                    ? TripSummaryDriver(ride: _history)
                    : TripSummaryRider(ride: _history),
              ),
            );
          },
          child: HistoryCard(history: _history),
        ),
      );

      var _history1 = HistoryModel(
        action: 'Driving',
        rideInfo: RideModel(
          type: 'ride',
          fromTime: "12:00",
          toTime: "02:00",
          from: Location("Jhabua, Madhya Pradesh", 32.132254, 75.707455),
          to: Location("Indore, Madhya Pradesh", 22.72056, 75.84722),
          driveDate: "01/06/2020",
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
          slots: 1,
        ),
        requestFromRiders: [],
        acceptedRiders: [
          User(
            name: 'Manoj Jain',
            email: 'request_rider_1@gmail.com',
            rating: 5.0,
            pic:
                'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
            phone: '9425413535',
          ),
          User(
            name: 'Shweta Jain',
            email: 'accepted_rider_1@gmail.com',
            rating: 5.0,
            pic:
                'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80  ',
            phone: '8989145987',
          ),
        ],
      );
      upcomingList.add(
        GestureDetector(
          // onLongPressStart: (details) async {
          //   final RenderBox referenceBox = context.findRenderObject();
          //   Offset _tapPosition =
          //       referenceBox.globalToLocal(details.globalPosition);
          //   final RelativeRect position = RelativeRect.fromLTRB(
          //       _tapPosition.dx, _tapPosition.dy, _tapPosition.dx, 0);

          //   final result = await showMenu(
          //     context: context,
          //     position: position,
          //     items: <PopupMenuItem<String>>[
          //       const PopupMenuItem<String>(
          //           child: Text('test1'), value: 'test1'),
          //       const PopupMenuItem<String>(
          //           child: Text('test2'), value: 'test2'),
          //     ],
          //   );
          // },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _history1.action == 'Driving'
                    ? TripSummaryDriver(ride: _history1)
                    : TripSummaryRider(ride: _history1),
              ),
            );
          },
          child: HistoryCard(history: _history1),
        ),
      );
    });
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius * 3);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
