import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/add_addition_info.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/verification/profile_verification.dart';
import 'package:shared_transport/widgets/loacation.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/widgets/custom_dialog.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class DriverHome extends StatefulWidget {
  final String name = 'Drive';

  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  var _isLoading = true;
  var _verifiedDriver = true;
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
  TextEditingController _rideDateController = new TextEditingController();
  TextEditingController _goodsFromController = new TextEditingController();
  TextEditingController _goodsToController = new TextEditingController();
  TextEditingController _goodsDateController = new TextEditingController();
  // Field Data
  Location _rideFromLocation;
  Location _rideToLocation;
  Location _goodsFromLocation;
  Location _goodsToLocation;
  // Time
  var _rideTime;
  var _goodsTime;
  List<String> rideTimeList = new List();
  List<String> goodsTimeList = new List();
  DateTime rideSelectedDate = DateTime.now();
  DateTime goodsSelectedDate = DateTime.now();
  // Ride Vehicle
  Vehicle _vehicleName;
  List<Vehicle> vehicles = [];
  // Slots
  int _rideSlotsAvailable;
  int _goodsSlotsAvailable;
  List<int> rideSlots = [];
  List<int> goodsSlots = [1, 2, 3, 4, 5, 6];

  var _rideValidationError = false;
  var _goodsValidationError = false;

  getSuggestions(String val) async {
    suggestions.clear();
    if (val.isEmpty) return;
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    // TODO: Bias the response to favor results that are closer to this location.
    // var proximity = 'longitude,latitude';
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

  getDistance(Location fromLocation, Location toLocation) async {
    var accessToken =
        'pk.eyJ1IjoicGFyYWRveC1zaWQiLCJhIjoiY2p3dWluNmlrMDVlbTRicWcwMHJjdDY0bSJ9.sBILZWT0N-IC-_3s7_-dig';
    var coordinates =
        '${fromLocation.lon},${fromLocation.lat};${toLocation.lon},${toLocation.lat}';
    var mode = 'driving';
    var url =
        'https://api.mapbox.com/directions/v5/mapbox/$mode/$coordinates?access_token=$accessToken';
    var placesSearch = await get(url);
    double distance =
        jsonDecode(placesSearch.body)['routes'][0]['distance'] / 1000;
    double duration =
        jsonDecode(placesSearch.body)['routes'][0]['duration'] / 3600;

    return {
      'distance': double.parse(distance.toStringAsFixed(2)),
      'duration': double.parse(duration.toStringAsFixed(2)),
    };

    // setState(() {
    //   places.forEach((prediction) => {
    //         suggestions.add(Location(prediction['place_name'],
    //             prediction['center'][1], prediction['center'][0])),
    //       });
    // });
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
  void initState() {
    super.initState();
    _makeGetRequest();
  }

  _makeGetRequest() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    if (prefs.getString('approveStatus') == '100') {
      final response = await get(serverURL + 'driver', headers: {
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
          _verifiedDriver = true;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _verifiedDriver = false;
        });
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: buttonColor,
              ),
            ),
            title: 'Invalid Request',
            description:
                'This incident will be reported.\nYou will be redireted to the login page.',
            buttons: FlatButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  ModalRoute.withName(''),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(color: buttonColor, fontSize: 20),
              ),
            ),
          ),
        );
      }
    }
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
            rideTimeList.clear();
            _rideTime = null;
            var start = (picked.difference(rideSelectedDate).inDays > 0)
                ? 0
                : rideSelectedDate.hour + 1;
            for (var i = start; i < 24; i++) {
              if (i < 10)
                rideTimeList.add('0$i:00');
              else
                rideTimeList.add('$i:00');
            }
            rideSelectedDate = picked;
          } else {
            _goodsDateController.text =
                '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
            goodsTimeList.clear();
            _goodsTime = null;
            var start = (picked.difference(goodsSelectedDate).inDays > 0)
                ? 0
                : goodsSelectedDate.hour + 1;
            for (var i = start; i < 24; i++) {
              if (i < 10)
                goodsTimeList.add('0$i:00');
              else
                goodsTimeList.add('$i:00');
            }
            goodsSelectedDate = picked;
          }
        });
    }

    Widget ride() {
      return ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Material(
              elevation: 2,
              color: Colors.white,
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
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'From',
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
                      submitOnSuggestionTap: true,
                      clearOnSubmit: false,
                    ),
                  ),
                  _rideValidationError && _validFrom('ride') != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                          child: Text(
                            _rideValidationError ? _validFrom('ride') : '',
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
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'To',
                        // errorText: _showValidationError ? _validRideTo() : null,
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
                          padding:
                              const EdgeInsets.fromLTRB(13.0, 0.0, 20.0, 10.0),
                          color: Colors.white,
                          child: Text(
                            _rideValidationError ? _validTo('ride') : '',
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          ))
                      : Container(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 00.0, 20.0, 10.0),
            child: Material(
              elevation: 2,
              color: Colors.white,
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
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Date',
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context, 'ride'),
                    controller: _rideDateController,
                  ),
                  _rideValidationError && _validDate('ride') != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                          child: Text(
                            _rideValidationError ? _validDate('ride') : '',
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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Time',
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    isExpanded: true,
                    isDense: true,
                    value: _rideTime,
                    onChanged: (val) {
                      setState(() {
                        _rideTime = val;
                      });
                    },
                    items: rideTimeList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  _rideValidationError && _validTime('ride') != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.fromLTRB(13.0, 0.0, 20.0, 10.0),
                          color: Colors.white,
                          child: Text(
                            _rideValidationError ? _validTime('ride') : '',
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          ))
                      : Container(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Material(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField<Vehicle>(
                    decoration: InputDecoration(
                      hintText: 'Choose Vehicle',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      disabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    isExpanded: true,
                    isDense: true,
                    value: _vehicleName,
                    onChanged: (val) {
                      setState(() {
                        _vehicleName = val;
                        rideSlots.clear();
                        for (var i = 0; i < val.seats; i++)
                          rideSlots.add(i + 1);
                        _rideSlotsAvailable = null;
                      });
                    },
                    items: vehicles.map((Vehicle value) {
                      return DropdownMenuItem<Vehicle>(
                        value: value,
                        child: Text('${value.name} ${value.modelName}'),
                      );
                    }).toList(),
                  ),
                  _rideValidationError && _validVehicle('ride') != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                          color: Colors.white,
                          child: Text(
                            _rideValidationError ? _validVehicle('ride') : '',
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
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      hintText: 'Slots Available',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      disabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    isExpanded: true,
                    isDense: true,
                    value: _rideSlotsAvailable,
                    onChanged: (val) {
                      setState(() {
                        _rideSlotsAvailable = val;
                      });
                    },
                    items: rideSlots.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  _rideValidationError && _validSlots('ride') != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 0.0, 20.0, 10.0),
                          color: Colors.white,
                          child: Text(
                            _rideValidationError ? _validSlots('ride') : '',
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
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: MaterialButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              color: buttonColor,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
              onPressed: () async {
                if (!_validInput('ride')) {
                  setState(() {
                    _rideValidationError = true;
                  });
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                var route =
                    await getDistance(_rideFromLocation, _rideToLocation);
                var newDrive = {
                  'type': 'ride',
                  'from': _rideFromLocation.toJson(),
                  'to': _rideToLocation.toJson(),
                  'drive_date': _rideDateController.text,
                  'drive_time': _rideTime,
                  'vehicle': _vehicleName.toJson(),
                  'slots': _rideSlotsAvailable,
                  'routeDetail': route,
                };
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Color(0xFF737373),
                  builder: (builder) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20.0),
                          topRight: const Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(width: 1, color: Colors.black12),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                height: 4,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: AddAdditionalInfo(drive: newDrive),
                          ),
                        ],
                      ),
                    );
                  },
                ).then((onValue) {
                  setState(() {
                    if (onValue == 'clear') {
                      suggestions.clear();

                      // Form Locations
                      _rideFromController.text = '';
                      _rideFromLocation = null;

                      _goodsFromController.text = '';
                      _goodsFromLocation = null;

                      // To Locations
                      _rideToController.text = '';
                      _rideToLocation = null;

                      _goodsToLocation = null;
                      _goodsToController.text = '';

                      // Date and Time
                      _rideDateController.text = '';
                      rideSelectedDate = DateTime.now();

                      _rideTime = null;
                      rideTimeList.clear();

                      _goodsDateController.text = '';
                      goodsSelectedDate = DateTime.now();

                      _goodsTime = null;
                      goodsTimeList.clear();

                      _vehicleName = null;

                      _rideSlotsAvailable = null;
                      _goodsSlotsAvailable = null;

                      _rideValidationError = false;
                      _goodsValidationError = false;
                    }
                    _isLoading = false;
                  });
                });
              },
              child: Text(
                'Add',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      );
    }

    Widget goods() {
      return Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Material(
                elevation: 2,
                color: Colors.white,
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
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: 'From',
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
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 0.0, 20.0, 10.0),
                            child: Text(
                              _goodsValidationError ? _validFrom('goods') : '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ))
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
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: 'To',
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
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 0.0, 20.0, 10.0),
                            child: Text(
                              _goodsValidationError ? _validTo('goods') : '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ))
                        : Container(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Material(
                elevation: 2,
                color: Colors.white,
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
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'Date',
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap: () => _selectDate(context, 'goods'),
                      controller: _goodsDateController,
                    ),
                    _goodsValidationError && _validDate('goods') != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 0.0, 20.0, 10.0),
                            child: Text(
                              _goodsValidationError ? _validDate('goods') : '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ))
                        : Container(),
                    Container(
                      height: .5,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black12,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Time',
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      isExpanded: true,
                      isDense: true,
                      value: _goodsTime,
                      onChanged: (val) {
                        setState(() {
                          _goodsTime = val;
                        });
                      },
                      items: goodsTimeList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    _goodsValidationError && _validTime('goods') != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 0.0, 20.0, 10.0),
                            child: Text(
                              _goodsValidationError ? _validTime('goods') : '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ))
                        : Container(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Material(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Slots Available',
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      isExpanded: true,
                      isDense: true,
                      value: _goodsSlotsAvailable,
                      onChanged: (val) {
                        setState(() {
                          _goodsSlotsAvailable = val;
                        });
                      },
                      items: goodsSlots.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    _goodsValidationError && _validSlots('goods') != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 0.0, 20.0, 10.0),
                            child: Text(
                              _goodsValidationError ? _validSlots('goods') : '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ))
                        : Container(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Material(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlatButton(
                  color: buttonColor,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
                  onPressed: () async {
                    if (!_validInput('goods')) {
                      setState(() {
                        _goodsValidationError = true;
                      });
                      return;
                    }
                    setState(() {
                      _isLoading = true;
                    });
                    var route =
                        await getDistance(_goodsFromLocation, _goodsToLocation);
                    var newDrive = {
                      'type': 'goods',
                      'from': _goodsFromLocation.toJson(),
                      'to': _goodsToLocation.toJson(),
                      'drive_date': _goodsDateController.text,
                      'drive_time': _goodsTime,
                      'slots': _goodsSlotsAvailable,
                      'routeDetail': route,
                    };
                    print(newDrive);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Color(0xFF737373),
                      builder: (builder) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black12),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    height: 4,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: AddAdditionalInfo(drive: newDrive),
                              ),
                            ],
                          ),
                        );
                      },
                    ).then((onValue) {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget verify() {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              child: Image(
                  color: buttonColor,
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/proxy/hSfjRH6Yi5auQJnsyiHaycdqwWyWwMshqMmg5_ev4GSx3x0eWi3EsM1DsWWnejPxqAxQ7PDwbTC3b1vBPMs_jEPlEoMF9Rixsw-Xohke04Dry3CIkWYXmP4mEgEM7h_szA')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'To drive with us please complete the verification process.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (build) => ProfileVerificationPage(),
                    ),
                  );
                },
                color: buttonColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.all(15),
                child: Text('Go to verification Page'),
              ),
            )
          ],
        ),
      );
    }

    Widget createBody() {
      return _verifiedDriver
          ? DefaultTabController(
              length: 2,
              child: Container(
                color: bgColor,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: <Widget>[
                          !_isLoading
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  child: Material(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: TabBar(
                                        unselectedLabelColor: buttonColor,
                                        indicator: ShapeDecoration(
                                          color: buttonColor,
                                          shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                        ),
                                        tabs: [
                                          Tab(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text("RIDE"),
                                            ),
                                          ),
                                          Tab(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text("GOODS"),
                                            ),
                                          ),
                                        ]),
                                  ),
                                )
                              : null,
                          Expanded(
                            child: TabBarView(
                              children: [
                                ride(),
                                goods(),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : verify();
    }

    return Scaffold(
      appBar: AppBar(
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
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
        backgroundColor: buttonColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }

  bool _validInput(type) {
    if (_validFrom(type) == null &&
        _validTo(type) == null &&
        _validDate(type) == null &&
        _validTime(type) == null &&
        _validSlots(type) == null &&
        _validVehicle(type) == null) return true;
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

  String _validTime(type) {
    if (type == 'ride')
      return _rideTime == null ? 'Please select a time' : null;
    else
      return _goodsTime == null ? 'Please select a time' : null;
  }

  String _validSlots(type) {
    if (type == 'ride')
      return _rideSlotsAvailable == null ? 'Please select a slot' : null;
    else
      return _goodsSlotsAvailable == null ? 'Please select a slot' : null;
  }

  String _validVehicle(type) {
    if (type == 'ride')
      return _vehicleName == null ? 'Please select a vehicle' : null;
    else
      return null;
  }
}
