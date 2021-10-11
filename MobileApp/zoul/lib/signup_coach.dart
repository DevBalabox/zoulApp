import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zoul/coach_login.dart';
import 'package:zoul/extras/config.dart';
import 'dart:async';
import 'dart:convert';
import 'login.dart';
import 'signup_coach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class SignupCoachPage extends StatefulWidget {
  SignupCoachPage({Key key, this.title}) : super(key: key);
  final String title;
  static _SignupCoachPage of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_SignupCoachPage>());

  @override
  _SignupCoachPage createState() => _SignupCoachPage();
}

class _SignupCoachPage extends State<SignupCoachPage> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  int _counter = 0;
  bool filling_form = false;
  final _myForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /* String name = "Javier";
  String first_lastname = "Guerrero";
  String second_lastname = "Pérez";
  String mail = "cliente@zoul.com";
  String password = "12345678";
  String facebook_id = "";
  String method = "mail"; */

  String name = "";
  String first_lastname = "";
  String second_lastname = "";
  String biography = "";
  String mail = "";
  String password = "";
  String facebook_id = "";
  String method = "mail";
  String profile_picture = "null";

  TextEditingController nameController;
  TextEditingController first_lastnameController;
  TextEditingController second_lastnameController;
  TextEditingController biographyController;
  TextEditingController mailController;
  TextEditingController passwordController;

  bool showFbButton = false;

  var userFbProfile;

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> _login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;

        setState(() {
          filling_form = true;
        });

        _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=picture.width(400).height(400),name,first_name,last_name,email&access_token=${accessToken.token}');

        setState(() {
          print(graphResponse.body);

          userFbProfile = jsonDecode(graphResponse.body);
          print(userFbProfile["picture"]["data"]["url"]);

          if (userFbProfile != null && userFbProfile != "null") {
            name = userFbProfile["first_name"];
            first_lastname = userFbProfile["last_name"];
            mail = userFbProfile["email"];
            facebook_id = userFbProfile["id"];
            method = "facebook";
            profile_picture = userFbProfile["picture"]["data"]["url"];
            print(profile_picture);
            showFbButton = false;
            filling_form = false;
          }
        });

        /* var profile_picture = await networkImageToBase64(userFbProfile["picture"]["data"]["url"]);
        print(profile_picture.toString()); */

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
  }

  Future<http.Response> trySignup(context) async {
    setState(() {
      filling_form = true;
    });

    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "signup",
        "profile_picture_url": profile_picture,
        "name": name,
        "first_lastname": first_lastname,
        "second_lastname": second_lastname,
        "mail": mail,
        "biography": biography,
        "password": password,
        "method": method,
        "facebook_id": facebook_id,
        "user_type": "coach"
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        String user_id = jsonResponse[1]['user_id'];
        if (user_id != null) {
          goLoginScreen(context);
        } else {
          _displaySnackBar(context,
              "Hubo un problema interno, reporta esto a soporte. ¡Gracias por tu comprensión!");
        }
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
      _displaySnackBar(context, "No se ha podido realizar el registro");
      throw Exception('Failed to signup.');
    }
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  goLoginScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CoachLogin()),
    );
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
                      image: AssetImage("img/featured3.jpg"),
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
                                        width: 80,
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
                                        child:
                                            Text('Regístrate como Instructor',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
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
                                                  TextCapitalization.words,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              initialValue: name,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: Colors.white,
                                                ),
                                                hintText: 'Nombre',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Nombre',
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
                                                  return 'Ingresa tu Nombre';
                                                } else {
                                                  setState(() {
                                                    name = value;
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              initialValue: first_lastname,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              controller: first_lastnameController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.people_outline,
                                                  color: Colors.white,
                                                ),
                                                hintText: 'Apellido paterno',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Apellido paterno',
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
                                                  return 'Ingresa tu apellido paterno';
                                                } else {
                                                  setState(() {
                                                    first_lastname = value;
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              initialValue: second_lastname,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              controller: second_lastnameController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.people_outline,
                                                  color: Colors.white,
                                                ),
                                                hintText: 'Apellido materno',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Apellido materno',
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
                                                  return 'Ingresa tu apellido materno';
                                                } else {
                                                  setState(() {
                                                    second_lastname = value;
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              maxLength: 100,
                                              minLines: 2,
                                              maxLines: 8,
                                              style: TextStyle(
                                                  color: Colors.white),
                                                  initialValue: biography,
                                              controller: biographyController,
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: const InputDecoration(
                                                counterStyle: TextStyle(
                                                    color: Colors.white),
                                                suffixIcon: Icon(
                                                  Icons.info_outline,
                                                  color: Colors.white,
                                                ),
                                                hintText: 'Biografía',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                labelText: 'Biografía',
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
                                                  return 'Escribe tu biografía';
                                                } else {
                                                  setState(() {
                                                    biography = value;
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              initialValue: mail,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              controller: mailController,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.mail_outline,
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
                                                  if (EmailValidator.validate(
                                                      value)) {
                                                    setState(() {
                                                      mail = value;
                                                    });
                                                  } else {
                                                    return 'Ingresa un correo válido';
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              initialValue: password,
                                              controller: passwordController,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                    Icons.lock_outline,
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
                                                  return 'Ingresa tu contraseña';
                                                } else {
                                                  if (value.length > 7) {
                                                    setState(() {
                                                      password = value;
                                                    });
                                                  } else {
                                                    return 'Debe ser de al menos 8 dígitos';
                                                  }
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
                                                    trySignup(context);
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
                                                      "Registrarme",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            showFbButton
                                                ? Column(children: <Widget>[
                                                    Text(
                                                      "Ó",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: RaisedButton(
                                                        onPressed: _login,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        80.0)),
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        child: Ink(
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .lightBlue,
                                                                      Colors
                                                                          .lightBlueAccent
                                                                    ],
                                                                    begin: Alignment
                                                                        .centerLeft,
                                                                    end: Alignment
                                                                        .centerRight,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                          child: Container(
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxWidth:
                                                                        double
                                                                            .infinity,
                                                                    minHeight:
                                                                        40.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              "Usar Facebook",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ])
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: 0, top: 30),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
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
                                                          '¿Ya tienes cuenta? '),
                                                  new TextSpan(
                                                      text:
                                                          'Inicia sesión aquí',
                                                      style: new TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          )),
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
                ),
              ],
            ),
    );
  }
}
