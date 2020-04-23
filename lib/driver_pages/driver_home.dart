import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/add_addition_info.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/loacation.dart';
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
    var proximity = 'longitude,latitude';
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

          _isLoading = false;
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
                    // errorText: _showValidationError ? _validRideFrom() : null,
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
                Expanded(
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
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgColor,
                        labelText: 'Time',
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
                          borderSide: BorderSide(
                            color: borderColor,
                          ),
                        ),
                        errorText:
                            _rideValidationError ? _validTime('ride') : null,
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
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: DropdownButtonFormField<Vehicle>(
            decoration: InputDecoration(
              filled: true,
              fillColor: bgColor,
              labelText: 'Choose Vehicle',
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
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              errorText: _rideValidationError ? _validVehicle('ride') : null,
            ),
            isExpanded: true,
            isDense: true,
            value: _vehicleName,
            onChanged: (val) {
              setState(() {
                _vehicleName = val;
                rideSlots.clear();
                for (var i = 0; i < val.seats; i++) rideSlots.add(i + 1);
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
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgColor,
                    labelText: 'Slots Available',
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
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    errorText:
                        _rideValidationError ? _validSlots('ride') : null,
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: FlatButton(
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
              )
            ],
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
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
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
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: bgColor,
                      labelText: 'Time',
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
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      errorText:
                          _goodsValidationError ? _validTime('goods') : null,
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
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgColor,
                    labelText: 'Slots Available',
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
                      borderSide: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    errorText:
                        _goodsValidationError ? _validSlots('goods') : null,
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
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
                      var route = await getDistance(
                          _goodsFromLocation, _goodsToLocation);
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
              )
            ],
          ),
        ),
      ],
    ));

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              bottom: !_isLoading
                  ? TabBar(
                      indicatorColor: Colors.black38,
                      labelColor: Colors.black38,
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(icon: Icon(Icons.directions_car)),
                        Tab(icon: Icon(Icons.shopping_cart)),
                      ],
                    )
                  : null,
              centerTitle: true,
              backgroundColor: mainColor,
            ),
            body: Container(
              color: bgColor,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
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
