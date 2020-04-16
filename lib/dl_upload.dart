import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/login_page.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
///
class DLUploadPage extends StatefulWidget {
  final String name = 'Driving License';
  final Color color = mainColor;

  @override
  _DLUploadPageState createState() => _DLUploadPageState();
}

class _DLUploadPageState extends State<DLUploadPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keySaving = new GlobalKey<State>();

  var approveText = 'APPROVED';
  var approveColor = Colors.green;
  var _isSaving = false;
  var _images = [];
  var _selectedPicNum = 0;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _makeGetRequest();
  }

  _makeGetRequest() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    final response = await get(serverURL + 'profile/dl', headers: {
      'token': prefs.getString('token'),
      'email': prefs.getString('email'),
    });
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['docs'] != null && jsonData['docs']['image1'] != null) {
        Uint8List input1 =
            Uint8List.fromList(jsonData['docs']['image1'].cast<int>());
        ByteData byteData = input1.buffer.asByteData();

        final buffer1 = byteData.buffer;
        Directory tempDir = await getTemporaryDirectory();
        String tempPath1 = tempDir.path;
        var filePath1 = tempPath1 +
            '/file_01.tmp'; // file_01.tmp is dump file, can be anything
        File(filePath1).writeAsBytes(buffer1.asUint8List(
            byteData.offsetInBytes, byteData.lengthInBytes));
        setState(() {
          _images.add(File(filePath1));
        });
      }
      if (jsonData['docs'] != null && jsonData['docs']['image2'] != null) {
        Uint8List input2 =
            Uint8List.fromList(jsonData['docs']['image2'].cast<int>());
        ByteData byteData = input2.buffer.asByteData();

        final buffer2 = byteData.buffer;
        Directory tempDir = await getTemporaryDirectory();
        String tempPath2 = tempDir.path;
        var filePath2 = tempPath2 +
            '/file_02.tmp'; // file_01.tmp is dump file, can be anything
        File(filePath2).writeAsBytes(buffer2.asUint8List(
            byteData.offsetInBytes, byteData.lengthInBytes));
        setState(() {
          _images.add(File(filePath2));
        });
      }
      setState(() {
        approveText = prefs.getString('dlStatus');
        approveColor = getTextColor(approveText);
        _isLoading = false;
      });
    }
  }

  _makePostRequest() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    var image1 = _images[0].readAsBytesSync();
    var image2 = _images[1].readAsBytesSync();

    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'image1': image1,
      'image2': image2,
    };

    final response = await post(serverURL + 'profile/dl',
        headers: {"Content-type": "application/json"}, body: jsonEncode(data));

    // final response = await get(serverURL + 'profile/dl', headers: {
    //   'token': prefs.getString('token'),
    //   'email': prefs.getString('email'),
    // });
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _isSaving = false;
      });
      Navigator.pop(context);

      var _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      prefs.setString('dlStatus', 'Pending');
      prefs.setString('approveStatus',
          (int.parse(prefs.getString('approveStatus')) + 25).toString());
    } else {
      Navigator.pop(context);
      setState(() {
        _isSaving = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(jsonData['msg']),
        ),
      );
    }
    // onTap: () {
    //   setState(() {
    //     _isSaving = false;
    //   });
    //   Navigator.pop(context);
    // },
  }

  MaterialColor getTextColor(text) {
    if (text == 'Upload')
      return Colors.blue;
    else if (text == 'Pending')
      return Colors.amber;
    else if (text == 'Approved')
      return Colors.green;
    else if (text == 'Rejected')
      return Colors.red;
    else
      return Colors.blue;
  }

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
            image: _images.length == 0
                ? NetworkImage(
                    'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80')
                : FileImage(_images[_selectedPicNum]),
          ),
        ),
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
    Future getImage(imageSource, {int index}) async {
      var image = await ImagePicker.pickImage(source: imageSource);

      if (image != null) {
        File croppedFile = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
            androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
            ),
            iosUiSettings: IOSUiSettings(
              title: 'Crop',
              rotateButtonsHidden: true,
              showCancelConfirmationDialog: true,
            ));
        if (croppedFile != null) {
          image = croppedFile;
          if (index == null)
            setState(() {
              _images.add(image);
            });
          else
            setState(() {
              _images.removeAt(index);
              _images.insert(index, image);
            });
        }
      }
    }

    showImageOptions({int index}) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                    onTap: () => {
                      getImage(ImageSource.camera, index: index),
                      Navigator.pop(context)
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                    onTap: () => {
                      getImage(ImageSource.gallery, index: index),
                      Navigator.pop(context)
                    },
                  ),
                ],
              ),
            );
          });
    }

    showMessageSnackbar(msg) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 1),
      ));
    }

    Widget _picIcon(int n) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: buttonColor),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPicNum = n;
              });
            },
            onLongPress: () {
              if (approveText == 'Upload' || approveText == 'Rejected') {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Row(
                            children: <Widget>[Text('Replace?')],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                showImageOptions(index: n);
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                          ],
                        ));
              } else {
                showMessageSnackbar('Document verification is $approveText');
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: _images.length >= n
                      ? FileImage(_images[n])
                      : NetworkImage(
                          'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _addPicButton() {
      return InkWell(
        onTap: () {
          if (_images.length < 2)
            showImageOptions();
          else
            showMessageSnackbar('Can\'t add more than 2');
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
      var pics = List.generate(_images.length, (int i) => _picIcon(i));
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

    Widget dlUploadBody = _isLoading
        ? Center(
            child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(buttonColor),
          ))
        : Row(
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
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
          bottomSheet: !_isLoading
              ? Container(
                  color: buttonColor,
                  child: InkWell(
                    onTap: () {
                      if (!_isSaving) {
                        if (_images.length == 2) {
                          setState(() {
                            _isSaving = true;
                          });
                          _makePostRequest();
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: Row(
                                      children: <Widget>[
                                        CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  buttonColor),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30),
                                          child: Text("Saving"),
                                        ),
                                      ],
                                    ),
                                  ));
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(color: Colors.red),
                              ),
                              content: Text('Upload both back and front side.'),
                            ),
                          );
                        }
                      }
                    },
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
                )
              : null,
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: createBody(),
      ),
    );
  }
}
