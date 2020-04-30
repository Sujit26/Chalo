import 'package:flutter/material.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/widgets/loacation.dart';

class HistoryModel {
  String action;
  RideModel rideInfo;
  // Only for drive
  List<User> requestFromRiders;
  List<User> acceptedRiders;
  // Only for rides
  User rider;
  Location rideFrom;
  Location rideTo;
  String rideFromTime;
  String rideToTime;
  int rideSlots;
  String rideStatus;

  HistoryModel({
    @required this.action,
    @required this.rideInfo,
    this.requestFromRiders,
    this.acceptedRiders,
    // Only for riders
    this.rider,
    this.rideFrom,
    this.rideTo,
    this.rideFromTime,
    this.rideToTime,
    this.rideSlots,
    this.rideStatus,
  });
}
