import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/extras/storage.dart';

class PaymentMethods extends StatefulWidget {
  String user_data;
  String token;
  PaymentMethods(this.user_data, this.token);
  @override
  _PaymentMethods createState() => _PaymentMethods();
}

class _PaymentMethods extends State<PaymentMethods> with ChangeNotifier {
  List<Map<String, dynamic>> listaTarjetas;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PaymentMethod _paymentMethod = PaymentMethod();
  final _cardForm = GlobalKey<FormState>();

  bool active_loader = false;
  bool loading_lists = true;
  bool fetch_error = false;

  String user_id = "";
  String user_data;
  String token = "";

  String error_message = "";

  @override
  void initState() {
    super.initState();
    getAllData();
    //user_data = widget.user_data;
    print(token);

    StripePayment.setOptions(
        StripeOptions(publishableKey: stripe_publishable_key));
  }

  Future getAllData() async {
    String get_data = await getUserDataArray(context);
    String get_token = await getUserToken(context);

    setState(() {
      if (get_data != null) {
        user_data = get_data;
      }

      if (get_token != null) {
        token = get_token;
      }

      user_id = jsonDecode(user_data)["user_id"] ?? null;
    });
    loadCardList(context);
  }

  Future<http.Response> loadCardList(BuildContext context) async {
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
        });
        //print(jsonResponse[0]['message'].toString());
      } else {
        setState(() {
          loading_lists = false;
          fetch_error = true;
          listaTarjetas = [];
        });
        _displaySnackBar(context, "Aún no has registrado ninguna tarjeta");
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

  /* TextEditingController nameController =
      new TextEditingController(text: "Javier Guerrero");
  TextEditingController zipController =
      new TextEditingController(text: "62500");
  TextEditingController cardNumberController =
      new TextEditingController(text: "378282246310005");
  TextEditingController expYearController =
      new TextEditingController(text: "24");
  TextEditingController expMonthController =
      new TextEditingController(text: "11");
  TextEditingController cvvController = new TextEditingController(text: "1234"); */

  TextEditingController nameController = new TextEditingController(text: "");
  TextEditingController zipController = new TextEditingController(text: "");
  TextEditingController cardNumberController =
      new TextEditingController(text: "");
  TextEditingController expYearController = new TextEditingController(text: "");
  TextEditingController expMonthController =
      new TextEditingController(text: "");
  TextEditingController cvvController = new TextEditingController(text: "");

  Future<String> showCardForm(context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          void setError(dynamic error) {
            /* scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString()))); */

            setState(() {
              active_loader = false;
              error_message = error.toString();
            });
            print(error.toString());
          }

          _displaySnackBar(BuildContext context, String message) {
            final snackBar = SnackBar(content: Text(message));
            _scaffoldKey.currentState.showSnackBar(snackBar);
          }

          Future<http.Response> storeCard(context, card_token) async {
            setState(() {
              active_loader = true;
            });
            final http.Response response = await http.post(
              api_url,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                "action": "add_new_card",
                "user_id": user_id,
                "card_token": card_token,
                "token": token
              }),
            );
            var jsonResponse = jsonDecode(response.body);
            print(jsonEncode(jsonResponse));
            if (response.statusCode == 200) {
              if (jsonResponse[0]['status'] == "true") {
                setState(() {
                  active_loader = false;
                });
                Navigator.pop(context);
                _displaySnackBar(context, "Se agregó la tarjeta con éxito");
                loadCardList(context);
              } else {
                setState(() {
                  active_loader = false;
                  error_message = "Intenta de nuevo: " +
                      jsonResponse[0]['message'].toString();
                });
              }
            } else {
              setState(() {
                active_loader = false;
                error_message =
                    "No se ha podido añadir la tarjeta, inténtalo de nuevo.";
              });
              _displaySnackBar(context,
                  "No se ha podido añadir la tarjeta, inténtalo de nuevo.");
              throw Exception('Failed to add card.');
            }
          }

          return active_loader
              ? AlertDialog(
                  title: Text('Guardando tarjeta'),
                  content: Container(
                    height: 100,
                    child: loader(),
                  ))
              : AlertDialog(
                  title: Text('Añadira nueva tarjeta'),
                  content: Container(
                      height: 320,
                      width: 200,
                      child: ListView(children: <Widget>[
                        Form(
                            key: _cardForm,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                        labelText:
                                            'Nombre del tarjetahabiente'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Campo obligatorio';
                                      } else {
                                        setState(() {
                                          nameController =
                                              TextEditingController(
                                                  text: value);
                                        });
                                      }
                                      return null;
                                    }),
                                TextFormField(
                                    controller: zipController,
                                    decoration: InputDecoration(
                                        labelText: 'Código postal'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Campo obligatorio';
                                      } else {
                                        setState(() {
                                          zipController = TextEditingController(
                                              text: value);
                                        });
                                      }
                                      return null;
                                    }),
                                TextFormField(
                                    controller: cardNumberController,
                                    decoration: InputDecoration(
                                        labelText: 'Número de tarjeta'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Campo obligatorio';
                                      } else {
                                        setState(() {
                                          cardNumberController =
                                              TextEditingController(
                                                  text: value);
                                        });
                                      }
                                      return null;
                                    }),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                          controller: expMonthController,
                                          keyboardType: TextInputType.number,
                                          decoration:
                                              InputDecoration(labelText: 'Mes'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Campo obligatorio';
                                            } else {
                                              setState(() {
                                                expMonthController =
                                                    TextEditingController(
                                                        text: value);
                                              });
                                            }
                                            return null;
                                          }),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                          controller: expYearController,
                                          keyboardType: TextInputType.number,
                                          decoration:
                                              InputDecoration(labelText: 'Año'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Campo obligatorio';
                                            } else {
                                              setState(() {
                                                expYearController =
                                                    TextEditingController(
                                                        text: value);
                                              });
                                            }
                                            return null;
                                          }),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                          controller: cvvController,
                                          keyboardType: TextInputType.number,
                                          decoration:
                                              InputDecoration(labelText: 'CVV'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Campo obligatorio';
                                            } else {
                                              setState(() {
                                                cvvController =
                                                    TextEditingController(
                                                        text: value);
                                              });
                                            }
                                            return null;
                                          }),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                error_message != ""
                                    ? Text(
                                        error_message,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      )
                                    : SizedBox(),
                                SizedBox(
                                  height: 5,
                                ),
                                RaisedButton(
                                  child: Text(
                                    'Guardar tarjeta',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: main_action_color,
                                  onPressed: () {
                                    if (_cardForm.currentState.validate()) {
                                      setState(() {
                                        active_loader = true;
                                      });
                                      final CreditCard testCard = CreditCard(
                                          name: nameController.text,
                                          addressZip: zipController.text,
                                          number: cardNumberController.text,
                                          expMonth: int.parse(
                                              expMonthController.text),
                                          expYear:
                                              int.parse(expYearController.text),
                                          cvc: cvvController.text);

                                      StripePayment.createTokenWithCard(
                                              testCard)
                                          .then((token) {
                                        print(token.tokenId);

                                        storeCard(context, token.tokenId)
                                            .then((value) => () {
                                                  setState(() {
                                                    active_loader = false;
                                                  });
                                                });
                                      }).catchError(setError);
                                    }
                                  },
                                )
                              ],
                            )),
                      ])),
                );
        });
      },
    );
  }

  Future<http.Response> removeCard(context, card_id) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "remove_card",
        "user_id": user_id,
        "card_id": card_id
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonEncode(jsonResponse));
    if (response.statusCode == 200) {
      if (!jsonResponse[0]['status'] == "true") {
        _displaySnackBar(context, "Hubo un problema para eliminar la tarjeta");
      }
    } else {
      _displaySnackBar(
          context, "No se ha podido eliminar la tarjeta, inténtalo de nuevo.");
      throw Exception('Failed to remove card.');
    }
  }

  addNewCard() {
    /* StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      print('Received ${jsonEncode(paymentMethod)}');
      setState(() {
        _paymentMethod = paymentMethod;
      });
    }).catchError(setError); */
    showCardForm(context);
  }

  triggerCardRemoval(card_id) {
    removeCard(context, card_id);
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

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: zoul_primary_color.withOpacity(0.6),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Mis tarjetas"),
          ),
          Image.asset(
            "img/isotipo-w.png",
            height: 30,
          )
        ],
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      appBar: appBar,
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: appBar.preferredSize.height +
                MediaQuery.of(context).padding.top,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [zoul_secondary_color, zoul_primary_color],
                  begin: const FractionalOffset(0.5, 1.0),
                  end: const FractionalOffset(0.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              image: DecorationImage(
                image: AssetImage("img/bg-2.jpg"),
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.0), BlendMode.dstATop),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: loading_lists
                  ? loader()
                  : listaTarjetas.length == 0
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.credit_card,
                                  size: 35,
                                  color: zoul_primary_color,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("¡Aún no tienes tarjetas registradas!")
                              ]),
                        )
                      : new ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: listaTarjetas.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = listaTarjetas[index];
                            final lastDigits = listaTarjetas[index]["last4"];
                            final cardId = listaTarjetas[index]["id"];

                            return Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Dismissible(
                                // Show a red background as the item is swiped away.
                                background: Container(
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.centerRight,
                                  decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red,
                                  ),
                                  child: Text(
                                    "Eliminar tarjeta",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                key: Key(cardId),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  listaTarjetas.removeWhere(
                                      (item) => item["id"] == cardId);
                                  triggerCardRemoval(cardId);
                                  /* Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Tarjeta terminación $lastDigits eliminada"))); */
                                },

                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: new LinearGradient(
                                        colors: [
                                          Colors.grey[300],
                                          Colors.grey[200]
                                        ],
                                        begin: const FractionalOffset(0.0, 0.0),
                                        end: const FractionalOffset(2.0, 1.0),
                                        stops: [0.0, 1.0],
                                        tileMode: TileMode.clamp),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Image.asset(
                                            getCardImg(
                                                listaTarjetas[index]["brand"]),
                                            width: 25,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              "Terminación: " +
                                                  listaTarjetas[index]["last4"],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        "Desliza para eliminar",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewCard();
        },
        child: Icon(Icons.add),
        backgroundColor: zoul_primary_color,
      ),
    );
  }
}
