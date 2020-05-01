import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/driver_pages/add_vehicle.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/widgets/custom_dialog.dart';
import 'package:shared_transport/widgets/empty_state.dart';
import 'package:shared_transport/driver_pages/vehicle_form.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///

class VehiclePage extends StatefulWidget {
  final String name = 'My Vehicles';
  final Color color = mainColor;

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<VehicleCard> vehicles = [];
  var _isLoading = true;
  var _totalVehicles = 0;
  var _totalTrips = 0;

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
      final response = await get(serverURL + 'driver/vehicle', headers: {
        'token': prefs.getString('token'),
        'email': prefs.getString('email'),
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          jsonData['vehicles'].forEach(
            (vehicle) => onAddForm(
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
          _totalVehicles = jsonData['vehicles'].length;
          _totalTrips = 0;
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

  _showAddForm() {
    Vehicle data = Vehicle(
        name: null,
        modelName: null,
        seats: null,
        number: null,
        pic: null,
        type: null,
        index: vehicles.length);
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
                    bottom: BorderSide(width: 1, color: Colors.black12),
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
                  child: AddVehicleBody(
                vehicle: data,
                edit: false,
              )),
            ],
          ),
        );
      },
    ).then(
      (onValue) {
        if (data.name != null && data.name != '') onAddForm(data);
      },
    );
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
      backgroundColor: buttonColor,
      title: Text(
        widget.name,
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
      actions: <Widget>[
        _isLoading
            ? Container()
            : FlatButton(
                child: Text('ADD'),
                onPressed: () {
                  _showAddForm();
                },
                textColor: Colors.white,
              ),
      ],
      centerTitle: true,
    );

    Widget createBody() {
      return Container(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            decoration: BoxDecoration(
              color: bgColor,
            ),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(buttonColor),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      _totalTrips.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    child: Text(
                                      'Total Trips',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.black26,
                              height: 70,
                              width: 2,
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      _totalVehicles.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    child: Text(
                                      'Total Vehicles',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      vehicles.length <= 0
                          ? Expanded(
                              child: Center(
                                child: EmptyState(
                                  title: 'Oops',
                                  message:
                                      'No vehicles added yet\nTap "+" button to add a vehicle',
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                addAutomaticKeepAlives: true,
                                itemCount: vehicles.length,
                                itemBuilder: (_, i) => vehicles[i],
                              ),
                            ),
                    ],
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

  ///on add form
  void onAddForm(data) {
    setState(() {
      vehicles.add(VehicleCard(vehicle: data));
      _totalVehicles += 1;
    });
  }
}
