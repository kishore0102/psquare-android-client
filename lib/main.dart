import 'package:flutter/material.dart';
import 'package:psquare_android_client/login.dart';
import 'package:psquare_android_client/notes.dart';
import 'package:psquare_android_client/notesitem.dart';

void main() => runApp(PsquareApp());

class PsquareApp extends StatefulWidget {
  @override
  _PsquareAppState createState() => _PsquareAppState();
}

class _PsquareAppState extends State<PsquareApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Psquare',
        home: Notes(),
        routes: <String, WidgetBuilder>{
          "login": (BuildContext context) => new Login(),
          "notes": (BuildContext context) => new Notes(),
          "notesitem": (BuildContext context) => new Notesitem(),
        });
  }
}
