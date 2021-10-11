import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<InitialScreen> {
  PurchaserInfo _purchaserInfo;
  Offerings _offerings;
  bool in_progress = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("UKPkbCPhUTlBvKqErfHvhwsKTqPJvhiY");
    await Purchases.addAttributionData(
        {}, PurchasesAttributionNetwork.facebook);
    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    Offerings offerings = await Purchases.getOfferings();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    print("Test");
    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;
      print(_offerings.toString());
      in_progress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (in_progress) {
      if (_purchaserInfo == null) {
        return Scaffold(
          appBar: AppBar(title: Text("RevenueCat Sample App")),
          body: Center(
            child: Text("Loading..."),
          ),
        );
      } else {
        var isPro = _purchaserInfo.entitlements.active.containsKey("Pro");
        if (isPro) {
          return CatsScreen();
        } else {
          return UpsellScreen(
            offerings: _offerings,
          );
        }
      }
    } else {
      return Container(
        color: Colors.white,
        child: Center(
        child: CircularProgressIndicator(),
      )
      );
    }
  }
}

class UpsellScreen extends StatelessWidget {
  final Offerings offerings;

  UpsellScreen({Key key, @required this.offerings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (offerings != null) {
      final offering = offerings.current;
      if (offering != null) {
        final monthly = offering.monthly;
        final lifetime = offering.lifetime;
        if (monthly != null) {
          return Scaffold(
              appBar: AppBar(title: Text("Upsell Screen")),
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[PurchaseButton(package: monthly)],
              )));
        }
      }
    }
    return Scaffold(
        appBar: AppBar(title: Text("Upsell Screen")),
        body: Center(
          child: Text("Loading 2..."),
        ));
  }
}

class PurchaseButton extends StatelessWidget {
  final Package package;

  PurchaseButton({Key key, @required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        try {
          print("Botón de compra presionado");
          PurchaserInfo purchaserInfo =
              await Purchases.purchasePackage(package);
          var isPro = purchaserInfo.entitlements.all["Pro"].isActive;
          if (isPro) {
            print("Compra exitosa");
            return CatsScreen();
          } else {
            print("Compra exitosa pero no se sabe si es PRO: "+purchaserInfo.entitlements.all["Pro"].toString());
          }
        } on PlatformException catch (e) {
          var errorCode = PurchasesErrorHelper.getErrorCode(e);
          if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
            print("User cancelled");
          } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
            print("User not allowed to purchase");
          }
        }
        return InitialScreen();
      },
      child: Text("Suscribirse - (${package.product.priceString})"),
    );
  }
}

class CatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Cats Screen")),
        body: Center(
          child: Text("User is pro"),
        ));
  }
}
