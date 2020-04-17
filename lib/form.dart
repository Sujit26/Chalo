import 'package:flutter/material.dart';
import 'package:shared_transport/rating/rating_info.dart';

typedef OnDelete();

class UserForm extends StatefulWidget {
  final UserRating user;
  final state = _UserFormState();
  final OnDelete onDelete;

  UserForm({Key key, this.user, this.onDelete}) : super(key: key);
  @override
  _UserFormState createState() => state;

  bool isValid() => state.validate();
}

class _UserFormState extends State<UserForm> {
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                leading: Icon(Icons.verified_user),
                elevation: 0,
                title: Text('User Details'),
                backgroundColor: Theme.of(context).accentColor,
                centerTitle: true,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextFormField(
                  initialValue: widget.user.email,
                  validator: (val) =>
                      val.length > 3 ? null : 'Full name is invalid',
                  decoration: InputDecoration(
                    labelText: 'From',
                    hintText: 'From Place',
                    icon: Icon(Icons.map),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'To',
                    hintText: 'To place',
                    icon: Icon(Icons.map),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  initialValue: widget.user.date,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Date Of Trip',
                    icon: Icon(Icons.map),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///form validator
  bool validate() {
    var valid = form.currentState.validate();
    if (valid) form.currentState.save();
    return valid;
  }
}
