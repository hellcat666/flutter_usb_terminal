import 'package:flutter/material.dart';
import 'package:notifier/notifier_provider.dart';


import './ApplicationData.dart';
import './HomePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(NotifierProvider(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ApplicationData(
      child: MaterialApp(
        title: 'USB Serial Terminal V1.0.0',
        theme: ThemeData(
          primaryColor: Colors.black,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(title: 'USB Serial Terminal V1.0.0'),
      ),
    );
  }
}
