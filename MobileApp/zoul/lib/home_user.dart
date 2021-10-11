import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zoul/extras/storage.dart';
import 'package:zoul/user_profile.dart';
import 'package:upgrader/upgrader.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_list.dart';
import 'user_profile.dart';
import 'favorites.dart';
import 'payment_methods.dart';
import 'suscription.dart';
import 'progress.dart';
import 'extras/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

var categoria_plomeria = "1";

class HomeUser extends StatefulWidget {
  @override
  _HomeUser createState() => _HomeUser();
}

class _HomeUser extends State<HomeUser> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool loading_lists = true;
  bool fetch_error = false;
  bool logged = false;

  String user_id = null;
  String user_data;
  String token;
  String fcm_token = "";

  String user_name;
  String profile_pic_link;
  String subscription_status;

  //Variables de Revenuecat
  PurchaserInfo _purchaserInfo;
  Offerings _offerings;
  bool in_progress = true;
  var isPro;
  //Fin variables de revenuecat

  Widget proBadge(BuildContext context) {
    return subscription_status != "inactive"
        ? Container(
            width: 25,
            height: 25,
            margin: EdgeInsets.only(right: 7),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: secondary_button_gradient,
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
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: 15,
            ),
          )
        : SizedBox();
  }

  var pro_badge = Container(
    width: 25,
    height: 25,
    margin: EdgeInsets.only(right: 7),
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: Colors.white),
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
    child: Icon(
      Icons.star,
      color: Colors.white,
      size: 15,
    ),
  );

  List<Map<String, dynamic>> listaServicios;
  List<Map<String, dynamic>> serviciosPlomeria;
  List<Map<String, dynamic>> serviciosElectricidad;
  List<Map<String, dynamic>> serviciosEspeciales;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getStoredData(context);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);
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
      _offerings = offerings;
      print(_offerings.toString());
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
      setSubscriptionStatus(subscription_status);
    });
  }

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
        }
        print(jsonDecode(user_data)["subscription_status"]);
      } else {
        //_displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      /* _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.'); */
    }
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
      //subscription_status = jsonDecode(user_data)["subscription_status"];
      print(subscription_status);
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.getToken().then((gotten_token) => {
            print("FCM token: " + gotten_token.toString()),
            fcm_token = gotten_token,
            register_fcm_token(user_id, gotten_token.toString())
          });
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          //_showItemDialog(message);
        },
        onBackgroundMessage: (Map<String, dynamic> message) async {},
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          //_navigateToItemDetail(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          //_navigateToItemDetail(message);
        },
      );
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
        subscription_status =
            prefs.getString('subscription_status') ?? "inactive";
        print(subscription_status);
        print(profile_pic_link);
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
        loadServicesList(context);
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
    prefs.remove('user_id');
    prefs.remove('token');
    prefs.remove('user_type');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<http.Response> loadServicesList(BuildContext context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "get_disciplines_list",
        'status': 'public'
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          listaServicios =
              List<Map<String, dynamic>>.from(jsonResponse[0]['message']);
          serviciosPlomeria = listaServicios
              .where((service) => service["category_id"] == categoria_plomeria)
              .toList();
          serviciosElectricidad = listaServicios
              .where(
                  (service) => service["category_id"] == categoria_electricidad)
              .toList();
          serviciosEspeciales = listaServicios
              .where(
                  (service) => service["category_id"] == categoria_especiales)
              .toList();
        });
        //print(jsonResponse[0]['message'].toString());
      } else {
        setState(() {
          loading_lists = false;
        });
        _displaySnackBar(context, jsonResponse[0]['message']);
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
    return fetch_error
        ? null
        : modelListGenerator(context, "", listaServicios, user_data);
  }

  getNetImg(link, decoration) {
    var imageWidget;

    if (decoration) {
      if (link == null || link == "") {
        imageWidget = AssetImage("img/bg-2.jpg");
      } else {
        imageWidget = NetworkImage(link);
      }
    } else {
      if (link == null || link == "") {
        imageWidget = Image.asset(
          "img/bg-2.jpg",
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Image.network(
          link,
          fit: BoxFit.cover,
        );
      }
    }

    return imageWidget;
  }

  comingSoonMessage() {
    _displaySnackBar(context, "Esta disciplina estará disponible próximamente");
  }

  modelListGenerator(context, category, list, user_data) {
    var listLength;

    if (category == "") {
      listLength = list.length;
    } else {
      listLength =
          list.where((service) => service["category_id"] == category).length;
    }

    var discipline_status = "";

    return new Container(
      width: double.infinity,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 1,
          itemCount: listLength,
          padding: EdgeInsets.only(top: 40),
          itemBuilder: (BuildContext context, int index) => new Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.19),
                    blurRadius: 5.0, // soften the shadow
                    spreadRadius: 1.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      5.0, // Move to bottom 10 Vertically
                    ),
                  )
                ]),
            child: GestureDetector(
              onTap: () {
                var discipline_status = list[index]["status"];
                if (discipline_status != null && discipline_status != "") {
                  if (discipline_status != "Próximamente") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CoachList(
                                user_data,
                                list[index]["discipline_id"],
                                list[index]['name'],
                                list[index]['img_url'])));
                  } else {
                    comingSoonMessage();
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(images_path +
                        list[index]['img_url']), // <-- BACKGROUND IMAGE
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: EdgeInsets.only(
                          bottom: 15, left: 15, right: 15, top: 15),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: new LinearGradient(
                            colors: [
                              zoul_secondary_color.withOpacity(0.3),
                              Colors.black.withOpacity(0.4)
                            ],
                            begin: const FractionalOffset(0.0, 0.0),
                            end: const FractionalOffset(0.0, 1.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            list[index]['name'],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 27,
                                color: Colors.white),
                          ),
                          list[index]["status"] == "Próximamente"
                              ? Text(
                                  "(Próximamente)",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            list[index]['short_description'],
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();
    final appcastURL = sparkle;
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        /* appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.05),
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    proBadge(context),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: user_name != null
                          ? Text("Hola, " + user_name)
                          : null,
                    ),
                  ],
                ),
                Image.asset(
                  "img/isotipo-w.png",
                  height: 30,
                )
              ],
            ),
          ), */
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
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
                                    ProfileScreen(user_data)));
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
                                  true), // <-- BACKGROUND IMAGE
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      user_name != null ? "Hola, " + user_name : "",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: main_gradient,
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.5, 1.0),
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
                          builder: (context) => ProfileScreen(user_data)));
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favoritos'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserFavoriteVideos(user_data, token)));
                },
              ),
              ListTile(
                leading: Icon(Icons.pie_chart),
                title: Text('Progreso'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProgressPage(user_data)));
                },
              ),
              /* ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('Mis tarjetas'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PaymentMethods(user_data, token)));
                  },
                ), */
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Suscripción'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SuscriptionPage(user_data, token)));
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
        body: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  backgroundColor: Color(0xFFff8aa8),
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          proBadge(context),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: user_name != null
                                ? Text("Hola, " + user_name)
                                : null,
                          ),
                        ],
                      ),
                      Image.asset(
                        "img/isotipo-w.png",
                        height: 30,
                      )
                    ],
                  ),
                  pinned: false,
                  floating: false,
                  forceElevated: innerBoxIsScrolled,
                ),
              ];
            },
            body: loading_lists
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: const CircularProgressIndicator(),
                    ))
                : UpgradeAlert(
                    title: "Hemos actualizado Zoul",
                    prompt:
                        "Ayúdanos a mejorar tu experiencia y descarga la nueva versión de Zoul",
                    buttonTitleUpdate: "Actualizar",
                    appcastConfig: cfg,
                    debugLogging: true,
                    showIgnore: false,
                    showLater: false,
                    canDismissDialog: false,
                    child: Stack(
                      children: <Widget>[
                        SizedBox.fromSize(
                          size: preferredSize,
                          child:
                              new LayoutBuilder(builder: (context, constraint) {
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
                          child: !fetch_error ? showLists(context) : null,
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(280.0);
}
