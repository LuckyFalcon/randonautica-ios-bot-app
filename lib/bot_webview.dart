import 'dart:async';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class BotWebView extends StatelessWidget {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  BotWebView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Randonautica"),
        ),
        body: WebView(
          initialUrl: "https://devbot.randonauts.com?src=ios",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ));
  }
}