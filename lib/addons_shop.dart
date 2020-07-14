import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:randonautica/bot_webview.dart';

class AddonsShop extends StatefulWidget {
  bool available = false;
  Map<String, ProductDetails> products;
  List<PurchaseDetails> purchases;
  String userID;

  AddonsShop(bool available, Map<String, ProductDetails> products, List<PurchaseDetails> purchases, String userID) {
    this.available = available;
    this.products = products;
    this.purchases = purchases;
    this.userID = userID;
  }

  createState() => AddonsShopState(available, products, purchases, userID);
}

// https://fireship.io/lessons/flutter-inapp-purchases/
class AddonsShopState extends State<AddonsShop> {
  static double iapNameFontSize = 16;
  static double iapDescFontSize = 12;
  static double iapPriceFontSize = 15;
  static double iapBtnFontSize = 14;

  /// Is the API available on the device
  bool _available = false;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  Map<String, ProductDetails> _products;

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  BuildContext context;

  String _userID;

  AddonsShopState(bool available, Map<String, ProductDetails> products, List<PurchaseDetails> purchases, userID) {
    _available = available;
    _products = products;
    _purchases = purchases;
    _userID = userID;
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    print("[IAP] Purchasing " + prod.id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);

    if (prod.id == piAdd20Points || prod.id == piAdd60Points) {
      _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }

    Navigator.pop(context); // callback in bot_webview
  }

  void _enablePurchase(String productId) {
    print("[IAP] Enabling (probably already?) purchased " + productId);
    Navigator.pop(context, _hasPurchased(productId));
  }

  PurchaseDetails _hasPurchased(String productID) {
    productID = productID.replaceAll(productID.substring(productID.lastIndexOf('.v')), '');
    return _purchases.firstWhere( (purchase) => purchase.productID == productID, orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(_available ? 'Add-ons Shop' : 'Shop not available'),
        backgroundColor: Color.fromARGB(255, 88, 136, 226),
      ),
        body: Center(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.fromARGB(255, 88, 136, 226), Color.fromARGB(255, 75, 208, 222)])),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // piAdd20Points
                                Text(_products[piAdd20Points].title.substring(0, _products[piAdd20Points].title.contains("(") ? _products[piAdd20Points].title.indexOf("(") :  _products[piAdd20Points].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
//                                Text(_products[piAdd20Points].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                                Text(_products[piAdd20Points].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                                FlatButton(
                                  child: Text('BUY', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                                  color: Color.fromARGB(255, 75, 208, 222),
                                  onPressed: () => _buyProduct(_products[piAdd20Points]),
                                ),
                                ]
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // piAdd60Points
                                Text(_products[piAdd60Points].title.substring(0, _products[piAdd60Points].title.contains("(") ? _products[piAdd60Points].title.indexOf("(") :  _products[piAdd60Points].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
//                                Text(_products[piAdd60Points].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                                Text(_products[piAdd60Points].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                                FlatButton(
                                  child: Text('BUY', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                                  color: Color.fromARGB(255, 75, 208, 222),
                                  onPressed: () => _buyProduct(_products[piAdd60Points]),
                                ),
                              ]
                          ),
                          ]
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // piInfinitePoints
                          Text(_products[piInfinitePoints].title.substring(0, _products[piInfinitePoints].title.contains("(") ? _products[piInfinitePoints].title.indexOf("(") :  _products[piInfinitePoints].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
//                          Text(_products[piInfinitePoints].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                          Text(_products[piInfinitePoints].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                          FlatButton(
                            child: Text(null == _hasPurchased(piInfinitePoints) ? 'BUY' : 'ENABLE', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                            color: Color.fromARGB(255, 75, 208, 222),
                            onPressed: () => null == _hasPurchased(piInfinitePoints) ? _buyProduct(_products[piInfinitePoints]) : _enablePurchase(piInfinitePoints),
                          ),
                        ]
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // piMapsPack
                          Text(_products[piMapsPack].title.substring(0, _products[piMapsPack].title.contains("(") ? _products[piMapsPack].title.indexOf("(") :  _products[piMapsPack].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
                          Text(_products[piMapsPack].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                          Text(_products[piMapsPack].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                          FlatButton(
                            child: Text(null == _hasPurchased(piMapsPack) ? 'BUY' : 'ENABLE', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                            color: Color.fromARGB(255, 88, 136, 226),
                            onPressed: () => null == _hasPurchased(piMapsPack) ? _buyProduct(_products[piMapsPack]) : _enablePurchase(piMapsPack),
                          ),
                        ]
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // piSkipWaterPack
                          Text(_products[piSkipWaterPack].title.substring(0, _products[piSkipWaterPack].title.contains("(") ? _products[piSkipWaterPack].title.indexOf("(") :  _products[piSkipWaterPack].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
                          Text(_products[piSkipWaterPack].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                          Text(_products[piSkipWaterPack].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                          FlatButton(
                            child: Text(null == _hasPurchased(piSkipWaterPack) ? 'BUY' : 'ENABLE', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                            color: Color.fromARGB(255, 88, 136, 226),
                            onPressed: () => null == _hasPurchased(piSkipWaterPack) ? _buyProduct(_products[piSkipWaterPack]) : _enablePurchase(piSkipWaterPack),
                          ),
                        ]
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // piExtendRadius20km
                          Text(_products[piExtendRadius20km].title.substring(0, _products[piExtendRadius20km].title.contains("(") ? _products[piExtendRadius20km].title.indexOf("(") :  _products[piExtendRadius20km].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
                          Text(_products[piExtendRadius20km].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                          Text(_products[piExtendRadius20km].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                          FlatButton(
                            child: Text(null == _hasPurchased(piExtendRadius20km) ? 'BUY' : 'ENABLE', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                            color: Color.fromARGB(255, 88, 136, 226),
                            onPressed: () => null == _hasPurchased(piExtendRadius20km) ? _buyProduct(_products[piExtendRadius20km]) : _enablePurchase(piExtendRadius20km),
                          ),
                        ]
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // piEverythingPack
                          Text(_products[piEverythingPack].title.substring(0, _products[piEverythingPack].title.contains("(") ? _products[piEverythingPack].title.indexOf("(") :  _products[piEverythingPack].title.length), style: TextStyle(color: Colors.white, fontSize: iapNameFontSize, fontWeight: FontWeight.bold)),
                          Text(_products[piEverythingPack].description, style: TextStyle(color: Colors.white, fontSize: iapDescFontSize)),
                          Text(_products[piEverythingPack].price, style: TextStyle(color: Colors.white, fontSize: iapPriceFontSize)),
                          FlatButton(
                            child: Text(null == _hasPurchased(piEverythingPack) ? 'BUY' : 'ENABLE', style: TextStyle(color: Colors.white, fontSize: iapBtnFontSize)),
                            color: Color.fromARGB(255, 88, 136, 226),
                            onPressed: () => null == _hasPurchased(piEverythingPack) ? _buyProduct(_products[piEverythingPack]) : _enablePurchase(piEverythingPack),
                          ),
                        ]
                    ),
                  ],
                ),
              ),
            )));
  }
// Private methods go here

}