import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:psquare_android_client/models/NotesModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:psquare_android_client/nav_drawer.dart';
import 'package:psquare_android_client/notesitem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class DateUtil {
  static const DATE_FORMAT = 'MMM dd,yyyy hh:mm a';
  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class DateUtilDate {
  static const DATE_FORMAT = 'MMM dd,yyyy';
  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class DateUtilTime {
  static const DATE_FORMAT = 'hh:mm a';
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

  void redirectToNotesItem(String mode, NotesModel notes) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Notesitem(arguments: notes)));
  }

  void checkForTokenAndRedirect() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    try {
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil("login", (route) => false);
      } else {
        bool isTokenExpired = JwtDecoder.isExpired(token);
        if (isTokenExpired) {
          storage.clear();
          Navigator.of(context)
              .pushNamedAndRemoveUntil("login", (route) => false);
        } else {
          String parsedShared = storage.getString('notesdata');
          if (parsedShared != null) {
            final dynamic parsedShared0 =
                await jsonDecode(parsedShared).cast<Map<String, dynamic>>();
            List<NotesModel> parsedShared1 = await parsedShared0
                .map<NotesModel>((json) => NotesModel.fromJson(json))
                .toList();
            setState(() {
              dataToBeRendered = parsedShared1;
            });
          }

          String psquareURL =
              'https://psquare-springboot-service.herokuapp.com/api/notes/getNotes';
          final response = await get(psquareURL, headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });
          int statusCode = response.statusCode;
          final dynamic parsedResponse =
              await jsonDecode(response.body).cast<Map<String, dynamic>>();
          if (statusCode == 200) {
            List<NotesModel> parsedList = await parsedResponse
                .map<NotesModel>((json) => NotesModel.fromJson(json))
                .toList();
            storage.setString('notesdata', response.body);
            setState(() {
              dataToBeRendered = parsedList;
            });
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      parsedResponse['message'],
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
                            'Got it!',
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
          }
        }
      }
    } on Exception catch (e) {
      print(e);
      Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      appBar: AppBar(
        toolbarHeight: 75.0,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'scribbler.',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'CenturyGothic',
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu_outlined),
          color: Colors.black87,
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        actions: <Widget>[
          IconButton(
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
        ],
      ),
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
              height: 10.0,
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
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                redirectToNotesItem('update', notes);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: Text(notes.topic,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            IconButton(
                                disabledColor: null,
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onPressed: () {})
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                redirectToNotesItem('update', notes);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(notes.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                    )),
                              ),
                            ),
                            Text(
                              DateUtilDate().formattedDate(
                                      DateTime.parse(notes.updatedat)
                                          .toLocal()) +
                                  '\n' +
                                  DateUtilTime().formattedDate(
                                      DateTime.parse(notes.updatedat)
                                          .toLocal()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
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
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 5.0,
        splashColor: Colors.white,
        backgroundColor: Colors.white,
        onPressed: () {
          NotesModel newNote = new NotesModel(
            userid: '',
            seqnbr: null,
            topic: '',
            description: '',
            status: null,
            createdat:
                DateFormat('yyyy-mm-dd hh:mm:ss.sss').format(DateTime.now()),
            updatedat:
                DateFormat('yyyy-mm-dd hh:mm:ss.sss').format(DateTime.now()),
          );
          redirectToNotesItem('add', newNote);
        },
        tooltip: 'Increment',
        child: new Icon(
          Icons.add,
          color: Colors.black,
          size: 35.0,
        ),
      ),
    );
  }
}
