import 'package:budgets_app/ChooseCard.dart';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'home.dart';
import 'info.dart';
import 'history.dart';

void main() {runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/info':(context)=>Info(),
        '/history':(context)=>History(),
        '/choosecard':(context)=>ChooseCard(),
      },
    );
  }
}