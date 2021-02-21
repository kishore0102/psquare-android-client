import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _otpformKey = GlobalKey<FormState>();

  final Map<String, dynamic> formData = {'email': null, 'password': null};
  String otpvalue = null;

  Map<String, dynamic> jsonResponse;

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  dynamic snackbar = '';

  @override
  _LoginState() {
    print("login constructor ran");
    checkForTokenAndRedirect();
  }

  void checkForTokenAndRedirect() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    if (token != null) {
      bool isTokenExpired = JwtDecoder.isExpired(token);
      if (isTokenExpired) {
        storage.clear();
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil("notes", (route) => false);
      }
    }
  }

  void registerOTP() async {
    Navigator.of(context).pop();
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
        'https://psquare-springboot-service.herokuapp.com/api/user/registerOTP';

    final Map<String, dynamic> registerData = {
      'email': formData['email'],
      'otp': otpvalue,
    };

    final response = await post(psquareURL,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(registerData));

    jsonResponse = jsonDecode(response.body);
    Navigator.of(context).pop();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              jsonResponse['message'],
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
  }

  void handleLoginSubmit() async {
    if (_formKey.currentState.validate()) {
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

      print("Processing...");
      _formKey.currentState.save();
      print(formData);
      final msg = jsonEncode(formData);

      String psquareURL =
          'https://psquare-springboot-service.herokuapp.com/api/user/login';
      Map<String, String> headers = {"Content-type": "application/json"};
      Response response = await post(psquareURL, headers: headers, body: msg);
      int statusCode = response.statusCode;
      print(statusCode);
      String body = response.body;
      print(body);
      jsonResponse = jsonDecode(response.body);
      if (statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("firstname", jsonResponse['user']['firtsname']);
        prefs.setString("lastname", jsonResponse['user']['lastname']);
        prefs.setString("email", jsonResponse['user']['email']);
        prefs.setString("status", jsonResponse['user']['status']);
        prefs.setString("token", jsonResponse['token']);
        String snackbarName = jsonResponse['user']['firtsname'];
        setState(() {
          snackbar = "Hello " + snackbarName;
        });

        Navigator.of(context)
            .pushNamedAndRemoveUntil("notes", (route) => false);
      } else if (jsonResponse['message'] ==
          'Account is not activated - OTP sent to respective mail') {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Account is not activated\nOTP sent to respective mail',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Form(
                  key: _otpformKey,
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value.length != 6) {
                        return 'Invalid OTP';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      otpvalue = value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Enter OTP"),
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Icon(
                      Icons.arrow_right_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_otpformKey.currentState.validate()) {
                        registerOTP();
                      }
                    },
                  ),
                ],
              );
            });
      } else {
        Navigator.of(context).pop();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  jsonResponse['message'],
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild.unfocus();
            }
          },
          child: Container(
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 45.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hello',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CenturyGothic',
                                        fontSize: 90.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '.',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CenturyGothic',
                                        fontSize: 90.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 155.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign in to your account',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CenturyGothic',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(top: 60.0, left: 25.0, right: 25.0),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: Icon(Icons.mail_outline,
                                    color: Colors.grey),
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
                                if (!validateEmail(value)) {
                                  return 'Please enter valid mail address';
                                }
                                return null;
                              },
                              onSaved: (String value) {
                                formData['email'] = value;
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.grey),
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
                                if (value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              onSaved: (String value) {
                                formData['password'] = value;
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    launch(
                                        "https://psquare-reactjs-client.herokuapp.com/forgotPassword");
                                  },
                                  child: Text(
                                    'Forgot your password',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'CenturyGothic',
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '?',
                                  style: TextStyle(fontFamily: 'Calibri'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(150.0),
                                color: Colors.black,
                                child: MaterialButton(
                                  minWidth: 200.0,
                                  height: 50,
                                  color: Colors.black,
                                  child: new Text('L O G I N',
                                      style: new TextStyle(
                                          fontSize: 17.0,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.white)),
                                  onPressed: () {
                                    handleLoginSubmit();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('New to Psquare',
                                      style: TextStyle(
                                          fontFamily: 'CenturyGothic')),
                                  Text(
                                    '? ',
                                    style: TextStyle(fontFamily: 'Calibri'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      launch(
                                          "https://psquare-reactjs-client.herokuapp.com/register");
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CenturyGothic',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
