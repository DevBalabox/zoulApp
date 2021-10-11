import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/home_user.dart';
import 'package:zoul/payment_methods.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SuscriptionPage extends StatefulWidget {
  String user_data;
  String token;
  SuscriptionPage(this.user_data, this.token);

  @override
  _SuscriptionPage createState() => _SuscriptionPage();
}

class _SuscriptionPage extends State<SuscriptionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _selectedCard;
  String payment_method_id;
  String error_dialog = "";
  bool action_in_progress = false;
  bool subscribed_badge = false;
  String chosen_card_img = "";

  String user_id;
  String user_data;
  String token;
  String subscription_status;
  String end_of_cicle;
  String subscription_title;

  bool loading_lists = false;
  bool fetch_error = false;

  List<Map<String, dynamic>> listaTarjetas;

  //Variables de Revenuecat
  PurchaserInfo _purchaserInfo;
  Offerings _offerings;
  bool in_progress = true;
  var isPro;
  String subscription_price = "";
  //Fin variables de revenuecat

  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');

      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          break;
        case "AppLifecycleState.suspending":
          _lastLifecyleState = AppLifecycleState.detached;
          break;
        default:
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getStoredData(context);
    user_id = jsonDecode(widget.user_data)["user_id"] ?? null;
    user_data = widget.user_data;
    token = widget.token;
    //subscription_status = jsonDecode(widget.user_data)["subscription_status"] ?? null;
    end_of_cicle = jsonDecode(widget.user_data)["end_of_cicle"] ?? null;
    print(subscription_status);
    setUpSubscription();
    handleAppLifecycleState();
    StripePayment.setOptions(
        StripeOptions(publishableKey: stripe_publishable_key));
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(revenuecat_key, appUserId: user_id);
    await Purchases.addAttributionData(
        {}, PurchasesAttributionNetwork.facebook);
    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    Offerings offerings = await Purchases.getOfferings();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    //print("Test");
    setState(() {
      _purchaserInfo = purchaserInfo;
      print(_purchaserInfo.toString());
      _offerings = offerings;
      print(_offerings.toString());
      if (_offerings != null) {
        final offering = _offerings.current;
        if (offering != null) {
          final monthly = offering.monthly;
          if (monthly != null) {
            subscription_price = monthly.product.priceString;
          }
        }
      }
      in_progress = false;
      isPro = _purchaserInfo.entitlements.active.containsKey("Pro");
      toggleSubscription();
    });
  }

  toggleSubscription() {
    setState(() {
      if (isPro) {
        subscription_status = "active";
      } else {
        subscription_status = "inactive";
      }
      setUpSubscription();
    });
  }

  getStoredData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_data = (prefs.getString('user_data') ?? null);
    setState(() {
      user_id = jsonDecode(user_data)["user_id"] ?? null;
      token = widget.token;
      //subscription_status = jsonDecode(user_data)["subscription_status"] ?? null;
      end_of_cicle = jsonDecode(user_data)["end_of_cicle"] ?? null;
      setUpSubscription();
      print(subscription_status);
    });
  }

  Widget subscriptionBadge(BuildContext context) {
    switch (subscription_status) {
      case "active":
        return Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.deepPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 0.5, //extend the shadow
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  3.0, // Move to bottom 10 Vertically
                ),
              )
            ],
          ),
          child: Icon(Icons.star, color: Colors.white),
        );
        break;
      case "active_non_renewable":
        return Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.deepPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 0.5, //extend the shadow
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  3.0, // Move to bottom 10 Vertically
                ),
              )
            ],
          ),
          child: Icon(Icons.star, color: Colors.white),
        );
        break;
      case "inactive":
        return Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.white),
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [Colors.yellow, Colors.orangeAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 5.0, // soften the shadow
                  spreadRadius: 0.5, //extend the shadow
                  offset: Offset(
                    0.0, // Move to right 10  horizontally
                    3.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
              color: Colors.orange),
          child: Icon(Icons.star, color: Colors.white),
        );
        break;
    }
  }

  Widget actionButton(BuildContext context) {
    switch (subscription_status) {
      case "active":
        return SizedBox();
        //Text("Si deseas cancelar tu suscripción, lo puedes hacer desde los ajustes ");
        /* RaisedButton(
          onPressed: () {
            _cancelSubscriptionDialog(context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(0.0),
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0)),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: double.infinity, minHeight: 40.0),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Cancelar mi suscripción",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ); */
        break;
      case "active_non_renewable":
        return RaisedButton(
          onPressed: () {},
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(0.0),
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey, Colors.grey],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0)),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: double.infinity, minHeight: 40.0),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Suscripción cancelada",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case "inactive":
        if (_offerings != null) {
          final offering = _offerings.current;
          if (offering != null) {
            final monthly = offering.monthly;
            final lifetime = offering.lifetime;
            if (monthly != null) {
              return RaisedButton(
                onPressed: loading_lists
                    ? () {}
                    : () async {
                        try {
                          print("Botón de compra presionado");
                          setState(() {
                            loading_lists = true;
                          });
                          PurchaserInfo purchaserInfo =
                              await Purchases.purchasePackage(monthly);
                          var isPro =
                              purchaserInfo.entitlements.all["Pro"].isActive;
                          if (isPro) {
                            print("Compra exitosa");
                            goHome(context);
                          }
                          /* else {
                            print("Compra exitosa pero no se sabe si es PRO: " +
                                purchaserInfo.entitlements.all["Pro"]
                                    .toString());
                            _displaySnackBar(context,
                                "No tienes permiso para realizar esta compra.");
                          } */
                          setState(() {
                            loading_lists = false;
                          });
                        } on PlatformException catch (e) {
                          var errorCode = PurchasesErrorHelper.getErrorCode(e);
                          if (errorCode ==
                              PurchasesErrorCode.purchaseCancelledError) {
                            print("User cancelled");
                            //_displaySnackBar(context, "Cancelado.");
                          } else if (errorCode ==
                              PurchasesErrorCode.purchaseNotAllowedError) {
                            print("User not allowed to purchase");
                            _displaySnackBar(context,
                                "No tienes permiso para realizar esta compra.");
                          }
                          setState(() {
                            loading_lists = false;
                          });
                        }
                        //return InitialScreen();
                      },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: secondary_button_gradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, minHeight: 40.0),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        loading_lists
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : Text(
                                "Suscribirme ahora",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        }
        break;
    }
  }

  setUpSubscription() {
    switch (subscription_status) {
      case "active":
        setState(() {
          subscribed_badge = true;
          subscription_title = "¡Tu suscripción Zoul se encuentra activa!";
        });
        break;
      case "active_non_renewable":
        setState(() {
          subscribed_badge = true;
          subscription_title =
              "¡Tu suscripción Zoul está cancelada, pero aún tendrás acceso al contenido hasta el " +
                  end_of_cicle +
                  "!";
        });
        break;
      case "inactive":
        setState(() {
          subscription_title =
              "Adquiere tu suscripción por ${subscription_price} al mes";
        });
        break;
    }
  }

  Future<http.Response> loadCardList(BuildContext context, openDialog) async {
    setState(() {
      loading_lists = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "get_stripe_customers_cards",
        "user_id": user_id
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          listaTarjetas = List<Map<String, dynamic>>.from(
              jsonResponse[1]['metodos_de_pago']);
          if (openDialog) _subscribeDialog(context);
        });
        print(jsonResponse[0]['message'].toString());
        print(listaTarjetas);
      } else {
        setState(() {
          loading_lists = false;
          fetch_error = true;
          listaTarjetas = [];
        });
        if (openDialog) _subscribeDialog(context);
        //_displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        loading_lists = false;
        fetch_error = true;
      });
      _displaySnackBar(context, "No se han podido cargar las tarjetas.");
      //throw Exception('Failed to load list.');
    }
  }

  getNetImgLink(link) {
    if (link == null) {
      link =
          "https://icons.iconarchive.com/icons/designbolts/credit-card-payment/256/Master-Card-Blue-icon.png";
    }
    return link;
  }

  triggerSubscription() {
    setState(() {
      subscribed_badge = true;
    });
  }

  triggerUnSubscription() {
    setState(() {
      subscribed_badge = false;
    });
  }

  goHome(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeUser()),
        (Route<dynamic> route) => false);
  }

  getCardImg(brand) {
    String brand_img;

    switch (brand) {
      case 'Visa':
        brand_img = "img/visa.png";
        break;

      case 'MasterCard':
        brand_img = "img/mastercard.png";
        break;

      case 'American Express':
        brand_img = "img/amex.png";
        break;

      default:
        brand_img = "img/card.png";
        break;
    }

    return brand_img;
  }

  Future<String> _subscribeDialog(context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          Future<http.Response> subscribe(context) async {
            setState(() {
              action_in_progress = true;
            });
            final http.Response response = await http.post(
              api_url,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                "action": "create_subscription",
                "user_id": user_id,
                "card_id": payment_method_id
              }),
            );
            var jsonResponse = jsonDecode(response.body);
            print(jsonEncode(jsonResponse));
            if (response.statusCode == 200) {
              if (jsonResponse[0]['status'] == "true") {
                setState(() {
                  action_in_progress = false;
                });
                Navigator.pop(context);
                goHome(context);
              } else {
                setState(() {
                  action_in_progress = false;
                  error_dialog = jsonResponse[0]['message'];
                });
              }
            } else {
              setState(() {
                action_in_progress = false;
                error_dialog =
                    "No se ha podido completar tu suscripción, inténtalo de nuevo.";
              });
              throw Exception('Failed tosubscribe.');
            }
          }

          trySubscription() {
            /* bool successful_subscription = true;

            if (successful_subscription) {
              setState(() {
                action_in_progress = true;
              });
              Timer(Duration(seconds: 2), () {
                Navigator.of(context).pop();
                setState(() {
                  action_in_progress = false;
                });
                triggerSubscription();
              });
            } else {
              setState(() {
                action_in_progress = true;
              });
              Timer(Duration(seconds: 2), () {
                setState(() {
                  action_in_progress = false;
                  error_dialog = "Hubo un error, reinténtalo";
                });
              });
            } */
            subscribe(context);
          }

          return loading_lists
              ? Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: const CircularProgressIndicator(),
                  ),
                )
              : action_in_progress
                  ? AlertDialog(
                      title: Text('Procesando pago'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        ],
                      ),
                    )
                  : AlertDialog(
                      title: Text('Método de pago'),
                      content: listaTarjetas.length == 0
                          ? Text(
                              "Aún no tienes tarjetas registradas, guarda una tarjeta nueva para poder pagar tu suscripción",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DropdownButton(
                                  hint: _selectedCard == null
                                      ? Text('Selecciona tu método de pago')
                                      : Row(
                                          children: <Widget>[
                                            Image.asset(
                                              getCardImg(
                                                  listaTarjetas[_selectedCard]
                                                      ['brand']),
                                              width: 27,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text("****" +
                                                listaTarjetas[_selectedCard]
                                                    ['last4'])
                                          ],
                                        ),
                                  isExpanded: true,
                                  iconSize: 30.0,
                                  items: listaTarjetas.map((item) {
                                    return new DropdownMenuItem(
                                      child: new Row(
                                        children: <Widget>[
                                          Image.asset(
                                            getCardImg(item['brand']),
                                            width: 27,
                                          ),
                                          SizedBox(
                                            width: 7,
                                          ),
                                          Text("****" + item['last4'])
                                        ],
                                      ),
                                      value: listaTarjetas.indexOf(item),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(
                                      () {
                                        _selectedCard = val;
                                        chosen_card_img =
                                            listaTarjetas[_selectedCard]
                                                ["brand"];
                                        //print(chosen_card_img);
                                        payment_method_id =
                                            listaTarjetas[_selectedCard]["id"];
                                      },
                                    );
                                    print(_selectedCard.toString() +
                                        ", " +
                                        payment_method_id);
                                  },
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Los cargos se harán automáticamente al método de pago seleccionado cada mes a partir de tu suscripción.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                error_dialog != null
                                    ? Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          error_dialog,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : null,
                              ],
                            ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            setState(() {
                              action_in_progress = false;
                              error_dialog = "";
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        listaTarjetas.length == 0
                            ? FlatButton(
                                child: Text('Registrar tarjeta'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentMethods(
                                              user_data, token)));
                                },
                              )
                            : FlatButton(
                                child: Text('Suscribirme ahora'),
                                onPressed: () {
                                  if (payment_method_id != null &&
                                      payment_method_id != "") {
                                    trySubscription();
                                  } else {
                                    setState(() {
                                      error_dialog =
                                          "Debes seleccionar un método de pago.";
                                    });
                                  }
                                },
                              ),
                      ],
                    );
        });
      },
    );
  }

  Future<String> _cancelSubscriptionDialog(context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          Future<http.Response> unSubscribe(context) async {
            setState(() {
              action_in_progress = true;
            });
            final http.Response response = await http.post(
              api_url,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                "action": "cancel_subscription",
                "user_id": user_id
              }),
            );
            var jsonResponse = jsonDecode(response.body);
            print(jsonEncode(jsonResponse));
            if (response.statusCode == 200) {
              if (jsonResponse[0]['status'] == "true") {
                setState(() {
                  action_in_progress = false;
                });
                Navigator.pop(context);
                goHome(context);
              } else {
                setState(() {
                  action_in_progress = false;
                  error_dialog = jsonResponse[0]['message'];
                });
              }
            } else {
              setState(() {
                action_in_progress = false;
                error_dialog =
                    "No se ha podido cancelar tu suscripción, inténtalo de nuevo ó contacta a soporte.";
              });
              throw Exception('Failed tosubscribe.');
            }
          }

          tryUnSubscription() {
            /* bool successful_subscription = true;

            if (successful_subscription) {
              setState(() {
                action_in_progress = true;
              });
              Timer(Duration(seconds: 2), () {
                Navigator.of(context).pop();
                setState(() {
                  action_in_progress = false;
                });
                triggerUnSubscription();
              });
            } else {
              setState(() {
                action_in_progress = true;
              });
              Timer(Duration(seconds: 2), () {
                setState(() {
                  action_in_progress = false;
                  error_dialog = "Hubo un error, reinténtalo";
                });
              });
            } */
            unSubscribe(context);
          }

          return action_in_progress
              ? AlertDialog(
                  title: Text('Procesando pago'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Center(
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    ],
                  ),
                )
              : AlertDialog(
                  title: Text('Cancelar suscripción'),
                  contentPadding:
                      EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Si cancelas tu suscripción ya no tendrás acceso al contenido cuando tu último ciclo termine. ¿Seguro que quieres cancelar tu suscripción?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      error_dialog != null
                          ? Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                error_dialog,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : null,
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        setState(() {
                          action_in_progress = false;
                          error_dialog = "";
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Desuscribirme'),
                      onPressed: () {
                        tryUnSubscription();
                      },
                    ),
                  ],
                );
        });
      },
    );
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0),
      elevation: 0,
      title: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Suscripción"),
          )
        ],
      ),
    );

    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        appBar: appBar,
        backgroundColor: Color(0xFF114a9e),
        body: in_progress
            ? loader()
            : _purchaserInfo == null
                ? loader()
                : Container(
                    height: MediaQuery.of(context).size.height +
                        appBar.preferredSize.height +
                        MediaQuery.of(context).padding.top,
                    color: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              width: double.infinity,
                              height: 790,
                              color: Colors.white,
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  subscriptionBadge(context),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text("Zoul PRO", style: TextStyle(
                                    color: Color(0xFF0070c9),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800
                                  ),),
                                  Text(
                                    subscription_title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      /* Container(
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.info,
                                          size: 15,
                                          color: Colors.grey[600],
                                        ),
                                      ), */
                                      Flexible(
                                        child: Text(
                                          "(Tu suscripción será renovada automáticamente cada mes a partir de tu fecha de inicio, y puedes cancelar en cualquier momento.)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "En Zoul buscamos ayudarte a que logres tus objetivos dándote acceso a las mejores rutinas por coaches especializados, así como una experiencia única.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      go_to_link(privacy_link);
                                    },
                                    child: Text(
                                        "Terminos del servicio y aviso de privacidad",
                                        style: TextStyle(
                                            color: Color(0xFF0070c9),
                                            fontWeight: FontWeight.w800)),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  /* Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.lock,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            "Pago seguro con",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Image.asset("img/stripe-2.png",
                                          width: 230),
                                    ],
                                  ), */
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 50,
                                    margin: EdgeInsets.only(
                                        bottom: 20, left: 10, right: 10),
                                    child: actionButton(context),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox.fromSize(
                              size: preferredSize,
                              child: new LayoutBuilder(
                                  builder: (context, constraint) {
                                final width = constraint.maxWidth * 8;
                                return new ClipRect(
                                  child: new OverflowBox(
                                    maxHeight: double.infinity,
                                    maxWidth: double.infinity,
                                    child: new SizedBox(
                                      width: width,
                                      height: width,
                                      child: new Padding(
                                        padding: new EdgeInsets.only(
                                            bottom: width / 2 -
                                                preferredSize.height / 2),
                                        child: new DecoratedBox(
                                          decoration: new BoxDecoration(
                                            gradient: new LinearGradient(
                                                colors: main_gradient,
                                                begin: const FractionalOffset(
                                                    0.0, 0.5),
                                                end: const FractionalOffset(
                                                    0.0, 1.5),
                                                stops: [0.0, 1.0],
                                                tileMode: TileMode.clamp),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Container(
                              height: 200,
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  bottom: 15,
                                  top: appBar.preferredSize.height +
                                      MediaQuery.of(context).padding.top +
                                      20),
                              decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(width: 2, color: Colors.white),
                                gradient: new LinearGradient(
                                    colors: [Colors.blue, Colors.deepPurple],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(2.0, 1.0),
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp),
                                image: DecorationImage(
                                  image: AssetImage("img/featured2.jpg"),
                                  colorFilter: new ColorFilter.mode(
                                      Colors.black.withOpacity(1.0),
                                      BlendMode.dstATop),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 0.5, //extend the shadow
                                    offset: Offset(
                                      0.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(280.0);
}
