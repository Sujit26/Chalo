import 'package:flutter/material.dart';
import 'package:shared_transport/driver_pages/vehicle_info.dart';
import 'package:shared_transport/widgets/loacation.dart';

class User {
  String name;
  String email;
  double rating;
  String pic;
  String phone;
  int nod;
  // Extra
  Location from;
  Location to;
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
  Location from;
  Location to;
  String driveDate;
  String fromTime;
  String toTime;
  Vehicle vehicle;
  int slots;
  String dId;
  User driver;

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
