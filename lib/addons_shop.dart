import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AddonsShop extends StatefulWidget {
  bool available = false;
  List<ProductDetails> products;
  List<PurchaseDetails> purchases;
  String userID;

  AddonsShop(bool available, List<ProductDetails> products, List<PurchaseDetails> purchases, String userID) {
    this.available = available;
    this.products = products;
    this.purchases = purchases;
    this.userID = userID;
  }

  createState() => AddonsShopState(available, products, purchases, userID);
}

// https://fireship.io/lessons/flutter-inapp-purchases/
class AddonsShopState extends State<AddonsShop> {
  /// Is the API available on the device
  bool _available = false;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  BuildContext context;

  String _userID;

  AddonsShopState(bool available, List<ProductDetails> products, List<PurchaseDetails> purchases, userID) {
    _available = available;
    _products = products;
    _purchases = purchases;
    _userID = userID;
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    print("[IAP] Purchasing " + prod.id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    Navigator.pop(context); // callback in bot_webview
  }

  void _enablePurchase(String productId) {
    print("[IAP] Enabling (probably already?) purchased " + productId);
    Navigator.pop(context, _hasPurchased(productId));
  }

  PurchaseDetails _hasPurchased(String productID) {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var prod in _products)

                    // UI if already purchased
                      if (_hasPurchased(prod.id) != null)
                        ...[
                          Text(prod.title, style: TextStyle(color: Colors.white, fontSize: 22)),
                          Text(prod.description, style: TextStyle(color: Colors.white, fontSize: 14)),
                          FlatButton(
                            child: Text('ENABLE', style: TextStyle(color: Colors.white, fontSize: 18)),
                            color: Color.fromARGB(255, 88, 136, 226),
                            onPressed: () => _enablePurchase(prod.id),
                          ),
                          Divider(
                            color: Colors.white,
                          ),
                        ]

                      // UI if NOT purchased
                      else
                      ...[
                        Text(prod.title, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(prod.description, style: TextStyle(color: Colors.white, fontSize: 14)),
                        Text(prod.price,
                            style: TextStyle(color: Colors.white, fontSize: 30)),
                        FlatButton(
                          child: Text('BUY', style: TextStyle(color: Colors.white, fontSize: 18)),
                          color: Color.fromARGB(255, 88, 136, 226),
                          onPressed: () => _buyProduct(prod),
                        ),
                        Divider(
                          color: Colors.white,
                        ),
                      ]
                  ],
                ),
              ),
            )));
  }
// Private methods go here

}