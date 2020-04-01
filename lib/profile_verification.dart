import 'package:flutter/material.dart';
import 'package:shared_transport/login_page.dart';

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

class ProfileVerificationPage extends StatefulWidget {
  final String name = 'Profile Verification';
  final Color color = mainColor;

  @override
  _ProfileVerificationPageState createState() =>
      _ProfileVerificationPageState();
}

class _ProfileVerificationPageState extends State<ProfileVerificationPage> {
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
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(const Radius.circular(5.0)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: InkWell(
                    onTap: () => {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfileVerificationPage()),
                      // )
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
                        )
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
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(const Radius.circular(5.0)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () => {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ProfileVerificationPage()),
                          // )
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
                                'Secondary Document',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ProfileVerificationPage()),
                          // )
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
                            )
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
                        '100%',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 48,
                        ),
                      )),
                ),
              ),
              Text(
                'Approved',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                  fontSize: 18,
                ),
              ),
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
