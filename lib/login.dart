import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final loginViewTitle = 'Psquare Login';
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {'email': null, 'password': null};

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  String psquareURL =
      'https://psquare-springboot-service.herokuapp.com/api/user/login';
  Map<String, String> headers = {"Content-type": "application/json"};

  void handleLoginSubmit() async {
    if (_formKey.currentState.validate()) {
      print("Processing...");
      _formKey.currentState.save();
      print(formData);
      final msg = jsonEncode(formData);
      Response response = await post(psquareURL, headers: headers, body: msg);
      int statusCode = response.statusCode;
      print(statusCode);
      String body = response.body;
      print(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loginViewTitle),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome back buddy...',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 15,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email address',
                        hintText: 'Enter Your email address',
                        prefixIcon: Icon(Icons.mail_outline),
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
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true,
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
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/forgotpassword',
                            arguments: '',
                          );
                        },
                        child: new Text('Forgot Password ?'),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          handleLoginSubmit();
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
