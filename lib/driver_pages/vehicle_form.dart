import 'package:flutter/material.dart';
import 'package:shared_transport/driver_pages/add_vehicle.dart';
import 'package:shared_transport/models/models.dart';

class VehicleCard extends StatefulWidget {
  final Vehicle vehicle;

  VehicleCard({Key key, @required this.vehicle}) : super(key: key);

  @override
  _VehicleCardState createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  Vehicle vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = widget.vehicle;
  }

  showCarPic() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.fill,
        image: NetworkImage(vehicle.pic),
      )),
    );
  }

  _showEditForm() {
    Vehicle data = vehicle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF737373),
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black12),
                  ),
                ),
                child: Center(
                  child: Container(
                    height: 4,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
              Flexible(child: AddVehicleBody(vehicle: data, edit: true)),
            ],
          ),
        );
      },
    ).then((onValue) {
      if (data.name != null && data.name != '')
        setState(() {
          vehicle.name = data.name;
          vehicle.modelName = data.modelName;
          vehicle.number = data.number;
          vehicle.seats = data.seats;
          vehicle.pic = data.pic;
          vehicle.type = data.type;
        });
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBar(
              title: Text('Total seats ${vehicle.seats}'),
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      child: Icon(
                        vehicle.type == 'Motorbike'
                            ? Icons.motorcycle
                            : Icons.directions_car,
                        size: 30.0,
                      ),
                    )),
              ],
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                vehicle.number,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                              Text(
                                vehicle.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                vehicle.modelName,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            _showEditForm();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.edit,
                                color: Theme.of(context).accentColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'EDIT',
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[showCarPic()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
