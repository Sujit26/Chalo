import 'package:flutter/material.dart';
import 'package:shared_transport/ride_search/ride_model.dart';
import 'package:shared_transport/login/login_page.dart';

class ProfileCard extends StatefulWidget {
  final User user;

  ProfileCard({Key key, @required this.user}) : super(key: key);
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Widget _starFilling(double fill) {
    return fill >= 1.0
        ? Icon(
            Icons.star,
            color: buttonColor,
            size: 30,
          )
        : fill > 0
            ? Icon(
                Icons.star_half,
                color: buttonColor,
                size: 30,
              )
            : Icon(
                Icons.star_border,
                color: buttonColor,
                size: 30,
              );
  }

  showSeats(slots) {
    List<Widget> seats = List();
    for (var i = 0; i < slots; i++)
      seats.add(Icon(Icons.person, color: buttonColor, size: 18));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: seats,
    );
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Material(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 300,
                width: 300,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        widget.user.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: buttonColor,
                        ),
                      ),
                    ),
                    Text(
                      widget.user.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                    Text(
                      // widget.user.gender,
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _starFilling(widget.user.rating),
                        _starFilling(widget.user.rating - 1),
                        _starFilling(widget.user.rating - 2),
                        _starFilling(widget.user.rating - 3),
                        _starFilling(widget.user.rating - 4),
                      ],
                    ),
                    Spacer(flex: 2),
                    widget.user.phone == null
                        ? Container(
                            height: 60,
                            child: Icon(
                              Icons.lock,
                              color: Colors.black45,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              MaterialButton(
                                onPressed: () {},
                                padding: const EdgeInsets.all(16),
                                shape: CircleBorder(),
                                elevation: 3,
                                color: mainColor,
                                child: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {},
                                padding: const EdgeInsets.all(16),
                                shape: CircleBorder(),
                                elevation: 3,
                                color: buttonColor,
                                child: Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                    Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            child: Material(
              elevation: 5,
              shape: CircleBorder(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 70,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(widget.user.pic),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
