import 'package:flutter/material.dart';
import 'package:shared_transport/rating_info.dart';
import 'package:shared_transport/form.dart';
import 'package:shared_transport/login_page.dart';
import 'package:shared_transport/empty_state.dart';

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
  List<UserForm> users1 = []; // Current ride detail
  List<UserForm> users2 = []; // past ride details
  List<UserForm> users3 = []; // Upcoming ride detail

  Widget build(BuildContext context) {
    final currentRide = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0x708690),
              Color(0xFF2AA7DC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: users1.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: users1.length,
                itemBuilder: (_, i) => users1[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addCurrentRide,
        foregroundColor: Colors.white,
      ),
    );
    final previousRide = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0x708690),
              Color(0xFF2AA7DC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: users2.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: users2.length,
                itemBuilder: (_, i) => users2[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addPastRide,
        foregroundColor: Colors.white,
      ),
    );
    final upcomingRide = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0x708690),
              Color(0xFF2AA7DC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: users3.length <= 0
            ? Center(
                child: EmptyState(
                  title: 'Oops',
                  message: 'Add Ride by tapping add button below',
                ),
              )
            : ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: users3.length,
                itemBuilder: (_, i) => users3[i],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addUpcomingRide,
        foregroundColor: Colors.white,
      ),
    );

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.black38,
                labelColor: Colors.black38,
                unselectedLabelColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                    text: 'Current Ride',
                  ),
                  Tab(
                    text: 'Past Rides',
                  ),
                  Tab(
                    text: 'Upcoming Ride',
                  ),
                ],
              ),
              centerTitle: true,
              backgroundColor: mainColor,
            ),
            body: Container(
              color: bgColor,
              child: TabBarView(
                children: [
                  currentRide,
                  previousRide,
                  upcomingRide,
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

//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        onPressed: onAddForm,
//        foregroundColor: Colors.white,
//      ),
    );
  }

  ///on form user deleted
  onDelete(UserRating _user) {
//    setState(() {
//      var find = users1.firstWhere(
//            (it) => it.user == _user,
//        orElse: () => null,
//      );
//      if (find != null) users1.removeAt(users1.indexOf(find));
//    });
  }

  ///on add form
  addCurrentRide() {
    print('Add Form');
    setState(() {
      var _user = new UserRating(email: '', emailFrom: '', date: '', ratingComments: '', ratingStars: '');
      users1.add(UserForm(
        user: _user,
//        onDelete: () => onDelete(_user),
      ));
    });
  }

  addPastRide() {
    print('Add Form');
    setState(() {
      var _user = new UserRating(email: '', emailFrom: '', date: '', ratingComments: '', ratingStars: '');
      users2.add(UserForm(
        user: _user,
//        onDelete: () => onDelete(_user),
      ));
    });
  }

  addUpcomingRide() {
    print('Add Form');
    setState(() {
      var _user = new UserRating(email: '', emailFrom: '', date: '', ratingComments: '', ratingStars: '');
      users3.add(UserForm(
        user: _user,
//        onDelete: () => onDelete(_user),
      ));
    });
  }

  ///on save forms
  onSave() {
    print("ON_SAVE");
//    if (users.length >= 0) {
////      var allValid = true;
////      if (allValid) {
////        var data = users.map((it) => it.user).toList();
////        Navigator.push(
////          context,
////          MaterialPageRoute(
////            fullscreenDialog: true,
////            builder: (_) => Scaffold(
////              appBar: AppBar(
////                title: Text('List of Users'),
////              ),
////              body: ListView.builder(
////                itemCount: data.length,
////                itemBuilder: (_, i) => ListTile(
////                  leading: CircleAvatar(
////                    child: Text(data[i].From.substring(0, 1)),
////                  ),
////                  title: Text(data[i].From),
////                  subtitle: Text(data[i].To + data[i].Date),
////
////                ),
////              ),
////            ),
////          ),
////        );
////      }
//    }
  }
}
