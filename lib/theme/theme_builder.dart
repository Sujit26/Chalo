import 'package:flutter/material.dart';
import 'package:shared_transport/theme/colors.dart';

class ThemeBuilder {
  static ThemeData buildLightTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
            color: LightColor.appbarColor,
            textTheme:
                base.accentTextTheme.copyWith(title: TextStyle(fontSize: 22))),
        accentColor: LightColor.appbarColor,
        backgroundColor: LightColor.borderColor,
        primaryColor: LightColor.mainColor,
        primaryTextTheme: base.textTheme.copyWith(),
        sliderTheme: base.sliderTheme.copyWith(
          activeTrackColor: LightColor.appbarColor,
          inactiveTrackColor: LightColor.bgColor,
          trackHeight: 5.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
          overlayColor: Colors.purple.withAlpha(0),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
        ));
  }
}
