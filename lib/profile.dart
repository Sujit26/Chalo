import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/driver_pages/my_vehicle.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/profile_edit.dart';
import 'package:shared_transport/rating/rating.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/verification/profile_verification.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _photoUrl =
      'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
  var _name = '';
  var _email = '';
  var _approveStatus = '0';
  List<Vehicle> vehicles = [];

  var _avgRating = 0.0;
  var _rating1 = 0.0;
  var _rating2 = 0.0;
  var _rating3 = 0.0;
  var _rating4 = 0.0;
  var _rating5 = 0.0;
  var _total = 0;
  String language = 'English';

  @override
  void initState() {
    super.initState();
    setInitialValues();
    _getVehicleData();
  }

  setInitialValues() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    var total = prefs.getInt("rating1") +
        prefs.getInt("rating2") +
        prefs.getInt("rating3") +
        prefs.getInt("rating4") +
        prefs.getInt("rating5");

    AppLocalizations.of(context)
        .getLanguage()
        .then((onValue) => setState(() => language = onValue));

    setState(() {
      _photoUrl = prefs.getString('photoUrl') == null
          ? 'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'
          : prefs.getString('photoUrl');
      _name = prefs.getString("name");
      _email = prefs.getString("email");
      _approveStatus = prefs.getString('approveStatus');

      _avgRating = prefs.getDouble('avgRating');
      _rating1 =
          (prefs.getInt("rating1") / (total == 0 ? 1 : total)).toDouble();
      _rating2 =
          (prefs.getInt("rating2") / (total == 0 ? 1 : total)).toDouble();
      _rating3 =
          (prefs.getInt("rating3") / (total == 0 ? 1 : total)).toDouble();
      _rating4 =
          (prefs.getInt("rating4") / (total == 0 ? 1 : total)).toDouble();
      _rating5 =
          (prefs.getInt("rating5") / (total == 0 ? 1 : total)).toDouble();
      _total = total;
    });
  }

  _getVehicleData() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    if (prefs.getString('approveStatus') == '100') {
      final response = await get(Keys.serverURL + 'driver/vehicle', headers: {
        'token': prefs.getString('token'),
        'email': prefs.getString('email'),
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          jsonData['vehicles'].forEach(
            (vehicle) => vehicles.add(
              Vehicle(
                name: vehicle['name'],
                modelName: vehicle['modelName'],
                seats: vehicle['seats'],
                number: vehicle['number'],
                pic: vehicle['pic'],
                type: vehicle['type'],
                index: vehicles.length,
              ),
            ),
          );
        });
      }
    }
  }

  Widget _starFilling(double fill) {
    return fill >= 1.0
        ? Icon(
            Icons.star,
            color: Theme.of(context).accentColor,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: Theme.of(context).accentColor,
              )
            : Icon(
                Icons.star_border,
                color: Theme.of(context).accentColor,
              );
  }

  Widget _stars(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _starFilling(rating),
        _starFilling(rating - 1.0),
        _starFilling(rating - 2.0),
        _starFilling(rating - 3.0),
        _starFilling(rating - 4.0),
      ],
    );
  }

  Widget _ratingBar(int stars, double percentage) {
    return SizedBox(
      height: 20,
      child: Row(
        children: <Widget>[
          Text(
            stars.toString(),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
            child: SliderTheme(
              data: SliderTheme.of(context),
              child: Slider(
                min: 0,
                max: 1,
                value: percentage,
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleBox() {
    List<Widget> listVehicels = vehicles.length > 0
        ? vehicles
            .map(
              (vehicle) => ListTile(
                leading: Material(
                  elevation: 2,
                  color: Theme.of(context).accentColor,
                  shape: CircleBorder(
                      side: BorderSide(
                          color: Theme.of(context).accentColor, width: 2)),
                  clipBehavior: Clip.antiAlias,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(vehicle.pic),
                    backgroundColor: Colors.white,
                    radius: 30,
                  ),
                ),
                title: Text(vehicle.name),
                subtitle: Text(vehicle.modelName),
              ),
            )
            .toList()
        : <Widget>[];
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: MaterialButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (build) => VehiclePage()),
          );
        },
        elevation: 0,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
                title: Text(
                  AppLocalizations.of(context).localisedText['vehicles'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.directions_car,
                  color: Theme.of(context).accentColor,
                  size: 30,
                )),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.black12,
            ),
            Wrap(children: listVehicels),
          ],
        ),
      ),
    );
  }

  Widget _ratingBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: MaterialButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (build) => RatingPage()),
          );
        },
        elevation: 0,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: AbsorbPointer(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  AppLocalizations.of(context).localisedText['rating'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.thumb_up,
                  color: Theme.of(context).accentColor,
                  size: 30,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _avgRating.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          ),
                          _stars(_avgRating),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                Text(
                                  ' ${_total.toString()}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        _ratingBar(5, _rating5),
                        _ratingBar(4, _rating4),
                        _ratingBar(3, _rating3),
                        _ratingBar(2, _rating2),
                        _ratingBar(1, _rating1),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verificationBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: MaterialButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (build) => ProfileVerificationPage()),
          );
        },
        elevation: 0,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: double.parse(_approveStatus) / 100,
                strokeWidth: 3,
                backgroundColor: double.parse(_approveStatus) / 100 == 0
                    ? Theme.of(context).backgroundColor
                    : Colors.white,
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .localisedText['your_profile_is']),
                  TextSpan(
                    text: '$_approveStatus%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .localisedText['complete']),
                ],
              ),
            ),
            trailing: Text(
              AppLocalizations.of(context).localisedText['finish'],
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: MaterialButton(
        onPressed: () {},
        elevation: 0,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            onTap: () => AppLocalizations.of(context)
                .changeLocale()
                .then((onValue) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      ModalRoute.withName(''),
                    )),
            title: Text(
              AppLocalizations.of(context).localisedText['language'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .localisedText[language.toLowerCase()],
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                ),
                Icon(Icons.navigate_next),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(30, 20),
                  bottomRight: Radius.elliptical(30, 20),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 20),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    child: Container(
                      width: 250,
                      height: 300,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(_photoUrl),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  _name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 28,
                                  ),
                                ),
                                Text(
                                  _email,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                                _stars(_avgRating),
                                Spacer(),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (build) => ProfileEditPage(),
                                      ),
                                    );
                                  },
                                  color: Theme.of(context).accentColor,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(AppLocalizations.of(context)
                                      .localisedText['edit']),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              icon: Icon(
                                Icons.exit_to_app,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () =>
                                  _settingModalBottomSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _approveStatus != '100' ? _verificationBox() : Container(),
                _ratingBox(),
                _approveStatus == '100' ? _vehicleBox() : Container(),
                _languageBox(),
              ],
            ),
          ],
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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text(
                      AppLocalizations.of(context).localisedText['logout'],
                      style: TextStyle(color: Colors.red)),
                  onTap: () => {
                    logout(),
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                      ModalRoute.withName(''),
                    ),
                  },
                ),
              ],
            ),
          );
        });
  }

  logout() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    prefs.setBool('login', false);
    // To logout with google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
  }
}
