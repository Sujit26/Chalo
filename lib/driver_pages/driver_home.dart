import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/loacation.dart';
import 'package:shared_transport/login/login_page.dart';

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
  TextEditingController _goodsFromController = new TextEditingController();
  TextEditingController _goodsToController = new TextEditingController();
  TextEditingController _rideDateController = new TextEditingController();
  TextEditingController _goodsDateController = new TextEditingController();
  // Vehicle DropDown list
  var vehicleName;
  List<Vehicle> vehicles = [];
  // Slots DropDown list
  int slotsAvailable;
  List<int> slots = [];
  // Time DropDown list
  var time;
  List<String> timeList = new List();
  DateTime selectedDate = DateTime.now();

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
            builder: (context) => AlertDialog(
                  title: Row(
                    children: <Widget>[Text('Invalid Request')],
                  ),
                  content: Text(
                      'This incident will be reported.\nYou will be redireted to the login page.'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => LoginPage()),
                          ModalRoute.withName(''),
                        );
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<Null> _selectDate(BuildContext context, String val) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime(2101),
      );
      if (picked != null)
        setState(() {
          val == 'ride'
              ? _rideDateController.text =
                  '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}'
              : _goodsDateController.text =
                  '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
          timeList.clear();
          time = null;
          var start = (picked.difference(selectedDate).inDays > 0)
              ? 0
              : selectedDate.hour + 1;
          for (var i = start; i < 24; i++) {
            if (i < 10)
              timeList.add('0$i:00');
            else
              timeList.add('$i:00');
          }
          selectedDate = picked;
        });
    }

    final ride = Container(
        child: ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Padding(
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
              textChanged: getSuggestions,
              itemBuilder: suggestionItemBuilder,
              itemFilter: suggestionFilter,
              itemSorter: suggestionSorter,
              itemSubmitted: (Location data) {
                _rideFromController.text = data.name;
              },
              submitOnSuggestionTap: true,
              clearOnSubmit: false,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
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
              textChanged: getSuggestions,
              itemBuilder: suggestionItemBuilder,
              itemFilter: suggestionFilter,
              itemSorter: suggestionSorter,
              itemSubmitted: (Location data) {
                _rideToController.text = data.name;
              },
              clearOnSubmit: false,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
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
                      labelText: 'Date',
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
                      ),
                      isExpanded: true,
                      isDense: true,
                      value: time,
                      onChanged: (val) {
                        setState(() {
                          time = val;
                        });
                      },
                      items: timeList.map((String value) {
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
            ),
            isExpanded: true,
            isDense: true,
            value: vehicleName,
            onChanged: (val) {
              setState(() {
                vehicleName = val;
                slots.clear();
                for (var i = 0; i < val.seats; i++) slots.add(i + 1);
                slotsAvailable = null;
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
                  ),
                  isExpanded: true,
                  isDense: true,
                  value: slotsAvailable,
                  onChanged: (val) {
                    setState(() {
                      slotsAvailable = val;
                    });
                  },
                  items: slots.map((int value) {
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
                    onPressed: () {
                      /*...*/
                    },
                    child: Text(
                      "Add",
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
          child: Padding(
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
              textChanged: getSuggestions,
              itemBuilder: suggestionItemBuilder,
              itemFilter: suggestionFilter,
              itemSorter: suggestionSorter,
              itemSubmitted: (Location data) {
                _goodsFromController.text = data.name;
              },
              clearOnSubmit: false,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
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
              textChanged: getSuggestions,
              itemBuilder: suggestionItemBuilder,
              itemFilter: suggestionFilter,
              itemSorter: suggestionSorter,
              itemSubmitted: (Location data) {
                _goodsToController.text = data.name;
              },
              clearOnSubmit: false,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: Row(
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
                    labelText: 'Date',
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
                    ),
                    isExpanded: true,
                    isDense: true,
                    value: time,
                    onChanged: (val) {
                      setState(() {
                        time = val;
                      });
                    },
                    items: [
                      '00:00',
                      '01:00',
                      '02:00',
                      '03:00',
                      '04:00',
                      '05:00',
                      '06:00',
                      '07:00',
                      '08:00',
                      '09:00',
                      '10:00',
                      '11:00',
                      '12:00',
                      '13:00',
                      '14:00',
                      '15:00',
                      '16:00',
                      '17:00',
                      '18:00',
                      '19:00',
                      '20:00',
                      '21:00',
                      '22:00',
                      '23:00',
                      '24:00',
                    ].map((String value) {
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
                  ),
                  isExpanded: true,
                  isDense: true,
                  value: slotsAvailable,
                  onChanged: (val) {
                    setState(() {
                      slotsAvailable = val;
                    });
                  },
                  items: [1, 2, 3, 4, 5, 6].map((int value) {
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
                    onPressed: () {
                      /*...*/
                    },
                    child: Text(
                      "Add",
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
}
