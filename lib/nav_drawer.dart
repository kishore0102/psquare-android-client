import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String firstname = '';
  String lastname = '';
  String email = '';
  String fullname = '';

  @override
  _NavDrawerState() {
    setHeaderMessage();
  }

  void setHeaderMessage() async {
    // FlutterSecureStorage storage = new FlutterSecureStorage();
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    if (token == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed("login");
      });
    }
    // String sFirstname = await storage.read(key: 'firstname');
    // String sLastname = await storage.read(key: 'lastname');
    // String sEmail = await storage.read(key: 'email');
    String sFirstname = storage.getString("firstname");
    String sLastname = storage.getString("lastname");
    String sEmail = storage.getString("email");
    setState(() {
      firstname = sFirstname;
      lastname = sLastname;
      email = sEmail;
      fullname = sFirstname + ' ' + sLastname;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                fullname,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                email,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal),
              ),
            ],
          )),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () async {
              Navigator.of(context).pop();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Settings is coming soon...'),
                duration: const Duration(seconds: 5),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              Navigator.of(context).pop();
              // FlutterSecureStorage storage = FlutterSecureStorage();
              // await storage.deleteAll();
              SharedPreferences storage = await SharedPreferences.getInstance();
              storage.clear();
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed("login");
              });
            },
          ),
        ],
      ),
    );
  }
}
