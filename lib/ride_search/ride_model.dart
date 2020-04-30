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

  User({
    @required this.name,
    @required this.email,
    @required this.rating,
    @required this.pic,
    this.nod,
    this.phone,
  });
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
}