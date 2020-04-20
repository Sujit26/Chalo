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
}
