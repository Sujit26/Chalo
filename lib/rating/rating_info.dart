import 'package:flutter/material.dart';

class UserRating {
  String email;
  String emailFrom;
  String date;
  String ratingComments;
  String ratingStars;

  UserRating(
      {@required this.email,
      @required this.emailFrom,
      @required this.date,
      @required this.ratingComments,
      @required this.ratingStars});
}
