import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/driver_home.dart';
import 'package:shared_transport/driver_pages/my_vehicle.dart';
import 'package:shared_transport/help_and_support.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/history_pages/my_trips.dart';
import 'package:shared_transport/policies.dart';
import 'package:shared_transport/profile.dart';
import 'package:shared_transport/verification/profile_verification.dart';
import 'package:shared_transport/rating/rating.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  var _photoUrl =
      'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
  var _name = 'John Don';
  var _email = 'example@email.com';
  var _phone = '0987654321';
  var _avgRating = 0.0;
  var _approveStatus = '0';

  @override
  void initState() {
    super.initState();
    setInitialValues();
  }

  setInitialValues() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _photoUrl = prefs.getString('photoUrl');
      _name = prefs.getString("name");
      _email = prefs.getString("email");
      _phone = prefs.getString("phone");
      _avgRating = prefs.getDouble("avgRating");
      _approveStatus = prefs.getString("approveStatus");

      if (_photoUrl == null)
        _photoUrl =
            'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
      if (_name == null) _name = 'Carl Aron';
      if (_email == null) _email = 'johnaron999@gmail.com';
      if (_phone == null) _phone = '0987654321';
    });
  }

  Widget _starFilling(double fill) {
    return fill >= 1.0
        ? Icon(
            Icons.star,
            color: Colors.white,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: Colors.white,
              )
            : Icon(
                Icons.star_border,
                color: Colors.white,
              );
  }

  @override
  Widget build(BuildContext context) {
    Widget ratingBar = InkWell(
      onTap: () => {
        Navigator.of(context).pop(),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RatingPage()),
        )
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
        child: Wrap(
          children: <Widget>[
            Text(
              _avgRating.toString(),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: _starFilling(_avgRating),
            ),
            _starFilling(_avgRating - 1.0),
            _starFilling(_avgRating - 2.0),
            _starFilling(_avgRating - 3.0),
            _starFilling(_avgRating - 4.0),
          ],
        ),
      ),
    );

    Widget profile = InkWell(
      onTap: () => {
        Navigator.of(context).pop(),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        )
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill, image: NetworkImage(_photoUrl))),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _name,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _email,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _phone,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget drawerHeader = Container(
      height: 173,
      child: DrawerHeader(
        child: Column(
          children: <Widget>[profile, ratingBar],
        ),
        decoration: BoxDecoration(
          color: mainColor,
        ),
      ),
    );

    return Drawer(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            drawerHeader,
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(const Radius.circular(100.0)),
                    color: mainColor,
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 15,
                  )),
              title: Text('My Trips'),
              onTap: () => {
                Navigator.of(context).pop(),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyTripsPage()),
                )
              },
            ),
            _approveStatus == '100'
                ? ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(const Radius.circular(100.0)),
                          color: mainColor,
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 15,
                        )),
                    title: Text('My Vehicles'),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VehiclePage()),
                      )
                    },
                  )
                : Container(),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(const Radius.circular(100.0)),
                    color: mainColor,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 15,
                  )),
              title: Text('Profile Verification'),
              onTap: () => {
                Navigator.of(context).pop(),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileVerificationPage()),
                )
              },
            ),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(const Radius.circular(100.0)),
                    color: mainColor,
                  ),
                  child: Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 15,
                  )),
              title: Text('Help and Support'),
              onTap: () => {
                Navigator.of(context).pop(),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpAndSupportPage()),
                )
              },
            ),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(const Radius.circular(100.0)),
                    color: mainColor,
                  ),
                  child: Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 15,
                  )),
              title: Text('Policies'),
              onTap: () => {
                Navigator.of(context).pop(),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoliciesPage()),
                )
              },
            ),
          ],
        ),
        bottomNavigationBar: _approveStatus == '100'
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: InkWell(
                  onTap: () => {
                    Navigator.of(context).pop(),
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DriverHome()),
                    )
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: buttonColor, width: 2),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(40.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Drive',
                        style: TextStyle(
                          color: buttonColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
            : Wrap(
                children: <Widget>[
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Text(
                        'To drive with us complete the verification process.'),
                  ),
                ],
              ),
      ),
    );
  }
}
