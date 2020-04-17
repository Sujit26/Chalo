import 'package:flutter/material.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/widgets/sidebar.dart';

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

class RiderHome extends StatefulWidget {
  final String name = 'Rider';
  final Color color = mainColor;

  @override
  _RiderHomeState createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    Future<Null> _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
        });
    }

    final ride = Container(
        child: ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.place),
                filled: true,
                fillColor: bgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),

                labelText: 'From',
                // errorText: _showValidationError ? 'Invalid number entered' : null,
              ),
              keyboardType: TextInputType.text,

              // onChanged: _updateInputValue,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.place),
                filled: true,
                fillColor: bgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),

                labelText: 'To',
                // errorText: _showValidationError ? 'Invalid number entered' : null,
              ),
              keyboardType: TextInputType.text,
              // onChanged: _updateInputValue,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    focusNode: FocusNode(),
                    enableInteractiveSelection: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range),
                      filled: true,
                      fillColor: bgColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),

                      labelText: 'Date',
                      // errorText: _showValidationError ? 'Invalid number entered' : null,
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context),
                    // onChanged: _updateInputValue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: FlatButton(
                    color: buttonColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
                    onPressed: () {
                      /*...*/
                    },
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));

    final goods = Container(
        child: ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.place),
                filled: true,
                fillColor: bgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),

                labelText: 'From',
                // errorText: _showValidationError ? 'Invalid number entered' : null,
              ),
              keyboardType: TextInputType.text,

              // onChanged: _updateInputValue,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.place),
                filled: true,
                fillColor: bgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),

                labelText: 'To',
                // errorText: _showValidationError ? 'Invalid number entered' : null,
              ),
              keyboardType: TextInputType.text,
              // onChanged: _updateInputValue,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    focusNode: FocusNode(),
                    enableInteractiveSelection: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range),
                      filled: true,
                      fillColor: bgColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),

                      labelText: 'Date',
                      // errorText: _showValidationError ? 'Invalid number entered' : null,
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context),
                    // onChanged: _updateInputValue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: FlatButton(
                    color: buttonColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 17.0, 30.0, 17.0),
                    onPressed: () {
                      /*...*/
                    },
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            drawer: NavDrawer(),
            appBar: AppBar(
              elevation: 0,
              title: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.black38,
                labelColor: Colors.black38,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(icon: Icon(Icons.directions_car)),
                  Tab(icon: Icon(Icons.shopping_cart)),
                ],
              ),
              centerTitle: true,
              backgroundColor: mainColor,
            ),
            body: Container(
              color: bgColor,
              child: TabBarView(
                children: [
                  ride,
                  goods,
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
}
