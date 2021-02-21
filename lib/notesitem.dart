import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:psquare_android_client/models/NotesModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notesitem extends StatefulWidget {
  Notesitem({this.arguments}) {
    print("notes item constructor 1 ran");
  }

  final NotesModel arguments;

  @override
  _NotesitemState createState() => _NotesitemState(arguments: arguments);
}

class DateUtil {
  static const DATE_FORMAT = 'MMM dd,yyyy hh:mm a';
  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class _NotesitemState extends State<Notesitem> {
  _NotesitemState({this.arguments}) {
    print("notes item constructor 2 ran");
  }

  final NotesModel arguments;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> notesData = {
    'topic': null,
    'description': null,
    'seqnbr': null,
    'status': null
  };

  void updateNote() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 5,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              height: 250.0,
              width: 250.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Image.asset(
                        'assets/loadingspin1.gif',
                        height: 50,
                        width: 50,
                      )),
                ],
              ),
            ),
          );
        });

    _formKey.currentState.save();
    int compareTopic = arguments.topic.compareTo(notesData['topic']);
    int compareDesc = arguments.description.compareTo(notesData['description']);

    if (_formKey.currentState.validate() &&
        compareTopic != 0 &&
        compareDesc != 0) {
      print("service call");

      notesData['seqnbr'] = arguments.seqnbr;
      notesData['status'] = arguments.status;
      print(notesData);

      SharedPreferences storage = await SharedPreferences.getInstance();
      String token = storage.getString('token');

      if (notesData['seqnbr'] == null) {
        String psquareURL =
            'https://psquare-springboot-service.herokuapp.com/api/notes/addNotes';

        final Map<String, dynamic> insertData = {
          'topic': notesData['topic'],
          'description': notesData['description'],
        };

        final response = await post(psquareURL,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(insertData));
        print(response.body);

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: 'Note added', gravity: ToastGravity.CENTER);
        } else {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          Fluttertoast.showToast(
              msg: jsonResponse['message'], gravity: ToastGravity.CENTER);
        }
      } else {
        String psquareURL =
            'https://psquare-springboot-service.herokuapp.com/api/notes/updateNotes';

        final response = await post(psquareURL,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(notesData));
        print(response.body);

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: 'Note updated', gravity: ToastGravity.CENTER);
        } else {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          Fluttertoast.showToast(
              msg: jsonResponse['message'], gravity: ToastGravity.CENTER);
        }
      }
    } else {
      if (notesData['topic'].toString().isEmpty &&
          notesData['description'].toString().isEmpty) {
        Fluttertoast.showToast(
            msg: 'Empty note discarded', gravity: ToastGravity.CENTER);
        Navigator.of(context).pop();
      } else if (notesData['topic'].toString().isEmpty) {
        Fluttertoast.showToast(
            msg: 'Empty title', gravity: ToastGravity.CENTER);
        Navigator.of(context).pop();
      } else if (notesData['description'].toString().isEmpty) {
        Fluttertoast.showToast(
            msg: 'Empty description', gravity: ToastGravity.CENTER);
        Navigator.of(context).pop();
      }
    }
  }

  void deleteNotes() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    if (token == null) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Apologies! Login is expired. Please login & try again.',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5.0,
                    child: Text(
                      'Okay!',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: 'CenturyGothic',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
      Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
    } else {
      bool isTokenExpired = JwtDecoder.isExpired(token);
      if (isTokenExpired) {
        storage.clear();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Apologies! Login is expired. Please login & try again.',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'CenturyGothic',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                      elevation: 5.0,
                      child: Text(
                        'Okay!',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'CenturyGothic',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
        Navigator.of(context)
            .pushNamedAndRemoveUntil("login", (route) => false);
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Dialog(
                elevation: 5,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Container(
                  height: 250.0,
                  width: 250.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Image.asset(
                            'assets/loadingspin1.gif',
                            height: 50,
                            width: 50,
                          )),
                    ],
                  ),
                ),
              );
            });

        String psquareURL =
            'https://psquare-springboot-service.herokuapp.com/api/notes/deleteNotes';

        String json = '{"seqnbr": ' + arguments.seqnbr.toString() + '}';
        final response = await post(psquareURL,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json);
        print(response.body);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: 'Deleted', gravity: ToastGravity.CENTER);
        } else {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          Fluttertoast.showToast(
              msg: jsonResponse['message'], gravity: ToastGravity.CENTER);
        }
        Navigator.of(context)
            .pushNamedAndRemoveUntil("notes", (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await updateNote();
        Navigator.of(context)
            .pushNamedAndRemoveUntil("notes", (route) => false);
        return null;
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 75.0,
            elevation: 1.0,
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              color: Colors.black87,
              onPressed: () async {
                await updateNote();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("notes", (route) => false);
              },
            ),
            actions: <Widget>[
              arguments.status != null
                  ? Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.push_pin_outlined),
                            color: Colors.black87,
                            onPressed: () {
                              print("pin pressed");
                            }),
                        IconButton(
                            icon: Icon(Icons.delete_outlined),
                            color: Colors.black87,
                            onPressed: () {
                              print("delete button pressed");
                              deleteNotes();
                            })
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              await updateNote();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  "notes", (route) => false);
                            },
                            child: Container(
                              child: Text('Save',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild.unfocus();
              }
            },
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                          TextFormField(
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            initialValue: arguments.topic,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null) {
                                print("Title is empty");
                                return 'Title is empty';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              notesData['topic'] = value;
                            },
                            onChanged: (String value) {
                              notesData['topic'] = value;
                            },
                          ),
                          Divider(),
                          TextFormField(
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            initialValue: arguments.description,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelText: 'Note',
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null) {
                                print("Description is empty");
                                return 'Description is empty';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              notesData['description'] = value;
                            },
                            onChanged: (String value) {
                              notesData['description'] = value;
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          )
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: <Widget>[
                      // arguments.updatedat == null ?
                      Text(
                        'Edited at ' +
                            DateUtil().formattedDate(
                                DateTime.parse(arguments.updatedat).toLocal()),
                        style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
