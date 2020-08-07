import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:randonautica/addons_shop.dart';
import 'package:randonautica/getLocation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:toast/toast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:location_permissions/location_permissions.dart';

// camrng
import 'package:flutter/services.dart';

final String piAdd20Points = 'fatumbot.addons.c.add_20_points.v4';
final String piAdd20PointsOld = 'get_points';

final String piAdd60Points = 'fatumbot.addons.c.add_60_points.v4';
final String piAdd60PointsOld = 'get_more_points';

final String piInfinitePoints = 'fatumbot.addons.nc.infinite_points.v4';
final String piInfinitePointsOld = 'infinte_points';

final String piExtendRadius20km = 'fatumbot.addons.nc.extend_radius_20km.v4';
final String piExtendRadius20kmOld = 'extend_radius';

final String piMapsPack = 'fatumbot.addons.nc.maps_pack.v2';

final String piSkipWaterPack = 'fatumbot.addons.nc.skip_water_pack.v2';
final String piSkipWaterPackOld = 'skip_water_points';

final String piEverythingPack = 'fatumbot.addons.nc.everything_pack.v4';

class BotWebView extends StatelessWidget {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController webView;

  //
  // camrng
  //
  static const platform = const MethodChannel('com.randonautica.app');
  // flutter->ios(swift) (used to load the TrueEntropy Camera RNG view controller)
  Future<void> _navToCamRNG(int bytesNeeded) async {
    try {
      if (Platform.isAndroid) {
        // Flutter->Android (Java/Kotlin) (used to load an implementation of awasisto's camrng - https://github.com/awasisto/camrng/)
        await platform.invokeMethod('gotoCameraRNG', bytesNeeded*2);
      } else if (Platform.isIOS) {
        // Flutter->Android (Swift) (used to load the a camrng implementation done with vault12's TrueEntropy - https://github.com/vault12/TrueEntropy)
        await platform.invokeMethod('goToTrueEntropy', bytesNeeded);
      }
    } on PlatformException catch (e) {
      print("Failed to load CamRNG: '${e.message}'.");
    }
  }

  //
  // temporal rng
  //
  // flutter->ios(swift) (used to load the TrueEntropy Temporal RNG)
  Future<void> _navToTemporal(int bytesNeeded) async {
    try {
      await platform.invokeMethod('goToTemporal', bytesNeeded);
    } on PlatformException catch (e) {
      print("Failed: '${e.message}'.");
    }
  }

  //
  // get location
  //
  // flutter->ios(swift)/android. use native code, not webview/js to get the current location
  Future<void> _getCurrentLocation() async {
    Position position;
    var lat;
    var lon;
    var eval;
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(Duration(seconds: 10));
      print(position);
      lat = position.latitude?.toString();
      lon = position.longitude?.toString();
      var eval = "currentLocationCallback(" + lat + "," + lon + ");";
      webView.evaluateJavascript(eval);
    } on TimeoutException catch (_) {
      // A timeout occurred.
      await getLocation().then((value) => {
        lat = value.latitude,
        lon = value.longitude,
        lat = position.latitude?.toString(),
        lon = position.longitude?.toString(),
        eval = "currentLocationCallback(" + lat + "," + lon + ");",
        webView.evaluateJavascript(eval),
      });
    }
  }

  //
  // Add-ons shop
  //
  // C# Fatumbot -> javascript/html webbot client front end -> javascript/flutter bridge -> flutter native IAP screen
  Future<void> _navToShop(BuildContext context, String userId) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddonsShop(_available, products, purchases, userId))
    );

    if (result != null && result != '') {
      if (result.productID == piAdd20PointsOld || result.productID == piAdd60PointsOld) {
        // consume any left over unconsumed get points/get more points from the old pre-bot Android app
        print("[IAP] Consuming " + result.productID);
        _iap.consumePurchase(result);
        purchases.remove(result);
      }

      // flutter->javascript (send to bot the in-app purchase details)
      var json = _purchaseDetails2Json(result);
      var eval = "sendIAPToBot('" + json + "');";
      webView.evaluateJavascript(eval);
      Toast.show("Enabling feature...",
          context,
          duration: Toast.LENGTH_LONG,
          gravity:  Toast.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 88, 136, 226)
      );
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
    if (Platform.isAndroid) {
      await launch(url);
      return;
    }
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
    } else if (url.contains("maps/search")) { // with maps/search
      coords = coords.replaceAll("https://www.google.com/maps/search/?api=1&query=", "").replaceAll("&zoom=14", "");
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

  _initWebBot() async {
    String udid = await FlutterUdid.udid;
    webView.evaluateJavascript('initWebBot("${udid}");');
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
    OneSignal.shared.setLocationShared(false);

    var status = await OneSignal.shared.getPermissionSubscriptionState();
    webView.evaluateJavascript('sendPushIdToBot("${status.subscriptionStatus.userId}");');
  }

  _initLocationPermissions() async {
    GeolocationStatus geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
    print("location permission granted? ${geolocationStatus.value}");
    if (geolocationStatus.value == 0) {
      PermissionStatus permission = await LocationPermissions()
          .requestPermissions();
    }
  }

  ///
  /// In-app purchase stuff >>>
  /// https://fireship.io/lessons/flutter-inapp-purchases/
  ///
  /// Fatumbot User ID
  String userID = "";

  /// Is the API available on the device
  bool _available = false;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  Map<String, ProductDetails> products = new Map<String, ProductDetails>();

  /// Past purchases
  List<PurchaseDetails> purchases = [];

  /// Updates to purchases
  StreamSubscription _subscription;

  /// Get all products available for sale
  void _getProducts() async {
    Set<String> ids = Set.from([
      piAdd20Points,
      piAdd20PointsOld,
      piAdd60Points,
      piAdd60PointsOld,
      piInfinitePoints,
      piInfinitePointsOld,
      piExtendRadius20km,
      piExtendRadius20kmOld,
      piMapsPack,
      piSkipWaterPack,
      piSkipWaterPackOld,
      piEverythingPack]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    for (var product in response.productDetails) {
      if (product.id == piAdd20Points)
      {
        products[piAdd20Points] = product;
      }
      else if (product.id == piAdd60Points)
      {
        products[piAdd60Points] = product;
      }
      else if (product.id == piInfinitePoints)
      {
        products[piInfinitePoints] = product;
      }
      else if (product.id == piExtendRadius20km)
      {
        products[piExtendRadius20km] = product;
      }
      else if (product.id == piMapsPack)
      {
        products[piMapsPack] = product;
      }
      else if (product.id == piSkipWaterPack)
      {
        products[piSkipWaterPack] = product;
      }
      else if (product.id == piEverythingPack)
      {
        products[piEverythingPack] = product;
      }
    }
  }

  /// Gets past purchases
  void _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      print("[IAP] Past purchase: " + purchase.productID + " => status is: " + purchase.status.toString());
      InAppPurchaseConnection.instance.completePurchase(purchase, developerPayload: userID);
    }

    purchases = response.pastPurchases;
  }

  void _enablePurchase(PurchaseDetails purchase) {
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print("[IAP] Verified purchase of " + purchase.productID);

      // flutter->javascript (send to bot the in-app purchase details)
      var json = _purchaseDetails2Json(purchase);
      var eval = "sendIAPToBot('" + json + "');";
      webView.evaluateJavascript(eval);
      Toast.show("Thank you. Enabling now...",
          context,
          duration: Toast.LENGTH_LONG,
          gravity:  Toast.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 88, 136, 226)
      );

      for (PurchaseDetails oldPurchase in purchases) {
        if (oldPurchase.productID == purchase.productID) {
          // Update record in memory
          if (purchases.remove(oldPurchase)) {
            purchases.add(purchase);
          }
        }
      }
    }
  }

  String _purchaseDetails2Json(PurchaseDetails purchaseDetails) {
    return '{' +
        '"purchaseID":"' +             purchaseDetails.purchaseID + '",' +
        '"productID":"' +              purchaseDetails.productID + '",' +
//        '"localVerificationData":"' +  purchaseDetails.verificationData.localVerificationData + '",' + // This was causing issues on Android coz it was a Json object and wasn't escaping nicely
        '"serverVerificationData":"' + purchaseDetails.verificationData.serverVerificationData + '",' +
        '"source":"' +                 purchaseDetails.verificationData.source.toString() + '",' +
        '"transactionDate":"' +        purchaseDetails.transactionDate + '",' +
//            '"skPaymentTransaction":"' +   purchaseDetails.skPaymentTransaction + '",' +
//            '"billingClientPurchase":"' +  purchaseDetails.billingClientPurchase. + '",' +
        '"status":"' +                 purchaseDetails.status.toString() + '"' +
        '}';
  }

  _initIAP() async {
    // Check availability of In App Purchases
    _available = await _iap.isAvailable();

    if (_available) {
      await _getProducts();
      await _getPastPurchases();

      // Listen to new purchases
      _subscription = _iap.purchaseUpdatedStream.listen((purchaseDetailsList) {
        for (PurchaseDetails purchase in purchaseDetailsList) {
          print('[IAP] New purchase: ' + purchase.productID);
          _iap.completePurchase(purchase);
          _enablePurchase(purchase);
        }
        purchases.addAll(purchaseDetailsList);
      }, onDone: () {
        print("[IAP] onDone");
        _subscription.cancel();
      }, onError: (error) {
        // handle error here.
        print("[IAP] error: " + error);
        Toast.show("Purchase error: " + error,
            context,
            duration: Toast.LENGTH_LONG,
            gravity:  Toast.BOTTOM,
            textColor: Colors.red[600],
            backgroundColor: Colors.black
        );
      });
    }
  }

  ///
  /// <<< In-app purchase stuff
  ///
  BuildContext context;

  BotWebView();

  @override
  Widget build(BuildContext context) {
    this.context = context;

    var botUrl = "";
    if (Platform.isAndroid) {
//      botUrl = "https://devbot.randonauts.com/devbotdl.html?src=android";
      botUrl = "https://bot.randonauts.com/index3.html?src=android";
    } else if (Platform.isIOS) {
//      botUrl = "https://devbot.randonauts.com/devbotdl.html?src=ios";
      botUrl = "https://bot.randonauts.com/index3.html?src=ios";
    }

    _initLocationPermissions();

    _initIAP();

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
              JavascriptChannel(
                  name: 'flutterChannel_loadTemporalWithBytesNeeded',
                  onMessageReceived: (JavascriptMessage message) {
                    _navToTemporal(int.parse(message.message)); // open swift TrueEntropy Temporal RNG view
                  }),
              JavascriptChannel(
                  name: 'flutterChannel_loadNativeShop',
                  onMessageReceived: (JavascriptMessage message) {
                    userID = message.message;
                    _navToShop(context, message.message); // open Flutter in-app purchase shop
                  }),
              JavascriptChannel(
                  name: 'flutterChannel_getCurrentLocation',
                  onMessageReceived: (JavascriptMessage message) {
                    _getCurrentLocation();
                  }),
              // we can have more than one channels
            ]),
            onWebViewCreated: (WebViewController webViewController) {
              webView = webViewController;
              _controller.complete(webViewController);
            },
            onPageFinished: (String page) {
              if (page.contains("index2.html") || page.contains("localbot.html") || page.contains("devbotdl.html") || page.contains("index3.html")) {
                _initWebBot();
                _initOneSignal();
              }
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith("https://www.google.com/maps/place/") ||
                  request.url.startsWith("https://www.google.com/maps/search/") ||
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