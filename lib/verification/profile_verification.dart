import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/verification/docs_upload_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class ProfileVerificationPage extends StatefulWidget {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 2,
      titleSpacing: 0,
      title: Text(
          AppLocalizations.of(context).localisedText['profile_verification']),
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
                                color: Theme.of(context).accentColor,
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
                            AppLocalizations.of(context)
                                .localisedText['driving_licence'],
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
                                    color: Theme.of(context).accentColor,
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
                                AppLocalizations.of(context)
                                    .localisedText['second_document'],
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
                                    color: Theme.of(context).accentColor,
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
                                AppLocalizations.of(context)
                                    .localisedText['live_photo'],
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
                    color: Theme.of(context).accentColor,
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
                AppLocalizations.of(context).localisedText['verified'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Text(AppLocalizations.of(context)
                  .localisedText['verification_page_message']),
            ],
          ),
        ),
      ],
    );

    Widget createBody() {
      return Container(
        child: Scaffold(
          appBar: appBar,
          body: profileVerificationBody,
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
