import 'package:flutter/material.dart';
import 'homepage.dart';
import 'login.dart';
import 'register.dart';
import 'forgotpassword.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
      case '/':
        return MaterialPageRoute(builder: (_) => Homepage());
      case '/register':
        return MaterialPageRoute(builder: (_) => Register());
      case '/forgotpassword':
        return MaterialPageRoute(builder: (_) => ForgotPassword());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
