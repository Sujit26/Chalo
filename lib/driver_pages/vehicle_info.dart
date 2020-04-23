import 'package:flutter/material.dart';

class Vehicle {
  String name;
  String modelName;
  int seats;
  String number;
  String pic;
  String type;
  int index;

  Vehicle({
    @required this.name,
    @required this.modelName,
    @required this.seats,
    @required this.number,
    @required this.pic,
    @required this.type,
    @required this.index,
  });
  Map<String, dynamic> toJson() => {
        'name': name,
        'modelName': modelName,
        'seats': seats,
        'number': number,
        'pic': pic,
        'type': type,
        'index': index,
      };
}
