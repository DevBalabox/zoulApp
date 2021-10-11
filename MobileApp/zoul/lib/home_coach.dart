import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoul/coach_login.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/user_profile.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_profile.dart';
import 'favorites.dart';
import 'payment_methods.dart';
import 'suscription.dart';
import 'coach_disciplines.dart';
import 'coach_payment_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeCoach extends StatefulWidget {
  @override
  _HomeCoach createState() => _HomeCoach();
}

class _HomeCoach extends State<HomeCoach> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    getStoredData(context);
  }

  bool loading_lists = true;
  bool fetch_error = false;
  bool logged = false;

  bool acceptedCoach = true;

  List<Map<String, dynamic>> list;

  String user_id = null;
  String user_data;
  String coach_data;
  String coach_id;
  String token;
  String fcm_token;

  String user_name = "";
  String profile_pic_link;

  Future<http.Response> getUserData(user_id, token, context) async {
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
          getCoachData(user_id, token, context);
        }
      } else {
        setState(() {
          loading_lists = false;
          list = [];
        });
        //_displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        loading_lists = false;
        list = [];
      });
      /* _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.'); */
    }
  }

  Future<http.Response> getCoachData(user_id, token, context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "get_coach_data",
        'user_id': user_id,
        'token': token
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    //print("Data:"+jsonResponse.toString());
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        //print(jsonResponse);
        String coach_data = jsonEncode(jsonResponse[1]['coach_data'][0]);
        if (user_data != null) {
          storeCoachData(coach_data, context);
        }
      } else {
        //print("No se encontró data del coach");
        setState(() {
          loading_lists = false;
          acceptedCoach = false;
          list = [];
        });
        //_displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        loading_lists = false;
        list = [];
      });
      /* _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.'); */
    }
  }

  storeCoachData(coach_data, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('coach_data', coach_data);
    setState(() {
      coach_data = coach_data;
      print(coach_data);
      coach_id = jsonDecode(coach_data)["coach_id"];
    });
    loadServicesList(context);
  }

  storeLoginData(user_data, user_id, token, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user_data);
    await prefs.setString('user_id', user_id);
    await prefs.setString('token', token);
    setState(() {
      user_data = user_data;
      profile_pic_link = jsonDecode(user_data)["img_url"];
      user_name = jsonDecode(user_data)["name"];
      profile_pic_link = jsonDecode(user_data)["img_url"];
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.getToken().then((gotten_token) => {
            //print("FCM token: " + token.toString()),
            fcm_token = gotten_token,
            register_fcm_token(user_id, gotten_token.toString())
          });
    });
  }

  getStoredData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = (prefs.getString('user_id') ?? null);
    token = (prefs.getString('token') ?? null);
    user_data = (prefs.getString('user_data') ?? null);
    if (user_data != null && token != null && user_id != null) {
      setState(() {
        user_name = jsonDecode(user_data)["name"];
        profile_pic_link = jsonDecode(user_data)["img_url"];
        //print(profile_pic_link);
      });
      validate_token(context);
      getUserData(user_id, token, context);
    } else {
      //Logout
      //print("Checkpoint");
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
        clear_session_data(user_id, token, fcm_token).then((value) => logout());
      } else {
        setState(() {
          logged = true;
        });
        //_displaySnackBar(context, "¡Hola!");
      }
    } else {
      _displaySnackBar(context, "Hubo un problema para verificar tu cuenta.");
      clear_session_data(user_id, token, fcm_token).then((value) => logout());
      throw Exception('Failed to login.');
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_data');
    prefs.remove('coach_data');
    prefs.remove('user_id');
    prefs.remove('token');
    prefs.remove('user_type');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<http.Response> loadServicesList(BuildContext context) async {
    setState(() {
      loading_lists = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{"action": "get_coach_statics", "user_id": user_id}),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          list = List<Map<String, dynamic>>.from(jsonResponse[1]['periods']);
        });
        //print(jsonResponse[0]['message'].toString());
      } else {
        setState(() {
          loading_lists = false;
          list = [];
        });
        _displaySnackBar(context, jsonResponse[0]['message'].toString());
      }
    } else {
      setState(() {
        loading_lists = false;
        fetch_error = true;
      });
      _displaySnackBar(context, "No se ha podido cargar la lista de servicios");
      //throw Exception('Failed to load list.');
    }
  }

  _displaySnackBar(context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  showLists(context) {
    return fetch_error ? null : modelListGenerator(context, "");
  }

  var categoria_plomeria = "1";

  modelListGenerator(context, category) {
    var listLength;

    if (list == null || list == "" || list.isEmpty) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.data_usage,
                size: 35,
              ),
              SizedBox(
                height: 5,
              ),
              Text("¡Aún no tienes métricas!")
            ]),
      );
    }

    if (category == "") {
      listLength = list.length;
    }

    return new Container(
        width: double.infinity,
        child: RefreshIndicator(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: listLength,
              padding: EdgeInsets.all(15),
              itemBuilder: (BuildContext context, int index) => new Container(
                child: Container(
                  alignment: Alignment.center,
                  width: 100,
                  height: 100,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          list[index]["period"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        list[index]["views"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      Container(
                        transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                        child: Text(
                          "vistas",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
            ),
            onRefresh: () {
              loadServicesList(context);
            }));
  }

  uploadNew(url) async {
    if (url != "" && url != "") {
      if (await canLaunch(url)) {
        await launch(
          url,
          universalLinksOnly: true,
        );
      } else {
        throw 'There was a problem to open the url: $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.5),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Hola, " + user_name),
          Image.asset(
            "img/isotipo-w.png",
            height: 30,
          )
        ],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: appBar,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CoachProfile(user_data, token)));
                      },
                      child: Hero(
                        tag: "profile_picture",
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: EdgeInsets.only(top: 0, bottom: 10),
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 3, color: Colors.white),
                            image: DecorationImage(
                              image: setImage(
                                  "network",
                                  profile_pic_link != ""
                                      ? (images_path +
                                          profile_pic_link.toString())
                                      : null,
                                  true),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Hola, ' + user_name,
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Colors.blue, Colors.deepPurple],
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
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Mi perfil'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CoachProfile(user_data, token)));
                },
              ),
              ListTile(
                leading: Icon(Icons.play_circle_outline),
                title: Text('Mi canal'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CoachDisciplines(user_id)));
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Datos de pago'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CoachPaymentDetails(user_id, token)));
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Ayuda'),
                onTap: () {
                  callSupportCenter("");
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Aviso de privacidad'),
                onTap: () {
                  go_to_link(privacy_link);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Cerrar sesión'),
                onTap: () {
                  clear_session_data(user_id, token, fcm_token)
                      .then((value) => logout());
                },
              ),
            ],
          ),
        ),
        body: Column(
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
                    colors: [Colors.blue, Colors.deepPurple],
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
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CoachProfile(user_data, token)));
                        },
                        child: Hero(
                          tag: "profile_picture_main",
                          child: Container(
                            width: 150,
                            height: 150,
                            margin: EdgeInsets.only(top: 0, bottom: 10),
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(width: 3, color: Colors.white),
                              image: DecorationImage(
                                image: setImage(
                                    "network",
                                    profile_pic_link != ""
                                        ? (images_path +
                                            profile_pic_link.toString())
                                        : null,
                                    true),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: loading_lists
                            ? SizedBox()
                            : !acceptedCoach ? SizedBox() : FlatButton(
                                onPressed: () {
                                  acceptedCoach
                                      ? uploadNew(coach_web_dashboard)
                                      : null;
                                },
                                color:
                                    acceptedCoach ? Colors.lime : Colors.grey,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  child: Text(
                                    "Subir nueva rutina",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        acceptedCoach
                            ? "A continuación puedes ver tus métricas sobre reproducciones:"
                            : "Estamos revisando tu solicitud, si tienes dudas comunícate con nosotros",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading_lists
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: Center(
                        child: const CircularProgressIndicator(),
                      ))
                  : Container(
                      color: Colors.white,
                      child: !fetch_error ? showLists(context) : null,
                    ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(280.0);
}
