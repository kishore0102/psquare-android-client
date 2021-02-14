import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:psquare_android_client/models/NotesModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:psquare_android_client/nav_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class DateUtil {
  static const DATE_FORMAT = 'MMM dd,yyyy hh:mm';
  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class _NotesState extends State<Notes> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NotesModel> dataToBeRendered = <NotesModel>[];
  bool searchStatus = false;

  @override
  _NotesState() {
    print("constructor ran");
    checkForTokenAndRedirect();
  }

  void checkForTokenAndRedirect() async {
    // FlutterSecureStorage storage = FlutterSecureStorage();
    SharedPreferences storage = await SharedPreferences.getInstance();
    try {
      // String token = await storage.read(key: 'token');
      String token = storage.getString('token');
      if (token == null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed("login");
        });
      } else {
        String psquareURL =
            'https://psquare-springboot-service.herokuapp.com/api/notes/getNotes';
        final response = await get(psquareURL, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
        int statusCode = response.statusCode;
        print(statusCode);
        print(response.body);
        if (statusCode == 200) {
          final parsed =
              await jsonDecode(response.body).cast<Map<String, dynamic>>();
          List<NotesModel> parsedList = await parsed
              .map<NotesModel>((json) => NotesModel.fromJson(json))
              .toList();
          print(dataToBeRendered);
          print(dataToBeRendered.length);
          setState(() {
            dataToBeRendered = parsedList;
          });
        } else {
          // await storage.deleteAll();
          storage.clear();
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed("login");
          });
        }
      }
    } on Exception catch (_) {
      print('exception in checkForTokenAndRedirect');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed("login");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: NavDrawer(),
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild.unfocus();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 50.0,
                            height: 50.0,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              child: IconButton(
                                icon: Icon(Icons.menu),
                                tooltip: 'Menu',
                                iconSize: 30.0,
                                color: Colors.black54,
                                onPressed: () {
                                  print("menu button clicked");
                                  _scaffoldKey.currentState.openDrawer();
                                },
                              ),
                            ),
                          ),
                          Text(
                            'notes.',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'CenturyGothic',
                            ),
                          ),
                          Container(
                            width: 50.0,
                            height: 50.0,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              child: IconButton(
                                icon: Icon(Icons.search),
                                tooltip: 'Search',
                                iconSize: 30.0,
                                color: Colors.black54,
                                onPressed: () {
                                  print("search button clicked");
                                  // setState(() {
                                  //   searchStatus = !searchStatus;
                                  // });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 0.0,
                    ),
                    searchStatus
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 120.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Search',
                                contentPadding: EdgeInsets.only(top: 0.0),
                                prefixIcon:
                                    Icon(Icons.mail_outline, color: Colors.grey),
                                labelStyle: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                              onSaved: (String value) {
                                print('search - ' + value);
                              },
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: dataToBeRendered.length,
                    itemBuilder: (BuildContext context, int index) {
                      NotesModel notes = dataToBeRendered[index];
                      return Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.75,
                                  child: Text(notes.topic,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                    icon: Icon(Icons.more_vert), onPressed: () {})
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child: Text(notes.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                                Text(
                                  '\n' +
                                      DateUtil().formattedDate(
                                          DateTime.parse(notes.updatedat)
                                              .toLocal()),
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.0),
                            Divider()
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          )),
    );
  }
}
