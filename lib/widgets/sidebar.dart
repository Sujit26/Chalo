import 'package:flutter/material.dart';
import 'package:shared_transport/help_and_support.dart';
import 'package:shared_transport/login_page.dart';
import 'package:shared_transport/my_trips.dart';
import 'package:shared_transport/policies.dart';
import 'package:shared_transport/profile.dart';
import 'package:shared_transport/profile_verification.dart';
import 'package:shared_transport/rating.dart';

class NavDrawer extends StatelessWidget {
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
              '4.5',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Icon(
                Icons.star,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.star,
              color: Colors.white,
            ),
            Icon(
              Icons.star,
              color: Colors.white,
            ),
            Icon(
              Icons.star,
              color: Colors.white,
            ),
            Icon(
              Icons.star_half,
              color: Colors.white,
            ),
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
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'))),
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
                      'Carl Aron',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      'johnaron999@gmail.com',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      '0987654321',
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: InkWell(
            onTap: () {
              print('Facebook Clicked');
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: buttonColor, width: 2),
                  borderRadius: BorderRadius.all(const Radius.circular(40.0))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Driver',
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
        ),
      ),
    );
  }
}
