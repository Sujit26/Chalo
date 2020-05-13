import 'package:flutter/material.dart';
import 'package:shared_transport/models/models.dart';


class HistoryModel {
  String action;
  RideModel rideInfo;
  // Only for drive
  List<User> requestFromRiders;
  List<User> acceptedRiders;
  // Only for rides
  User rider;
  LocationLatLng rideFrom;
  LocationLatLng rideTo;
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
