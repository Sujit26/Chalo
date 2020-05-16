import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_transport/login/login_page.dart';
import 'package:shared_transport/theme/theme_builder.dart';
import 'package:shared_transport/utils/localizations.dart';

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
      supportedLocales: [
        Locale('en', 'US'),
        Locale('hi', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: LoginPage(),
    );
  }
}
