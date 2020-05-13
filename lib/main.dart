import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/theme/theme_builder.dart';

// TODO: open ios/Runner.xcworkspace to open xcode

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chalo',
      theme: ThemeBuilder.buildLightTheme(),
      home: LoginPage(),
    );
  }
}
