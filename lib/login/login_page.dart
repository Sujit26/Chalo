import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/widgets/bottom_navigation.dart';
import 'phone_number.dart';

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

Color mainColor = hexToColor("#708690");
Color buttonColor = hexToColor("#A65A7B");
Color bgColor = hexToColor("#F7FAFB");
Color borderColor = hexToColor("#EBEBEB");
Color fbColor = hexToColor("#4267B2");
Color gColor = hexToColor("#de5246");
String serverURL = 'http://172.20.10.2:3002/';

class LoginPage extends StatefulWidget {
  final String name = 'Rider';
  final Color color = mainColor;

  @override
  _LoginPageState createState() => _LoginPageState();
}

// TODO: doc compress before upload and improve location suggestion and my vehicle pics and sidebar otp page getting out of view and show message when unable to connect to server
class _LoginPageState extends State<LoginPage> {
  var _isLoading = true;

  // To login with google
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    // if (!_isLoading) {
    //   googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //     var data = {
    //       'name': account.displayName,
    //       'email': account.email,
    //       'photoUrl': account.photoUrl
    //     };
    //     print(data);
    //     _makePostRequest(data);
    //   });
    //   googleSignIn.signInSilently();
    // }
    _makeGetRequest();
  }

  _makeGetRequest() async {
    final response = await get(serverURL);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['type'] == 'server' &&
          jsonData['info'] == 'Connection successful') {
        WidgetsFlutterBinding.ensureInitialized();
        var _prefs = SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        if (prefs.containsKey('login')) {
          // Getting firebase user token for the server
          final FirebaseUser currentUser = await _auth.currentUser();
          currentUser.getIdToken().then((idToken) {
            prefs.setString('token', idToken.token);
            if (prefs.getBool('login')) {
              var data = {
                'token': prefs.getString('token'),
                'name': prefs.getString('name'),
                'email': prefs.getString('email'),
                'photoUrl': prefs.getString('photoUrl'),
                'phone': prefs.getString("phone"),
                'gender': prefs.getString("gender"),
                'rating': prefs.getString("rating"),
              };
              print(data['email']);
              _makePostRequest(data);
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  double getAvgRating(ratings) {
    var total = ratings['1'] +
        ratings['2'] +
        ratings['3'] +
        ratings['4'] +
        ratings['5'];

    var avg = ((1 * ratings['1'] +
                    2 * ratings['2'] +
                    3 * ratings['3'] +
                    4 * ratings['4'] +
                    5 * ratings['5']) /
                total ==
            0
        ? 1
        : total);
    avg = num.parse(avg.toStringAsFixed(1));
    return avg;
  }

  _makePostRequest(data) async {
    final response = await post(serverURL,
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['msg'] == 'LoggedIn') {
        data = jsonData['user'];
        // To save user
        var _prefs = SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        prefs.setBool("login", true);
        prefs.setString("token", jsonData['token']);
        prefs.setString("name", data['name']);
        prefs.setString("email", data['email']);
        prefs.setString("photoUrl", data['photoUrl']);
        prefs.setString("phone", data['phone']);
        prefs.setString("gender", data['gender']);
        prefs.setString("approveStatus", data['verification']['approved']);
        prefs.setString("dlStatus", data['verification']['dl']);
        prefs.setString("sdStatus", data['verification']['sd']);
        prefs.setString("lpStatus", data['verification']['photo']);
        prefs.setInt("rating1", data['rating']['1']);
        prefs.setInt("rating2", data['rating']['2']);
        prefs.setInt("rating3", data['rating']['3']);
        prefs.setInt("rating4", data['rating']['4']);
        prefs.setInt("rating5", data['rating']['5']);
        prefs.setDouble("avgRating", getAvgRating(data['rating']));

        _navigateToRiderHome(context);
      } else
        _navigateToNumberPage(context, data);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigates to the [RiderHome].
  void _navigateToRiderHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
      ModalRoute.withName(''),
    );
  }

  /// Navigates to the [NumberPage].
  void _navigateToNumberPage(BuildContext context, data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NumberPage(userData: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Container(
        color: mainColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(children: <Widget>[
            Positioned(
                child: Align(
              alignment: FractionalOffset.center,
              child: Image.asset('assets/images/logo.png'),
            )),
            Positioned(
                child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: _isLoading
                  ? Padding(
                    padding: const EdgeInsets.only(bottom: 150.0),
                    child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                  )
                  : Wrap(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                  color: fbColor,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(40.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0.0, 28.0, 0.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.facebookF,
                                        size: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Continue with facebook',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () {
                              signInWithGoogle();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: gColor,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(40.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0.0, 28.0, 0.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.google,
                                        size: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            )),
          ]),
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

  signInWithGoogle() async {
    if (googleSignIn.currentUser != null) {
      GoogleSignInAccount account = googleSignIn.currentUser;

      // Getting firebase user token for the server
      final FirebaseUser currentUser = await _auth.currentUser();
      currentUser.getIdToken().then((idToken) {
        var data = {
          'name': account.displayName,
          'email': account.email,
          'photoUrl': account.photoUrl,
          'platform': 'ios',
          'token': idToken.token,
        };
        print(data['email']);
        _makePostRequest(data);
      }, onError: (Object error) {
        print('error in fetching firebase user id token. error=$error');
      });
    } else {
      try {
        final GoogleSignInAccount googleSignInAccount =
            await googleSignIn.signIn();
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        final FirebaseUser user = authResult.user;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);

        return 'signInWithGoogle succeeded: $user';
      } catch (e) {
        throw e;
      }
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }
}
