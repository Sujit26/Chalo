import 'package:flutter/material.dart';
import 'package:shared_transport/widgets/custom_tooltip_shape.dart';

class CustomTooltip extends StatelessWidget {
  final String message;
  final Color bgColor;
  final String photoUrl;
  final GlobalKey<State<Tooltip>> _tipKey = GlobalKey();

  CustomTooltip({
    Key key,
    @required this.message,
    @required this.bgColor,
    @required this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tipKey,
      showDuration: Duration(seconds: 10),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      message: message,
      textStyle: TextStyle(color: bgColor),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: TooltipShapeBorder(arrowArc: 0.5),
        shadows: [
          BoxShadow(
              color: Colors.black26, blurRadius: 4.0, offset: Offset(2, 2))
        ],
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          final dynamic tooltip = _tipKey.currentState;
          tooltip.ensureTooltipVisible();
        },
        shape: CircleBorder(),
        elevation: 5,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(photoUrl),
            ),
          ),
        ),
      ),
    );
  }
}
