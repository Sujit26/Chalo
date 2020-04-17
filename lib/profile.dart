import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/verification/profile_verification.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class ProfilePage extends StatefulWidget {
  final String name = 'Profile';
  final Color color = mainColor;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _photoUrl =
      'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
  var _gender;
  var _token;
  var _isSaving = false;

  // TextField Controllers
  TextEditingController _nameController = TextEditingController(text: '');
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _phoneController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    setInitialValues();
  }

  setInitialValues() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var _name = prefs.getString("name");
    var _email = prefs.getString("email");
    var _phone = prefs.getString("phone");
    setState(() {
      _photoUrl = prefs.getString('photoUrl') == null
          ? 'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'
          : prefs.getString('photoUrl');
      _gender = prefs.containsKey('gender') ? prefs.getString('gender') : null;
      _nameController = TextEditingController(
          text: _name == null ? '' : prefs.getString("name"));
      _emailController = TextEditingController(
          text: _email == null ? '' : prefs.getString("email"));
      _phoneController = TextEditingController(
          text: _phone == null ? '' : prefs.getString("phone"));
      _token = prefs.getString("token");
    });
  }

  final _formKey = GlobalKey<FormState>();

  get _profilePic {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill, image: NetworkImage(_photoUrl))),
          ),
        ),
      ],
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => {
                    logout(),
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                      ModalRoute.withName(''),
                    ),
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      elevation: 0,
      title: Text(
        widget.name,
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
      actions: <Widget>[
        GestureDetector(
            onTap: () {
              _settingModalBottomSheet(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                Icons.more_horiz,
                size: 26.0,
              ),
            )),
      ],
      centerTitle: true,
      backgroundColor: mainColor,
    );

    Widget profileBody = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  _profilePic,
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                          labelText: 'Name',
                          errorText: _validName(),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        textCapitalization: TextCapitalization.words,
                        controller: _nameController,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                          labelText: 'Email',
                          errorText: _validEmail(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        controller: _emailController,
                        enabled: false,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: new InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Gender',
                          errorText: _validGender(),
                        ),
                        isEmpty: _gender == null,
                        child: new DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          isDense: true,
                          onChanged: _updateGenderValue,
                          items:
                              ['Male', 'Female', 'Other'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.phone),
                          border: InputBorder.none,
                          labelText: 'Phone',
                          errorText: _validPhone(),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        controller: _phoneController,
                        enabled: false,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                        child: InkWell(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileVerificationPage()),
                            )
                          },
                          child: TextField(
                            decoration: InputDecoration(
                              suffixIcon:
                                  Icon(Icons.verified_user, color: buttonColor),
                              border: InputBorder.none,
                              labelText: 'Profile Verification',
                              labelStyle: TextStyle(
                                  color: buttonColor,
                                  fontWeight: FontWeight.bold),
                              enabled: false,
                              // errorText: _showValidationError ? 'Invalid number entered' : null,
                            ),
                            keyboardType: TextInputType.text,
                            // onChanged: _updateInputValue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    Widget createBody() {
      return Container(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            color: bgColor,
            child: profileBody,
          ),
          bottomSheet: Container(
            color: buttonColor,
            child: InkWell(
              onTap: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _isSaving = true;
                      });
                      print('Saving!!!');
                      var data = {
                        'email': _emailController.text,
                        'name': _nameController.text,
                        'gender': _gender.toString(),
                        'token': _token
                      };
                      _makePostRequest(data);
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _isSaving
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.5),
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                            height: 35.0,
                            width: 35.0,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'SAVE',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }

  _makePostRequest(data) async {
    final response = await post(serverURL + 'profile/update',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
      // TODO: Change data in local storage
      print('Profile Updated!');
      setState(() {
        _isSaving = false;
      });
    } else {
      print('Error, Try Again!');
      print(response.body);
    }
  }

  String _validName() {
    return _nameController.text.length < 3
        ? 'Name must be more than 2 charater'
        : null;
  }

  String _validEmail() {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    return regex.hasMatch(_emailController.text)
        ? null
        : 'Invalid Email entered';
  }

  String _validGender() {
    return _gender == null ? 'Invalid Gender selected' : null;
  }

  String _validPhone() {
    return _phoneController.text.length == 10
        ? null
        : 'Invalid phone number entered';
  }

  void _updateGenderValue(String value) {
    setState(() {
      _gender = value;
    });
  }

  logout() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    prefs.setBool('login', false);
    // To logout with google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
  }
}
