import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:randonautica/Introduction.dart';
import 'package:randonautica/bot_webview.dart';

import 'Randonaut.dart';
import 'api/Sizes.dart';
import 'dashboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Randonautica',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Introduction());
  }
}

//Set app state
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}


class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  //Based on the selected Navigation item
  int _selectedIndex = 0;

  //Returns the widget based on the selected Navigation item
  widgetSelector(int _selectedIndex) {
    switch(_selectedIndex){
      case 0: { //Home
        return DashBoardPage();

      }
        break;
      case 1: { //Bot
        return BotWebView();
      }
        break;
      case 2: { //Attractors
        //Return something
        return Randonaut();

      }
        break;
    }
  }

  Future<void> getAttractors(String instance) async {
    var postResult = await getSizes(3000);
    print(postResult);

  }


  //Set selctedIndex based on the selected Navigation item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //App overlay with bottomNavigation bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randonautica'),
      ),
      body: Container(
          child: widgetSelector(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Bot'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('Attractors'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
