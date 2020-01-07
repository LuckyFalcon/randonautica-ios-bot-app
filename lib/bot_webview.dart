import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

// camrng
import 'package:flutter/services.dart';

class BotWebView extends StatelessWidget {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController webView;

  //
  // camrng
  //
  static const platform = const MethodChannel('com.randonautica.app');
  // flutter->ios(swift) (used to load the TrueEntropy Camera RNG view controller
  Future<void> _navToCamRNG(int bytesNeeded) async {
    try {
      await platform.invokeMethod('goToTrueEntropy', bytesNeeded);
    } on PlatformException catch (e) {
      print("Failed: '${e.message}'.");
    }
  }
  // ios(swift)->flutter (used as a callback so we are given the GID of entropy generated and uploaded to the libwrapper)
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "gid":
        debugPrint(call.arguments);
        // flutter->javascript (send to bot the gid)
        webView.evaluateJavascript('sendGidToBot("${call.arguments}");');
        return new Future.value("");
    }
  }

  _launchURL(String url) async {
      await launch(url);
  }

  BotWebView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: Text("Randonautica"),
//        ),
        body: WebView(
          initialUrl: "https://devbot.randonauts.com/devbot.html?src=ios",
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'flutterChannel_loadCamRNGWithBytesNeeded',
                onMessageReceived: (JavascriptMessage message) {
                  platform.setMethodCallHandler(_handleMethod); // for gid callback
                  _navToCamRNG(int.parse(message.message)); // open swift TrueEntropy Camera RNG view
                }),
            // we can have more than one channels
          ]),
          onWebViewCreated: (WebViewController webViewController) {
            webView = webViewController;
            _controller.complete(webViewController);
          },
          navigationDelegate: (NavigationRequest request) {
            if (!request.url.startsWith('https://devbot.randonauts.com/devbot.html')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          }
        ));
  }
}