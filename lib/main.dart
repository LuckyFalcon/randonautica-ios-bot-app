import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:randonautica/bot_webview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ///Include this in main() so purchases are enabled
    InAppPurchaseConnection.enablePendingPurchases();

    return MaterialApp(
        title: 'Fatumbot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BotWebView());
  }
}
