import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_transport/loacation.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/ride_search/search_result.dart';
import 'package:shared_transport/widgets/sidebar.dart';
import 'package:http/http.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class RiderHome extends StatefulWidget {
  final String name = 'Request Ride';

  @override
  _RiderHomeState createState() => _RiderHomeState();
}

const kGoogleApiKey = "AIzaSyBRhGd5iTPn7gs0OjQ3CXjwiXVZaLDuInk";

class _RiderHomeState extends State<RiderHome> {
  var _isLoading = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  // Location Suggestions
  List<Location> suggestions = [];
  GlobalKey<AutoCompleteTextFieldState<Location>> _rideFromKey =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Location>> _rideToKey = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Location>> _goodsFromKey =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Location>> _goodsToKey = new GlobalKey();
  // Fields Controllers
  TextEditingController _rideFromController = new TextEditingController();
  TextEditingController _rideToController = new TextEditingController();
  TextEditingController _goodsFromController = new TextEditingController();
  TextEditingController _goodsToController = new TextEditingController();
  TextEditingController _rideDateController = new TextEditingController();
  TextEditingController _goodsDateController = new TextEditingController();
  // Field Data
  Location _rideFromLocation;
  Location _rideToLocation;
  Location _goodsFromLocation;
  Location _goodsToLocation;
  // Date
  DateTime rideSelectedDate = DateTime.now();
  DateTime goodsSelectedDate = DateTime.now();

  var _rideValidationError = false;
  var _goodsValidationError = false;

  getSuggestions(String val) async {
    suggestions.clear();
    if (val.isEmpty) return;
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    // TODO: Bias the response to favor results that are closer to this location.
    var proximity = 'latitude,longitude';
    var url =
        'http://api.mapbox.com/geocoding/v5/mapbox.places/$val.json?access_token=$accessToken&language=en&country=in&types=place';
    var placesSearch = await get(url);
    var places = jsonDecode(placesSearch.body)['features'];
    setState(() {
      places.forEach((prediction) => {
            suggestions.add(Location(prediction['place_name'],
                prediction['center'][1], prediction['center'][0])),
          });
    });
  }

  Widget suggestionItemBuilder(BuildContext context, Location suggestion) {
    return Padding(
        child: ListTile(title: Text(suggestion.name)),
        padding: EdgeInsets.all(8.0));
  }

  bool suggestionFilter(Location suggestion, String query) {
    return suggestion.name.toLowerCase().startsWith(query.toLowerCase());
  }

  int suggestionSorter(Location a, Location b) {
    return a.name.compareTo(b.name);
  }

  @override
  Widget build(BuildContext context) {
    Future<Null> _selectDate(BuildContext context, String val) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: val == 'ride' ? rideSelectedDate : goodsSelectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime(2101),
      );
      if (picked != null)
        setState(() {
          if (val == 'ride') {
            _rideDateController.text =
                '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
            rideSelectedDate = picked;
          } else {
            _goodsDateController.text =
                '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
            goodsSelectedDate = picked;
          }
        });
    }

    final ride = Container(
        child: ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: AutoCompleteTextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.place),
                    filled: true,
                    fillColor: bgColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'From',
                    // errorText: _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.text,
                  key: _rideFromKey,
                  controller: _rideFromController,
                  suggestions: suggestions,
                  textChanged: (String val) {
                    setState(() {
                      _rideFromLocation = null;
                    });
                    getSuggestions(val);
                  },
                  itemBuilder: suggestionItemBuilder,
                  itemFilter: suggestionFilter,
                  itemSorter: suggestionSorter,
                  itemSubmitted: (Location data) {
                    setState(() {
                      _rideFromController.text = data.name;
                      _rideFromLocation = data;
                    });
                  },
                  clearOnSubmit: false,
                ),
              ),
              _rideValidationError && _validFrom('ride') != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(33.0, 0.0, 20.0, 10.0),
                      child: Text(
                        _rideValidationError ? _validFrom('ride') : '',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ))
                  : Container(),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                child: AutoCompleteTextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.place),
                    filled: true,
                    fillColor: bgColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),

                    labelText: 'To',
                    // errorText: _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.text,
                  key: _rideToKey,
                  controller: _rideToController,
                  suggestions: suggestions,
                  textChanged: (String val) {
                    setState(() {
                      _rideToLocation = null;
                    });
                    getSuggestions(val);
                  },
                  itemBuilder: suggestionItemBuilder,
                  itemFilter: suggestionFilter,
                  itemSorter: suggestionSorter,
                  itemSubmitted: (Location data) {
                    setState(() {
                      _rideToController.text = data.name;
                      _rideToLocation = data;
                    });
                  },
                  clearOnSubmit: false,
                ),
              ),
              _rideValidationError && _validTo('ride') != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(33.0, 0.0, 20.0, 10.0),
                      child: Text(
                        _rideValidationError ? _validTo('ride') : '',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ))
                  : Container(),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: TextField(
                    focusNode: FocusNode(),
                    enableInteractiveSelection: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range),
                      filled: true,
                      fillColor: bgColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      labelText: 'Date',
                      errorText:
                          _rideValidationError ? _validDate('ride') : null,
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context, 'ride'),
                    controller: _rideDateController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: FlatButton(
                    color: buttonColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
                    onPressed: () {
                      if (!_validInput('ride')) {
                        setState(() {
                          _rideValidationError = true;
                        });
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                      });
                      var search = {
                        'type': 'ride',
                        'from': _rideFromLocation.toJson(),
                        'to': _rideToLocation.toJson(),
                        'date': _rideDateController.text,
                      };
                      Navigator.push(context,
                          MaterialPageRoute(builder: (build) => SearchResultPage(search: search)));
                    },
                    child: Text(
                      'Search',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));

    final goods = Container(
        child: ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: AutoCompleteTextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.place),
                    filled: true,
                    fillColor: bgColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'From',
                    // errorText: _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.text,
                  key: _goodsFromKey,
                  controller: _goodsFromController,
                  suggestions: suggestions,
                  textChanged: (String val) {
                    setState(() {
                      _goodsFromLocation = null;
                    });
                    getSuggestions(val);
                  },
                  itemBuilder: suggestionItemBuilder,
                  itemFilter: suggestionFilter,
                  itemSorter: suggestionSorter,
                  itemSubmitted: (Location data) {
                    setState(() {
                      _goodsFromController.text = data.name;
                      _goodsFromLocation = data;
                    });
                  },
                  clearOnSubmit: false,
                ),
              ),
              _goodsValidationError && _validFrom('goods') != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(33.0, 0.0, 20.0, 10.0),
                      child: Text(
                        _goodsValidationError ? _validFrom('goods') : '',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ))
                  : Container(),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                child: AutoCompleteTextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.place),
                    filled: true,
                    fillColor: bgColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),

                    labelText: 'To',
                    // errorText: _showValidationError ? 'Invalid number entered' : null,
                  ),
                  keyboardType: TextInputType.text,
                  key: _goodsToKey,
                  controller: _goodsToController,
                  suggestions: suggestions,
                  textChanged: (String val) {
                    setState(() {
                      _goodsToLocation = null;
                    });
                    getSuggestions(val);
                  },
                  itemBuilder: suggestionItemBuilder,
                  itemFilter: suggestionFilter,
                  itemSorter: suggestionSorter,
                  itemSubmitted: (Location data) {
                    setState(() {
                      _goodsToController.text = data.name;
                      _goodsToLocation = data;
                    });
                  },
                  clearOnSubmit: false,
                ),
              ),
              _goodsValidationError && _validTo('goods') != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(33.0, 0.0, 20.0, 10.0),
                      child: Text(
                        _goodsValidationError ? _validTo('goods') : '',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ))
                  : Container(),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: TextField(
                    focusNode: FocusNode(),
                    enableInteractiveSelection: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range),
                      filled: true,
                      fillColor: bgColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      labelText: 'Date',
                      errorText:
                          _goodsValidationError ? _validDate('goods') : null,
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context, 'goods'),
                    controller: _goodsDateController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: FlatButton(
                    color: buttonColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
                    onPressed: () {
                      if (!_validInput('goods')) {
                        setState(() {
                          _goodsValidationError = true;
                        });
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    child: Text(
                      'Search',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: NavDrawer(),
            // TODO: improve app bar
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                  if (_scaffoldKey.currentState.isDrawerOpen) _clearRiderPage();
                },
              ),
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
                tabs: [
                  Tab(icon: Icon(Icons.directions_car)),
                  Tab(icon: Icon(Icons.shopping_cart)),
                ],
              ),
              centerTitle: true,
              backgroundColor: mainColor,
            ),
            body: Container(
              color: bgColor,
              child: TabBarView(
                children: [
                  ride,
                  goods,
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

  void _clearRiderPage() {
    setState(() {
      suggestions.clear();

      _rideFromController.text = '';
      _rideToController.text = '';
      _goodsFromController.text = '';
      _goodsToController.text = '';
      _rideDateController.text = '';
      _goodsDateController.text = '';

      _rideFromLocation = null;
      _rideToLocation = null;
      _goodsFromLocation = null;
      _goodsToLocation = null;

      rideSelectedDate = DateTime.now();
      goodsSelectedDate = DateTime.now();

      _rideValidationError = false;
      _goodsValidationError = false;
    });
  }

  bool _validInput(type) {
    if (_validFrom(type) == null &&
        _validTo(type) == null &&
        _validDate(type) == null) return true;
    return false;
  }

  String _validFrom(type) {
    if (type == 'ride')
      return _rideFromController.text.length < 1 || _rideFromLocation == null
          ? 'Please enter from location'
          : null;
    else
      return _goodsFromController.text.length < 1 || _goodsFromLocation == null
          ? 'Please enter from location'
          : null;
  }

  String _validTo(type) {
    if (type == 'ride')
      return _rideToController.text.length < 1 || _rideToLocation == null
          ? 'Please enter to location'
          : null;
    else
      return _goodsToController.text.length < 1 || _goodsToLocation == null
          ? 'Please enter to location'
          : null;
  }

  String _validDate(type) {
    if (type == 'ride')
      return _rideDateController.text.length < 1
          ? 'Please select a date'
          : null;
    else
      return _goodsDateController.text.length < 1
          ? 'Please select a date'
          : null;
  }
}
