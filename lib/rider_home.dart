import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_transport/models/models.dart';
import 'package:location/location.dart';
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
class SearchPage extends StatefulWidget {
  final String name = 'Search';

  @override
  _SearchPageState createState() => _SearchPageState();
}

const kGoogleApiKey = "AIzaSyBRhGd5iTPn7gs0OjQ3CXjwiXVZaLDuInk";

class _SearchPageState extends State<SearchPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  // Location Suggestions
  List<LocationLatLng> suggestions = [];
  GlobalKey<AutoCompleteTextFieldState<LocationLatLng>> _fromKey =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<LocationLatLng>> _toKey =
      new GlobalKey();
  // Fields Controllers
  TextEditingController _fromController = new TextEditingController();
  TextEditingController _toController = new TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  // User Location
  Location _location;
  LocationData _myLocation;
  // Field Data
  LocationLatLng _fromLocation;
  LocationLatLng _toLocation;
  // Date
  DateTime selectedDate = DateTime.now();
  // Type of search
  String type = 'ride';

  var _validationError = false;

  @override
  void initState() {
    super.initState();
    // Setting up my locations
    _location = Location();
    _location.getLocation().then((onValue) {
      setState(() {
        _myLocation = onValue;
      });
    });
  }

  getSuggestions(String val) async {
    suggestions.clear();
    if (val.isEmpty) return;
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    var proximity = '${_myLocation.longitude},${_myLocation.latitude}';
    var url =
        'http://api.mapbox.com/geocoding/v5/mapbox.places/$val.json?proximity=$proximity&access_token=$accessToken&language=en&country=in&types=place';
    var placesSearch = await get(url);
    var places = jsonDecode(placesSearch.body)['features'];
    setState(() {
      places.forEach((prediction) => {
            suggestions.add(LocationLatLng(prediction['place_name'],
                prediction['center'][1] * 1.0, prediction['center'][0] * 1.0)),
          });
    });
  }

  Widget suggestionItemBuilder(
      BuildContext context, LocationLatLng suggestion) {
    return Padding(
        child: ListTile(title: Text(suggestion.name)),
        padding: EdgeInsets.all(8.0));
  }

  bool suggestionFilter(LocationLatLng suggestion, String query) {
    return suggestion.name.toLowerCase().startsWith(query.toLowerCase());
  }

  int suggestionSorter(LocationLatLng a, LocationLatLng b) {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    Future<Null> _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime(2101),
      );
      if (picked != null)
        setState(() {
          _dateController.text =
              '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
          selectedDate = picked;
        });
    }

    final ride = ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                Container(
                  height: 50,
                  child: AutoCompleteTextField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.my_location),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'From',
                    ),
                    keyboardType: TextInputType.text,
                    key: _fromKey,
                    controller: _fromController,
                    suggestions: suggestions,
                    textChanged: (String val) {
                      setState(() {
                        _fromLocation = null;
                      });
                      getSuggestions(val);
                    },
                    itemBuilder: suggestionItemBuilder,
                    itemFilter: suggestionFilter,
                    itemSorter: suggestionSorter,
                    itemSubmitted: (LocationLatLng data) {
                      setState(() {
                        _fromController.text = data.name;
                        _fromLocation = data;
                      });
                    },
                    clearOnSubmit: false,
                  ),
                ),
                _validationError && _validFrom() != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                        color: Colors.white,
                        child: Text(
                          _validationError ? _validFrom() : '',
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      )
                    : Container(),
                Container(
                  height: .5,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black12,
                ),
                Container(
                  height: 50,
                  child: AutoCompleteTextField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.place),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'To',
                    ),
                    keyboardType: TextInputType.text,
                    key: _toKey,
                    controller: _toController,
                    suggestions: suggestions,
                    textChanged: (String val) {
                      setState(() {
                        _toLocation = null;
                      });
                      getSuggestions(val);
                    },
                    itemBuilder: suggestionItemBuilder,
                    itemFilter: suggestionFilter,
                    itemSorter: suggestionSorter,
                    itemSubmitted: (LocationLatLng data) {
                      setState(() {
                        _toController.text = data.name;
                        _toLocation = data;
                      });
                    },
                    clearOnSubmit: false,
                  ),
                ),
                _validationError && _validTo() != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                        color: Colors.white,
                        child: Text(
                          _validationError ? _validTo() : '',
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                TextField(
                  focusNode: FocusNode(),
                  enableInteractiveSelection: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.date_range),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: 'Date',
                  ),
                  keyboardType: TextInputType.datetime,
                  onTap: () => _selectDate(context),
                  controller: _dateController,
                ),
                _validationError && _validDate() != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                        color: Colors.white,
                        child: Text(
                          _validationError ? _validDate() : '',
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          type = 'ride';
                        });
                      },
                      child: Container(
                        color: type == 'ride'
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        child: ListTile(
                          title: Align(
                            alignment: Alignment.center,
                            child: Center(
                                child: Text(
                              "RIDE",
                              style: TextStyle(
                                color: type == 'ride'
                                    ? Colors.white
                                    : Theme.of(context).accentColor,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          type = 'goods';
                        });
                      },
                      child: Container(
                        color: type == 'goods'
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        child: ListTile(
                          title: Align(
                            alignment: Alignment.center,
                            child: Center(
                                child: Text(
                              "GOODS",
                              style: TextStyle(
                                color: type == 'goods'
                                    ? Colors.white
                                    : Theme.of(context).accentColor,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: MaterialButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
            onPressed: () {
              if (!_validInput()) {
                setState(() {
                  _validationError = true;
                });
                return;
              }
              var search = {
                'type': type,
                'from': _fromLocation.toJson(),
                'to': _toLocation.toJson(),
                'date': _dateController.text,
              };
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (build) => SearchResultPage(search: search)));
            },
            child: Text(
              'Search',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
      ],
    );

    Widget createBody() {
      return Container(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: NavDrawer(),
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            elevation: 2,
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
                if (_scaffoldKey.currentState.isDrawerOpen) _clearPage();
              },
            ),
            title: Text(widget.name),
          ),
          body: ride,
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

  void _clearPage() {
    setState(() {
      suggestions.clear();

      _fromController.text = '';
      _toController.text = '';

      _dateController.text = '';

      _fromLocation = null;
      _toLocation = null;

      selectedDate = DateTime.now();

      _validationError = false;

      type = 'ride';
    });
  }

  bool _validInput() {
    if (_validFrom() == null && _validTo() == null && _validDate() == null)
      return true;
    return false;
  }

  String _validFrom() {
    return _fromController.text.length < 1 || _fromLocation == null
        ? 'Please enter from location'
        : null;
  }

  String _validTo() {
    return _toController.text.length < 1 || _toLocation == null
        ? 'Please enter to location'
        : null;
  }

  String _validDate() {
    return _dateController.text.length < 1 ? 'Please select a date' : null;
  }
}
