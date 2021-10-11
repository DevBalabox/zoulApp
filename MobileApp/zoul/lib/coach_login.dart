import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zoul/coach_login.dart';
import 'package:zoul/login.dart';
import 'package:zoul/signup_coach.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'home_user.dart';
import 'home_coach.dart';
import 'signup_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'extras/config.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class CoachLogin extends StatefulWidget {
  CoachLogin({Key key, this.title}) : super(key: key);
  final String title;
  static _CoachLogin of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_CoachLogin>());

  @override
  _CoachLogin createState() => _CoachLogin();
}

class _CoachLogin extends State<CoachLogin> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  int _counter = 0;
  bool filling_form = false;
  final _myForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String mail = "";
  String password = "";

  TextEditingController mailController;
  TextEditingController passwordController;

  var userFbProfile;
  String facebook_id;
  String source = "facebook";

  String _message = 'Log in/out by pressing the buttons below.';

  /* Future<Null> _login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;

        setState(() {
          filling_form = true;
        });

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${accessToken.token}');
        setState(() {
          userFbProfile = jsonDecode(graphResponse.body);
          facebook_id = userFbProfile["id"];
          if (facebook_id != null) {
            trySocialLogin(context);
          }
        });

        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  } */

  /* Future<http.Response> trySocialLogin(context) async {
    setState(() {
      filling_form = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "social_login",
        'source': source,
        'id': facebook_id,
        'user_type': 'client'
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(jsonResponse);
      if (jsonResponse[0]['status'] == "true") {
        String user_id = jsonResponse[1]['user_id'];
        String token = jsonResponse[1]['token'];

        if (user_id != null && token != null) {
          //storeLoginData(mail, user_id, token, context);
          getUserData(user_id, token, context);
        }
      } else {
        setState(() {
          filling_form = false;
        });
        _displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        filling_form = false;
      });
      _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.');
    }
  } */

  Future<http.Response> tryLogin(context) async {
    setState(() {
      filling_form = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "login",
        'mail': mail,
        'password': password,
        'user_type': 'coach'
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(jsonResponse);
      if (jsonResponse[0]['status'] == "true") {
        String user_id = jsonResponse[1]['user_id'];
        String token = jsonResponse[1]['token'];

        if (user_id != null && token != null) {
          //storeLoginData(mail, user_id, token, context);
          getUserData(user_id, token, context);
        }
      } else {
        setState(() {
          filling_form = false;
        });
        _displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        filling_form = false;
      });
      _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.');
    }
  }

  Future<http.Response> getUserData(user_id, token, context) async {
    setState(() {
      filling_form = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "get_user_public_data",
        'user_id': user_id,
        'token': token
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        String user_data = jsonEncode(jsonResponse[1]['user_data'][0]);
        if (user_data != null) {
          storeLoginData(user_data, user_id, token, context);
        }
        //print(jsonDecode(user_data)["name"]);
      } else {
        setState(() {
          filling_form = false;
        });
        _displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        filling_form = false;
      });
      _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.');
    }
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  storeLoginData(user_data, user_id, token, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user_data);
    await prefs.setString('user_id', user_id);
    await prefs.setString('token', token);
    await prefs.setString('user_type', "coach");
    goHome(context);
  }

  goHome(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeCoach()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: filling_form
          ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: const CircularProgressIndicator(),
              ))
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.green, Colors.blue],
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
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 80, bottom: 15, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        white_vertical_logo,
                                        width: 90,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text('Inicia sesión',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ),
                                      Form(
                                        key: _myForm,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                              initialValue: mail,
                                              controller: mailController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                                hintText: 'Correo',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Correo',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .lightGreenAccent),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.yellow),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.yellow),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.yellow),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu correo';
                                                } else {
                                                  setState(() {
                                                    mail = value;
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: passwordController,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(Icons.lock,
                                                    color: Colors.white),
                                                hintText: 'Contraseña',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Contraseña',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .lightGreenAccent),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.yellow),
                                                ),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.yellow),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.yellow),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Ingresa tu contraseña';
                                                } else {
                                                  setState(() {
                                                    password = value;
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
                                                  if (_myForm.currentState
                                                      .validate()) {
                                                    tryLogin(context);
                                                  }
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            80.0)),
                                                padding: EdgeInsets.all(0.0),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.lightGreen,
                                                          Colors
                                                              .lightGreenAccent
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth:
                                                            double.infinity,
                                                        minHeight: 40.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Entrar",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              go_to_link(change_password_link);
                                            },
                                            child: Text(
                                              "¿Olvidaste tu contraseña?",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          )),
                                      /* Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignupPage()),
                                              );
                                            },
                                            child: RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.white,
                                                      ),
                                                      text:
                                                          '¿Aún no tienes cuenta? '),
                                                  new TextSpan(
                                                      text: 'Regístrate aquí',
                                                      style: new TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          )), */
                                    ],
                                  ),
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  /* boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.19),
                                      blurRadius: 5.0, // soften the shadow
                                      spreadRadius: 1.0, //extend the shadow
                                      offset: Offset(
                                        0.0, // Move to right 10  horizontally
                                        5.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ], */
                                ),
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, left: 25, right: 25),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignupCoachPage()),
                                            );
                                          },
                                          child: RichText(
                                            text: new TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.white,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text:
                                                        '¿Aún no tienes cuenta? '),
                                                new TextSpan(
                                                    text: 'Regístrate aquí',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, left: 25, right: 25),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: RichText(
                                            text: new TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.white,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text:
                                                        '¿No eres instructor? '),
                                                new TextSpan(
                                                    text: 'Inicia sesión aquí',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /* Image.network('http://circlecitygogirls.com/wp-content/uploads/2013/01/indy1.png'), */
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
