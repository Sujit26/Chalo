// import 'package:flutter/material.dart';
// import 'package:shared_transport/history_pages/history_model.dart';
// import 'package:shared_transport/login/login_page.dart';
// import 'dart:math' as math;

// class ProfileCard extends StatefulWidget {
//   final HistoryModel ride;

//   ProfileCard({Key key, @required this.ride}) : super(key: key);
//   @override
//   _ProfileCardState createState() => _ProfileCardState();
// }

// class _ProfileCardState extends State<ProfileCard> {
//   var _accepted = false;
//   var _rejected = false;

//   Widget _starFilling(double fill) {
//     return fill >= 1.0
//         ? Icon(
//             Icons.star,
//             color: buttonColor,
//             size: 30,
//           )
//         : fill > 0
//             ? Icon(
//                 Icons.star_half,
//                 color: buttonColor,
//                 size: 30,
//               )
//             : Icon(
//                 Icons.star_border,
//                 color: buttonColor,
//                 size: 30,
//               );
//   }

//   showSeats() {
//     List<Widget> seats = List();
//     for (var i = 0; i < widget.ride.vehicle.seats; i++)
//       seats.add(Icon(Icons.person, color: buttonColor, size: 18));
//     seats.add(Text(''));
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: seats,
//     );
//   }

//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Stack(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(top: 80),
//             child: Material(
//               elevation: 1,
//               clipBehavior: Clip.antiAlias,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 height: 370,
//                 width: 300,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//                 color: Colors.white,
//                 child: Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.only(top: 60),
//                       child: Text(
//                         'Sidhant Jain',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold,
//                           color: buttonColor,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'sidhantjain456@gmail.com',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black38,
//                       ),
//                     ),
//                     Spacer(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         _starFilling(4.5),
//                         _starFilling(4.5),
//                         _starFilling(4.5),
//                         _starFilling(4.5),
//                         _starFilling(4.5),
//                       ],
//                     ),
//                     Spacer(),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 3),
//                       child: Text(
//                         'Slots requested',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     showSeats(),
//                     Spacer(),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.only(left: 20),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               Icon(
//                                 Icons.fiber_manual_record,
//                                 color: buttonColor,
//                                 size: 15,
//                               ),
//                               Transform.rotate(
//                                 angle: 90 * math.pi / 180,
//                                 child: Icon(
//                                   Icons.linear_scale,
//                                   color: buttonColor.withAlpha(150),
//                                   size: 15,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.location_on,
//                                 color: mainColor,
//                                 size: 15,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 15),
//                             child: Column(
//                               children: <Widget>[
//                                 Container(
//                                   height: 30.0,
//                                   child: Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Text(
//                                       '${widget.ride.from.name.split(',')[0]},${widget.ride.from.name.split(',')[1]}',
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: 30.0,
//                                   child: Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Text(
//                                         '${widget.ride.to.name.split(',')[0]},${widget.ride.to.name.split(',')[1]}'),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Spacer(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: <Widget>[
//                         FlatButton(
//                           child: Text(
//                             'ACCEPT',
//                             style: TextStyle(
//                               color: buttonColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _accepted = true;
//                             });
//                           },
//                         ),
//                         Container(
//                           width: 2,
//                           height: 20,
//                           color: buttonColor,
//                         ),
//                         FlatButton(
//                           child: Text(
//                             'REJECT',
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _rejected = true;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 50,
//             right: 50,
//             child: Material(
//               elevation: 5,
//               shape: CircleBorder(),
//               child: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 radius: 70,
//                 child: Container(
//                   width: 130,
//                   height: 130,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: NetworkImage(widget.ride.driver.pic),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           _accepted
//               ? Padding(
//                   padding: const EdgeInsets.only(top: 80),
//                   child: CustomPaint(
//                     painter: ShapesPainter(mainColor),
//                     child: Container(
//                       height: 370,
//                       width: 300,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Spacer(flex: 5),
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               border: Border.all(width: 4, color: Colors.white),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.done,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Spacer(flex: 1),
//                           Text(
//                             'ACCEPTED',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Spacer(flex: 8),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   height: 370,
//                   width: 300,
//                 ),
//           _rejected
//               ? Padding(
//                   padding: const EdgeInsets.only(top: 80),
//                   child: CustomPaint(
//                     painter: ShapesPainter(buttonColor),
//                     child: Container(
//                       height: 370,
//                       width: 300,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Spacer(flex: 5),
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               border: Border.all(width: 4, color: Colors.white),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.close,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Spacer(flex: 1),
//                           Text(
//                             'REJECTED',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Spacer(flex: 8),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   height: 370,
//                   width: 300,
//                 ),
//         ],
//       ),
//     );
//   }
// }

// class ShapesPainter extends CustomPainter {
//   final Color _color;
//   ShapesPainter(this._color);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();

//     var rect = Rect.fromLTWH(0, 0, size.width, size.height);

//     paint.color = _color.withOpacity(.8);

//     final RRect rRect = new RRect.fromRectAndCorners(
//       rect,
//       topLeft: Radius.circular(20.0),
//       topRight: Radius.circular(20.0),
//       bottomLeft: Radius.circular(20.0),
//       bottomRight: Radius.circular(20.0),
//     );
//     canvas.drawRRect(rRect, paint);

//     var center = Offset(size.width / 2, 0);

//     canvas.drawArc(
//       Rect.fromCenter(
//         center: center,
//         height: size.height / 2.3,
//         width: size.width / 2.1,
//       ),
//       math.pi,
//       math.pi,
//       false,
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
