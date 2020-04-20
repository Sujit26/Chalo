import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/verification/docs_upload_page.dart';
import 'package:shared_transport/login/login_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class ProfileVerificationPage extends StatefulWidget {
  final String name = 'Profile Verification';
  final Color color = mainColor;

  @override
  _ProfileVerificationPageState createState() =>
      _ProfileVerificationPageState();
}

class _ProfileVerificationPageState extends State<ProfileVerificationPage> {
  var _verification = '0';
  var _prefs;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _setVerification();
  }

  _setVerification() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = SharedPreferences.getInstance();
    prefs = await _prefs;
    setState(() {
      _verification = prefs.getString('approveStatus');
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
      centerTitle: true,
      backgroundColor: mainColor,
    );

    Widget getStatusIcon(status) {
      if (status == 'Upload')
        return Icon(
          Icons.cloud_upload,
          color: Colors.blue[300],
        );
      else if (status == 'Approved')
        return Icon(
          Icons.check_circle,
          color: Colors.green[300],
        );
      else if (status == 'Rejected')
        return Icon(
          Icons.cancel,
          color: Colors.red[300],
        );
      else if (status == 'Pending')
        return Icon(
          Icons.watch_later,
          color: Colors.amber[300],
        );
      else
        return Icon(
          Icons.not_interested,
          color: Colors.black,
        );
    }

    Widget profileVerificationBody = ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.black12),
                    borderRadius: BorderRadius.all(const Radius.circular(5.0)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: InkWell(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DocsUploadPage(
                                  name: 'dl',
                                )),
                      )
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(100.0)),
                                color: buttonColor,
                              ),
                              child: Icon(
                                Icons.assignment_ind,
                                color: Colors.white,
                                size: 20,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            'Driving Licence',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Spacer(),
                        getStatusIcon(
                            prefs != null ? prefs.getString('dlStatus') : ''),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.black12),
                    borderRadius: BorderRadius.all(const Radius.circular(5.0)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocsUploadPage(
                                      name: 'sd',
                                    )),
                          )
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        const Radius.circular(100.0)),
                                    color: buttonColor,
                                  ),
                                  child: Icon(
                                    Icons.assignment_ind,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                'Second Document',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Spacer(),
                            getStatusIcon(prefs != null
                                ? prefs.getString('sdStatus')
                                : ''),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DocsUploadPage(name: 'lp')),
                          )
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        const Radius.circular(100.0)),
                                    color: buttonColor,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                'Live Photo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Spacer(),
                            getStatusIcon(prefs != null
                                ? prefs.getString('lpStatus')
                                : ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor,
                  ),
                  child: Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        _verification + '%',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 48,
                        ),
                      )),
                ),
              ),
              Text(
                'Verified',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Text('To drive with us complete the verification process.'),
            ],
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
            child: profileVerificationBody,
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
}
