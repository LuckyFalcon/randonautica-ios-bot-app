import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geolocator/geolocator.dart';


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

  _openMap(String url) async {
    var isStreetView = false;
    var isChain = false;
    var coords = url;
    if (url.contains("map_action=pano")) { // Street View URL
      isStreetView = true;
      coords = coords.replaceAll(
          "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=", "")
          .replaceAll("&fov=90&heading=235&pitch=10", "");
    } else if (url.contains("maps/dir")) { // Multiple points route
      // Get all points' coordinates from the URL
      isChain = true;
      coords = url.replaceAll("https://www.google.com/maps/dir/", "").replaceAll("+", ",").replaceAll("/", "+to:");
    } else { // Normal Maps URL
      coords = coords.replaceAll("https://www.google.com/maps/place/", "").replaceAll("+", ",");
      coords = coords.substring(0, coords.indexOf("@")-1);
    }

    var googleMapsUrl = url.replaceAll("https://", "comgooglemaps://");
    if (await canLaunch(googleMapsUrl)) {
      // Open in Google Maps
      if (isStreetView) {
        await launch("comgooglemaps://?center=" + coords + "&mapmode=streetview");
      } else if (isChain) { // Multiple points (using the Chains feature)
        var route = "comgooglemaps://?daddr=${coords}&directionsmode=driving".replaceAll("+to:&", "&");
        await launch(route);
      } else { // Normal map view for a point
        await launch("comgooglemaps://?q=${coords}&center=${coords}&zoom=14&mapmode=standard");
      }
    } else {
      if (isStreetView) {
        await launch(url); // Street View in Webview
      } else {
        // Fall back to Apple Maps by extracting our lat/long from the URL
        await launch("http://maps.apple.com/?daddr=" + coords);
      }
    }
  }

  _openSpotify(String url) async {
    var spotifyAppUrl = url.replaceAll("https://open.spotify.com/", "spotify://");
    if (await canLaunch(spotifyAppUrl)) {
      // Open in Spotify app
      await launch(spotifyAppUrl);
    } else {
      // Spotify online
      await launch(url);
    }
  }

  _openTwitter(String url) async {
    var twitterAppUrl = url.replaceAll("https://twitter.com/intent/tweet?text=", "twitter://post?message=");
    if (await canLaunch(twitterAppUrl)) {
      // Open in Twitter app
      await launch(twitterAppUrl);
    } else {
      // Twitter online
      await launch(url);
    }
  }

  _initOneSignal() async {
    OneSignal.shared.init(
        "da21a078-babf-4e22-a032-0ea22de561a7",
        iOSSettings: {
          OSiOSSettings.autoPrompt: true,
          OSiOSSettings.inAppLaunchUrl: true
        }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    webView.evaluateJavascript('sendPushIdToBot("${status.subscriptionStatus.userId}");');
  }

  _initLocationPermissions() async {
    GeolocationStatus geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
    print("location permission granted? ${geolocationStatus.value}");
  }

  BotWebView();

  @override
  Widget build(BuildContext context) {
    var botUrl = "";
    if (Platform.isAndroid) {
      botUrl = "https://devbot.randonauts.com/devbot.html?src=android";

      _initLocationPermissions();
    } else if (Platform.isIOS) {
      botUrl = "https://bot.randonauts.com/index.html?src=ios";
    }

    platform.setMethodCallHandler(_handleMethod); // for handling javascript->flutter callbacks
    return Scaffold(
//        appBar: AppBar(
//          title: Text("Randonautica"),
//        ),
        body: WebView(
            initialUrl: botUrl,
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: Set.from([
              JavascriptChannel(
                  name: 'flutterChannel_loadCamRNGWithBytesNeeded',
                  onMessageReceived: (JavascriptMessage message) {
                    _navToCamRNG(int.parse(message.message)); // open swift TrueEntropy Camera RNG view
                  }),
              // we can have more than one channels
            ]),
            onWebViewCreated: (WebViewController webViewController) {
              webView = webViewController;
              _controller.complete(webViewController);
            },
            onPageFinished: (String page) {
              if (page.contains("index.html")){
                _initOneSignal();
              }
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith("https://www.google.com/maps/place/") ||
                  request.url.startsWith("https://www.google.com/maps/dir/") ||
                  request.url.startsWith("https://www.google.com/maps/@?api=1") ||
                  request.url.startsWith("https://open.spotify.com/") ||
                  request.url.startsWith("https://twitter.com")
              ) {
                if (request.url.startsWith("https://www.google.com/maps")) {
                  _openMap(request.url);
                  return NavigationDecision.prevent;
                }

                if (request.url.startsWith("https://open.spotify.com/")) {
                  _openSpotify(request.url);
                  return NavigationDecision.prevent;
                }

                if (request.url.startsWith("https://twitter.com")) {
                  _openTwitter(request.url);
                  return NavigationDecision.prevent;
                }

                _launchURL(request.url);
                return NavigationDecision.prevent;
              } else if (!request.url.startsWith(botUrl)) {
                _launchURL(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }
        ));
  }
}