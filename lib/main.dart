import 'package:flutter/material.dart';
import 'package:randonautica/bot_webview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fatumbot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BotWebView());
  }
}
