import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void decrementCounter() {
    if (counter > 0) {
      setState(() {
        counter--;
      });
    }
  }

  void refreshCounter() {
    setState(() {
      counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Psquare Homepage'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Just a number :',
                style: Theme.of(context).textTheme.bodyText1),
            Text('$counter', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'refreshButton',
            child: Icon(Icons.refresh),
            onPressed: refreshCounter,
          ),
          SizedBox(
            width: 10.0,
          ),
          FloatingActionButton(
            heroTag: ',removeButton',
            child: Icon(Icons.remove),
            onPressed: decrementCounter,
          ),
          SizedBox(
            width: 10.0,
          ),
          FloatingActionButton(
            heroTag: 'addButton',
            child: Icon(Icons.add),
            onPressed: incrementCounter,
          ),
        ],
      ),
    );
  }
}
