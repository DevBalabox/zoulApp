import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/home_user.dart';
import 'package:zoul/login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class EditUserProfile extends StatefulWidget {
  String user_data;
  String user_pic;

  EditUserProfile(this.user_data, this.user_pic);
  @override
  _EditUserProfile createState() => _EditUserProfile();
}

class _EditUserProfile extends State<EditUserProfile> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool filling_form = false;
  final _editProfileForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var userFbProfile;
  String facebook_id;
  String source = "facebook";

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> _requestID() async {
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
            submit_profile_edit(context);
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
  }

  String profile_pic_link = "";

  @override
  void initState() {
    super.initState();
    getStoredData(context);
    profile_pic_link = widget.user_pic;
  }

  String user_id = "";
  String token = "";
  String user_data = "";
  String user_name = "";

  String mail = "";
  String biography = "";
  String password = "";
  String new_password = "";
  String first_lastname = "";
  String second_lastname = "";
  String base64_img = "";
  String method = "mail";

  TextEditingController name_controller;
  TextEditingController first_lastname_controller;
  TextEditingController second_lastname_controller;
  TextEditingController mail_controller;
  TextEditingController password_controller;
  TextEditingController new_password_controller;

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 500,
        maxHeight: 500);

    setState(() {
      _image = image;
      if (_image != null) {
        base64_img = base64Encode(_image.readAsBytesSync());
      }
    });
    //print(base64Encode(_image.readAsBytesSync()));
  }

  getStoredData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = (prefs.getString('user_id') ?? null);
      token = (prefs.getString('token') ?? null);
      user_data = (prefs.getString('user_data') ?? null);
      user_name = jsonDecode(user_data)["name"];
      profile_pic_link = jsonDecode(user_data)["img_url"];
      mail = jsonDecode(user_data)["mail"];
      first_lastname = jsonDecode(user_data)["first_lastname"];
      second_lastname = jsonDecode(user_data)["second_lastname"];
      method = jsonDecode(user_data)["method"];
      biography = jsonDecode(user_data)["biography"];

      name_controller = TextEditingController(text: user_name);
      first_lastname_controller = TextEditingController(text: first_lastname);
      second_lastname_controller = TextEditingController(text: second_lastname);
      mail_controller = TextEditingController(text: mail);
      password_controller = TextEditingController(text: password);
      new_password_controller = TextEditingController(text: new_password);
      print(user_data);
      print(profile_pic_link);
    });
    if (user_data != null && token != null && user_id != null) {
      validate_token(context);
    } else {
      logout();
    }
  }

  Future<http.Response> validate_token(context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "validate_token",
        'user_id': user_id,
        'token': token
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] != "true") {
        logout();
      }
    } else {
      _displaySnackBar(context, "Hubo un problema para verificar tu cuenta.");
      logout();
      throw Exception('Failed to login.');
    }
  }

  Future<http.Response> submit_profile_edit(context) async {
    setState(() {
      filling_form = true;
    });

    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "edit_profile",
        "user_id": user_id,
        "profile_picture_base64": base64_img,
        "name": name_controller.text,
        "first_lastname": first_lastname_controller.text,
        "second_lastname": second_lastname_controller.text,
        "mail": mail_controller.text,
        "biography": biography,
        "password": password_controller.text,
        "new_password": new_password_controller.text,
        "method": method,
        "facebook_id": facebook_id,
        "user_type": "client"
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        getUserData(user_id, token, context);
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
      _displaySnackBar(
          context, "No se ha podido realizar la actualización de información");
      throw Exception('Failed to signup.');
    }
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
        String new_user_data = jsonEncode(jsonResponse[1]['user_data'][0]);
        if (new_user_data != null) {
          storeLoginData(new_user_data, user_id, token, context);
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
      _displaySnackBar(context,
          "Hubo un problema con las credenciales, intenta cerrando sesión");
      throw Exception('Failed to login.');
    }
  }

  storeLoginData(new_user_data, user_id, token, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', new_user_data);
    await prefs.setString('user_id', user_id);
    await prefs.setString('token', token);
    goHome(context);
  }

  goHome(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeUser()),
        (Route<dynamic> route) => false);
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_id');
    prefs.remove('token');
    prefs.remove('user_data');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  needsPassword() {
    if (method == "mail") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      facebookSignIn.loginBehavior = FacebookLoginBehavior.webViewOnly;
    }
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.0),
      elevation: 0,
      title: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Editar Perfil"),
          )
        ],
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      key: _scaffoldKey,
      body: filling_form
          ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: const CircularProgressIndicator(),
              ))
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      left: 25,
                      right: 25,
                      bottom: 25,
                      top: appBar.preferredSize.height +
                          MediaQuery.of(context).padding.top +
                          25),
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: main_gradient,
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.5, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                    image: DecorationImage(
                      image: AssetImage("img/bg-2.jpg"),
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: getImage,
                            child: Hero(
                              tag: "profile_picture",
                              child: Container(
                                width: 120,
                                height: 120,
                                margin: EdgeInsets.only(top: 0, bottom: 10),
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  image: DecorationImage(
                                    image: _image == null
                                        ? setImage(
                                            "network",
                                            profile_pic_link != ""
                                                ? (images_path +
                                                    profile_pic_link)
                                                : null,
                                            true)
                                        : FileImage(
                                            _image), // <-- BACKGROUND IMAGE
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "Toca la foto para cambiarla",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        ],
                      )
                    ],
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
                                              controller: name_controller,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              //initialValue: "prueba@prueba.com",
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Nombre',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Nombre',
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
                                                  return 'Ingresa tu Nombre';
                                                } else {
                                                  setState(() {
                                                    name_controller =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller:
                                                  first_lastname_controller,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.people_outline,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Apellido paterno',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Apellido paterno',
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
                                                  return 'Ingresa tu apellido paterno';
                                                } else {
                                                  setState(() {
                                                    first_lastname_controller =
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
                                                  second_lastname_controller,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.people_outline,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Apellido materno',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Apellido materno',
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
                                                  return 'Ingresa tu apellido materno';
                                                } else {
                                                  setState(() {
                                                    second_lastname_controller =
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
                                              controller: mail_controller,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.mail_outline,
                                                  color: Color(0xFF114a9e),
                                                ),
                                                hintText: 'Correo',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                                labelText: 'Correo',
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
                                                  return 'Ingresa tu correo';
                                                } else {
                                                  setState(() {
                                                    mail_controller =
                                                        TextEditingController(
                                                            text: value);
                                                  });
                                                }
                                                return null;
                                              },
                                            ),
                                            needsPassword()
                                                ? Column(children: <Widget>[
                                                    TextFormField(
                                                      initialValue: password,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      obscureText: true,
                                                      decoration:
                                                          const InputDecoration(
                                                        suffixIcon: Icon(
                                                            Icons.lock_outline,
                                                            color: Color(
                                                                0xFF114a9e)),
                                                        hintText:
                                                            'Contraseña actual',
                                                        hintStyle: TextStyle(
                                                          color: Colors.black38,
                                                        ),
                                                        labelText:
                                                            'Contraseña actual',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFF114a9e)),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .blue),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        errorStyle: TextStyle(
                                                            color: Colors.red),
                                                        focusedErrorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ),
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return 'Ingresa tu contraseña actual';
                                                        } else {
                                                          setState(() {
                                                            password_controller =
                                                                TextEditingController(
                                                                    text:
                                                                        value);
                                                          });
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          new_password_controller,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      obscureText: true,
                                                      decoration:
                                                          const InputDecoration(
                                                        suffixIcon: Icon(
                                                            Icons.lock_outline,
                                                            color: Color(
                                                                0xFF114a9e)),
                                                        hintText:
                                                            'Nueva contraseña (Opcional)',
                                                        hintStyle: TextStyle(
                                                          color: Colors.black38,
                                                        ),
                                                        labelText:
                                                            'Nueva contraseña (Opcional)',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFF114a9e)),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .blue),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        errorStyle: TextStyle(
                                                            color: Colors.red),
                                                        focusedErrorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ),
                                                      validator: (value) {
                                                        setState(() {
                                                          new_password_controller =
                                                              TextEditingController(
                                                                  text: value);
                                                        });
                                                      },
                                                    ),
                                                  ])
                                                : SizedBox(),
                                            method == "mail"
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 20, bottom: 5),
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        if (_editProfileForm
                                                            .currentState
                                                            .validate()) {
                                                          submit_profile_edit(
                                                              context);
                                                        }
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      child: Ink(
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: secondary_button_gradient,
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth: double
                                                                      .infinity,
                                                                  minHeight:
                                                                      40.0),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            "Guardar cambios",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 20, bottom: 5),
                                                    child: RaisedButton(
                                                      onPressed: () =>
                                                          _requestID(),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      child: Ink(
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: secondary_button_gradient,
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth: double
                                                                      .infinity,
                                                                  minHeight:
                                                                      40.0),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            "Guardar cambios",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
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
