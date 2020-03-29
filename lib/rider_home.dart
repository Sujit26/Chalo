import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Converter screen where users can input amounts to convert.
///
/// Currently, it just displays a list of mock units.
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.

class RiderHome extends StatefulWidget {
  final String name = 'Rider';
  final Color color = Colors.blueGrey;

  @override
  _RiderHomeState createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  @override
  Widget build(BuildContext context) {
    // Here is just a placeholder for a list of mock units
    // final unitWidgets = widget.units.map((Unit unit) {
    //   return DropdownMenuItem<String>(
    //     value: unit.name,
    //     child: Container(
    //       child: Text(
    //         unit.name,
    //         softWrap: true,
    //       ),
    //     ),
    //   );
    // });
    final ride = Container(
        child: ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white60,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              labelText: 'To',
              // errorText: _showValidationError ? 'Invalid number entered' : null,
            ),
            keyboardType: TextInputType.text,
            // onChanged: _updateInputValue,
          ),
        ),
      ],
    ));

    final goods = Icon(
      Icons.shopping_cart,
      color: Colors.white,
    );

    Widget createBody() {
      return Container(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24.0,
                  semanticLabel: 'SideBar',
                ),
              ),
              title: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 28.0,
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
              backgroundColor: widget.color,
            ),
            body: Container(
              color: Colors.black87,
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
