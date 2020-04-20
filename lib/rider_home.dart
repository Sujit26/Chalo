import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_transport/loacation.dart';
import 'package:shared_transport/login/login_page.dart';
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
  final String name = 'Rider';

  @override
  _RiderHomeState createState() => _RiderHomeState();
}

const kGoogleApiKey = "AIzaSyBRhGd5iTPn7gs0OjQ3CXjwiXVZaLDuInk";

class _RiderHomeState extends State<RiderHome> {
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

  // GOOGLE PLACES SEARCH //
  // void getFromLocationResults(String input) async {
  //   suggestions.clear();
  //   if (input.isEmpty) return;

  //   var baseUrl =
  //       'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  //   var type = '(regions)';
  //   var url = '$baseUrl?input=$input&key=$kGoogleApiKey&type=$type';

  //   Response response = await get(url);
  //   var jsonData = json.decode(response.body);
  //   print(jsonData);

  //   setState(() {
  //     jsonData['predictions'].forEach((data) {
  //       suggestions.add(data['description']);
  //     });
  //   });
  // }

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
          selectedDate = picked;
          val == 'ride'
              ? _rideDateController.text =
                  '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}'
              : _goodsDateController.text =
                  '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
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
                      labelText: 'Date',
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
                    onPressed: () {},
                    child: Text(
                      "Search",
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
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

                      labelText: 'Date',
                      // errorText: _showValidationError ? 'Invalid number entered' : null,
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
                      /*...*/
                    },
                    child: Text(
                      "Search",
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
            drawer: NavDrawer(),
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
}
