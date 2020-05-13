import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:shared_transport/driver_pages/my_vehicle.dart';
import 'package:shared_transport/models/models.dart';

class AddVehicleBody extends StatefulWidget {
  final Vehicle vehicle;
  final bool edit;

  const AddVehicleBody({Key key, @required this.vehicle, @required this.edit})
      : super(key: key);

  _AddVehicleBodyState createState() => _AddVehicleBodyState();
}

class _AddVehicleBodyState extends State<AddVehicleBody> {
  TextEditingController _companyNameController =
      TextEditingController(text: '');
  TextEditingController _modelNameController = TextEditingController(text: '');
  TextEditingController _numberController = TextEditingController(text: '');
  var _seats;
  var _type;
  var _isAdding = false;
  var _isDeleting = false;
  var _showErrors = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle.name != null)
      setState(() {
        _companyNameController.text = widget.vehicle.name;
        _modelNameController.text = widget.vehicle.modelName;
        _numberController.text = widget.vehicle.number;
        _seats = widget.vehicle.seats.toString();
        _type = widget.vehicle.type;
      });
  }

  _makePostRequest() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'name': _companyNameController.text,
      'modelName': _modelNameController.text,
      'seats': int.parse(_seats),
      'number': _numberController.text,
      'pic':
          'https://pictures.topspeed.com/IMG/crop/201706/audi-a5-cabriolet-dr_1600x0w.jpg',
      'type': _type,
      'edit': widget.edit,
      'del': _isDeleting,
      'pos': widget.vehicle.index,
    };
    final response = await post(Keys.serverURL + 'driver/vehicle',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        _isAdding = false;
        _isDeleting = false;
        widget.vehicle.name = _companyNameController.text;
        widget.vehicle.modelName = _modelNameController.text;
        widget.vehicle.seats = int.parse(_seats);
        widget.vehicle.number = _numberController.text;
        widget.vehicle.pic =
            'https://pictures.topspeed.com/IMG/crop/201706/audi-a5-cabriolet-dr_1600x0w.jpg';
        widget.vehicle.type = _type;
      });
      if (jsonData['msg'] == 'Deleted') {
        setState(() {
          widget.vehicle.name = 'Deleted';
        });
        // find a better way
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (builder) => VehiclePage()));
      } else
        Navigator.pop(context);
    } else {
      print('Error, Try Again!');
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.directions_car),
                  border: InputBorder.none,
                  labelText: 'Vehicle Company name',
                  errorText: !_showErrors ? null : _validCompanyName(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                textCapitalization: TextCapitalization.words,
                controller: _companyNameController,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.directions_car),
                  border: InputBorder.none,
                  labelText: 'Vehicle Model name',
                  errorText: !_showErrors ? null : _validModelName(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                textCapitalization: TextCapitalization.words,
                controller: _modelNameController,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.directions_car),
                  border: InputBorder.none,
                  labelText: 'Vehicle Registration Number',
                  errorText: !_showErrors ? null : _validVehicleNumber(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                textCapitalization: TextCapitalization.words,
                controller: _numberController,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Seats',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        errorText: !_showErrors ? null : _validSeats(),
                      ),
                      isExpanded: true,
                      isDense: true,
                      value: _seats,
                      onChanged: (val) {
                        setState(() {
                          _seats = val;
                        });
                      },
                      items: [
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Type',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        errorText: !_showErrors ? null : _validType(),
                      ),
                      isExpanded: true,
                      isDense: true,
                      value: _type,
                      onChanged: (val) {
                        setState(() {
                          _type = val;
                        });
                      },
                      items: [
                        'Hatchback',
                        'SUV',
                        'Sedan',
                        'Motorbike',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: FlatButton(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: _isAdding
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.edit ? 'SAVE' : 'ADD'),
                  onPressed: _isAdding || _isDeleting
                      ? () {}
                      : () {
                          setState(() {
                            _showErrors = true;
                          });
                          if (_validInput()) {
                            setState(() {
                              _isAdding = true;
                            });
                            _makePostRequest();
                          }
                        },
                )),
          ),
          widget.edit
              ? Container(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                      child: FlatButton(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: Colors.white,
                        textColor: Theme.of(context).accentColor,
                        child: _isDeleting
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).accentColor),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('DELETE'),
                        onPressed: _isDeleting || _isAdding
                            ? () {}
                            : () {
                                setState(() {
                                  _isDeleting = true;
                                });
                                _makePostRequest();
                              },
                      )),
                )
              : Container(),
        ],
      ),
    );
  }

  bool _validInput() {
    if (_validCompanyName() == null &&
        _validModelName() == null &&
        _validVehicleNumber() == null &&
        _validSeats() == null &&
        _validType() == null) return true;
    return false;
  }

  String _validCompanyName() {
    return _companyNameController.text.length < 1
        ? 'Company name Can\'t be empty'
        : null;
  }

  String _validModelName() {
    return _modelNameController.text.length < 1
        ? 'Model name Can\'t be empty'
        : null;
  }

  String _validVehicleNumber() {
    return _numberController.text.length < 1
        ? 'Vehicle number Can\'t be empty'
        : null;
  }

  String _validSeats() {
    return _seats == null ? 'Select seat' : null;
  }

  String _validType() {
    return _type == null ? 'Select type' : null;
  }
}
