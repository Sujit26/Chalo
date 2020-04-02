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

class DLUploadPage extends StatefulWidget {
  final String name = 'Driving License';
  final Color color = mainColor;

  @override
  _DLUploadPageState createState() => _DLUploadPageState();
}

class _DLUploadPageState extends State<DLUploadPage> {
  int nop = 1;
  var approveText = 'APPROVED';
  var approveColor = Colors.green;

  get _selectedPic {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.all(const Radius.circular(10)),
            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'))),
      ),
    );
  }

  get _approveText {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        approveText,
        style: TextStyle(
          fontSize: 18,
          color: approveColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _picIcon() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: buttonColor),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'))),
          ),
        ),
      );
    }

    Widget _addPicButton() {
      return InkWell(
        onTap: () {
          setState(() {
            nop = nop + 1;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: buttonColor),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  shape: BoxShape.circle,
                  color: buttonColor),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    Widget _showAllPics() {
      var pics = List.generate(nop, (int i) => _picIcon());
      pics.add(_addPicButton());
      return Container(
        height: 64,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: pics,
        ),
      );
    }

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

    Widget dlUploadBody = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: <Widget>[
                _approveText,
                _selectedPic,
                _showAllPics(),
                Text(
                  'GUIDLINES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    '- Name, Date of Birth, Driver Licence Number, Expiry Date and Vehicle class should be clearly visible',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    '- Both FRONT and BACK of the licence must be uploaded',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    '- Colour photocopy, laminated version or blurry image of licence will not be accepted',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    '- Licence alreay registered with us will not be accepted',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                  child: Text(
                    '- Any discrepancy in information will cause booking cancellation',
                  ),
                ),
              ],
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
            child: dlUploadBody,
          ),
          bottomSheet: Container(
            color: buttonColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
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
}
