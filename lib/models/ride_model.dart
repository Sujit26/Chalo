import 'package:flutter/material.dart';
import 'package:shared_transport/models/models.dart';

class User {
  String name;
  String email;
  double rating;
  String pic;
  String phone;
  int nod;
  // Extra
  LocationLatLng from;
  LocationLatLng to;
  int slots;
  String rideId;

  User({
    @required this.name,
    @required this.email,
    @required this.rating,
    @required this.pic,
    this.nod,
    this.phone,
    this.from,
    this.to,
    this.slots,
    this.rideId,
  });
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'rating': rating,
        'pic': pic,
        'phone': phone,
        'nod': nod,
      };
}

class RideModel {
  String type;
  LocationLatLng from;
  LocationLatLng to;
  String driveDate;
  String fromTime;
  String toTime;
  Vehicle vehicle;
  int slots;
  String dId;
  User driver;
  // for history
  int total;
  double currentDis;
  double currentDur;

  RideModel({
    @required this.type,
    @required this.from,
    @required this.to,
    @required this.driveDate,
    @required this.fromTime,
    @required this.toTime,
    @required this.vehicle,
    @required this.slots,
    @required this.dId,
    @required this.driver,
    this.total,
    this.currentDis,
    this.currentDur,
  });
  Map<String, dynamic> toJson() => {
        'type': type,
        'from': from.toJson(),
        'to': to.toJson(),
        'driveDate': driveDate,
        'fromTime': fromTime,
        'toTime': toTime,
        'vehicle': vehicle.toJson(),
        'slots': slots,
        'dId': dId,
        'driver': driver.toJson(),
      };
}
