import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/home_coach.dart';
import 'package:zoul/login.dart';
import 'package:http/http.dart' as http;

class CoachPaymentDetails extends StatefulWidget {
  String user_id;
  String token;
  CoachPaymentDetails(this.user_id, this.token);

  @override
  _CoachPaymentDetails createState() => _CoachPaymentDetails();
}

class _CoachPaymentDetails extends State<CoachPaymentDetails> {
  @override
  void initState() {
    super.initState();
    getStoredCoachData(context);
  }

  String coach_data;
  String password = "";
  String banco = "BBVA";
  String clabe = "0125 12439 98234709";
  String no_de_tarjeta = "5522 1922 2889 0012";

  TextEditingController bancoController;
  TextEditingController clabeController;
  TextEditingController no_de_tarjetaController;
  TextEditingController passwordController;

  getStoredCoachData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    coach_data = (prefs.getString('coach_data') ?? null);
    if (coach_data != null) {
      setState(() {
        bancoController =
            TextEditingController(text: jsonDecode(coach_data)["bank"]);
        clabeController =
            TextEditingController(text: jsonDecode(coach_data)["clabe"]);
        no_de_tarjetaController =
            TextEditingController(text: jsonDecode(coach_data)["card_number"]);
      });
    } else {
      //Logout
      //logout();
      Navigator.pop(context);
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_data');
    prefs.remove('user_id');
    prefs.remove('token');
    prefs.remove('user_type');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  bool filling_form = false;
  final _editProfileForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<http.Response> submit_coach_details(context) async {
    setState(() {
      filling_form = true;
    });

    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "update_coach_bank_details",
        "user_id": widget.user_id,
        "bank": bancoController.text,
        "clabe": clabeController.text,
        "card_number": no_de_tarjetaController.text,
        "password": passwordController.text
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        goHome(context);
        
      } else {
        setState(() {
          filling_form = false;
        });
        _displaySnackBar(context, jsonResponse[0]['message'].toString());
      }
    } else {
      setState(() {
        filling_form = false;
      });
      _displaySnackBar(
          context, "No se ha podido realizar la actualización de información");
      throw Exception('Failed to signup.');
    }
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  goHome(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeCoach()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.5),
      elevation: 0,
      title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Datos de pago"),
                Image.asset(
                  "img/isotipo-w.png",
                  height: 30,
                )
              ],
            ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      key: _scaffoldKey,
      body: filling_form
          ? loader()
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      left: 25,
                      right: 25,
                      bottom: 0,
                      top: appBar.preferredSize.height +
                          MediaQuery.of(context).padding.top),
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.blue, Colors.deepPurple],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(2.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                    image: DecorationImage(
                      image: AssetImage("img/bg-2.jpg"),
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: <Widget>[
                                      Form(
                                        key: _editProfileForm,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            TextFormField(
                                              controller: bancoController,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              //initialValue: "prueba@prueba.com",
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.account_balance,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Banco',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Banco',
                                                labelStyle: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF114a9e)),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu Banco';
                                                } else {
                                                  setState(() {
                                                    bancoController =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: clabeController,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.info,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'CLABE',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'CLABE',
                                                labelStyle: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF114a9e)),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu CLABE';
                                                } else {
                                                  setState(() {
                                                    clabeController =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black),
                                              controller:
                                                  no_de_tarjetaController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.credit_card,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Número de tarjeta',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Número de tarjeta',
                                                labelStyle: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF114a9e)),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu Número de tarjeta';
                                                } else {
                                                  setState(() {
                                                    no_de_tarjetaController =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              initialValue: password,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                    Icons.lock_outline,
                                                    color: Color(0xFF114a9e)),
                                                hintText: 'Contraseña',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Contraseña',
                                                labelStyle: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF114a9e)),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu contraseña';
                                                } else {
                                                  setState(() {
                                                    passwordController =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 20, bottom: 5),
                                              child: RaisedButton(
                                                onPressed: () {
                                                  if (_editProfileForm
                                                      .currentState
                                                      .validate()) {
                                                        submit_coach_details(context);
                                                    //tryLogin(context);
                                                  }
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                padding: EdgeInsets.all(0.0),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF114a9e),
                                                          Colors.lightBlue
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0)),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth:
                                                            double.infinity,
                                                        minHeight: 40.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Guardar cambios",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancelar y volver",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /* Image.network('http://circlecitygogirls.com/wp-content/uploads/2013/01/indy1.png'), */
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
