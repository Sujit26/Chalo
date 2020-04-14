import 'package:flutter/material.dart';
import 'package:shared_transport/login_page.dart';
import 'package:shared_transport/rating_info.dart';

class RatingForm extends StatelessWidget {
  final UserRating user;

  RatingForm({Key key, this.user}) : super(key: key);

  Widget build(BuildContext context) {
    Widget _starFilling(double fill) {
      return fill >= 1.0
          ? Icon(
              Icons.star,
              color: buttonColor,
            )
          : fill > 0
              ? Icon(
                  Icons.star_half,
                  color: buttonColor,
                )
              : Icon(
                  Icons.star_border,
                  color: buttonColor,
                );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBar(
              title: Text('User Rating'),
              backgroundColor: mainColor,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      child: Icon(
                        Icons.format_quote,
                        size: 30.0,
                      ),
                    )),
              ],
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(user.ratingComments),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Wrap(
                      children: <Widget>[
                        _starFilling(double.parse(user.ratingStars)),
                        _starFilling(double.parse(user.ratingStars) - 1),
                        _starFilling(double.parse(user.ratingStars) - 2),
                        _starFilling(double.parse(user.ratingStars) - 3),
                        _starFilling(double.parse(user.ratingStars) - 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}