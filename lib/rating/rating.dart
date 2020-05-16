import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/models/models.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/widgets/empty_state.dart';
import 'package:shared_transport/rating/rating_form.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class RatingPage extends StatefulWidget {
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  List<RatingForm> users = [];
  var _isLoading = true;
  var _avgRating = 0.0;
  var _rating1 = 0.0;
  var _rating2 = 0.0;
  var _rating3 = 0.0;
  var _rating4 = 0.0;
  var _rating5 = 0.0;
  var _total = 0;

  @override
  void initState() {
    super.initState();
    _makeGetRequest();
    _setAvgRating();
  }

  _makeGetRequest() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    final response = await get(Keys.serverURL + 'profile/rating', headers: {
      'token': prefs.getString('token'),
      'email': prefs.getString('email'),
    });
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (prefs.containsKey('login')) {
        if (prefs.getBool('login')) {
          setState(() {
            jsonData['rating'].forEach((rating) => onAddForm(rating));
            _isLoading = false;
          });
        }
      }
    }
  }

  _setAvgRating() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var total = prefs.getInt("rating1") +
        prefs.getInt("rating2") +
        prefs.getInt("rating3") +
        prefs.getInt("rating4") +
        prefs.getInt("rating5");
    setState(() {
      _avgRating = prefs.getDouble("avgRating");
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
      title: Text(AppLocalizations.of(context).localisedText['rating']),
    );

    Widget _ratingBar(int stars, double percentage) {
      return SizedBox(
        height: 20,
        child: Row(
          children: <Widget>[
            Text(
              stars.toString(),
              style: TextStyle(color: Colors.black),
            ),
            SliderTheme(
              data: SliderTheme.of(context),
              child: Slider(
                min: 0,
                max: 1,
                value: percentage,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      );
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
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          children: <Widget>[
            _starFilling(rating),
            _starFilling(rating - 1.0),
            _starFilling(rating - 2.0),
            _starFilling(rating - 3.0),
            _starFilling(rating - 4.0),
          ],
        ),
      );
    }

    Widget createBody() {
      return Scaffold(
        appBar: appBar,
        body: Container(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor),
                  ),
                )
              : Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                        _avgRating.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                        ),
                                      ),
                                    ),
                                    _stars(_avgRating),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Icon(
                                              Icons.person,
                                              size: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _total.toString(),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                          ],
                        ),
                      ),
                    ),
                    users.length <= 0
                        ? Expanded(
                            child: Center(
                              child: EmptyState(
                                title: AppLocalizations.of(context)
                                    .localisedText['oops'],
                                message: AppLocalizations.of(context)
                                    .localisedText['no_ratings_yet'],
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              addAutomaticKeepAlives: true,
                              itemCount: users.length,
                              itemBuilder: (_, i) => users[i],
                            ),
                          ),
                  ],
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
  void onAddForm(data) {
    setState(() {
      var _rating = UserRating(
        email: data['email'],
        emailFrom: data['emailFrom'],
        date: data['date'],
        ratingComments: data['comments'],
        ratingStars: data['stars'],
      );
      users.add(RatingForm(user: _rating));
    });
  }
}
