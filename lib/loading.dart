import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'database.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  DatabaseHelper db = DatabaseHelper.instance;

  void getItems() async {
    List<Map<String,dynamic>> items = await db.query();
    List<Map<String,dynamic>> temp = [];
    items.forEach((element) {temp.add(jsonDecode(jsonEncode(element)));});
    // print(temp);
    // print(19);
    // print(items);
    Navigator.pushReplacementNamed(context, '/home',arguments: temp);
  }

  @override
  void initState() {
    super.initState();
    this.getItems();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SpinKitFoldingCube(
            color: Colors.white,
            size: 50.0,
          ),
        ),
        backgroundColor: Colors.blue,
      )
    );
  }
}
