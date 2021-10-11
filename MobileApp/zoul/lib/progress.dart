import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zoul/extras/config.dart';
import 'package:http/http.dart' as http;

class ProgressPage extends StatefulWidget {
  String user_data;
  ProgressPage(this.user_data);

  @override
  _ProgressPage createState() => _ProgressPage();
}

class _ProgressPage extends State<ProgressPage> {
  bool active_loader = true;

  String user_name = "";
  String user_id = "";
  String profile_pic_link = "";

  String total_time = "";
  String unit = "";
  String total_disciplines = "";
  String period = "";

  @override
  void initState() {
    super.initState();
    user_name = jsonDecode(widget.user_data)["name"] ?? null;
    user_id = jsonDecode(widget.user_data)["user_id"] ?? null;
    profile_pic_link = jsonDecode(widget.user_data)["img_url"] ?? null;
    getAnalytics(context);
  }

  Future<http.Response> getAnalytics(context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{"action": "get_user_statics", "user_id": user_id}),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      if (jsonResponse[0]['status'] == "true") {
        String data = jsonEncode(jsonResponse[1]['data'][0]);
        if (data != null && data != "") {
          setState(() {
            total_time = jsonDecode(data)["total_time"].toString();
            unit = jsonDecode(data)["unit"].toString();
            total_disciplines =
                jsonDecode(data)["disciplines_count"].toString();
            period = jsonDecode(data)["days_period"].toString();
            active_loader = false;
          });
        }
        //print(jsonDecode(user_data)["name"]);
      } else {
        setState(() {
          total_time = "0";
          unit = "mins";
          total_disciplines = "0";
          period = "";
          active_loader = false;
        });
        //_displaySnackBar(context, jsonResponse[0]['message']);
      }
    } else {
      setState(() {
        active_loader = false;
      });
      /* _displaySnackBar(context, "No se ha podido iniciar sesión");
      throw Exception('Failed to login.'); */
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.0),
      elevation: 0,
      title: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Tu progreso"),
          )
        ],
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: appBar,
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
                    Hero(
                      tag: "profile_picture",
                      child: Container(
                        width: 150,
                        height: 150,
                        margin: EdgeInsets.only(top: 0, bottom: 10),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          border: Border.all(width: 3, color: Colors.white),
                          image: DecorationImage(
                            image: setImage(
                                "network",
                                profile_pic_link != ""
                                    ? (images_path + profile_pic_link)
                                    : null,
                                true), // <-- BACKGROUND IMAGE
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Mira " +
                          user_name +
                          ", a continuación podrás ver algunos de los datos de tu progreso, ¡Sigue así!",
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
            child: active_loader
                ? loader()
                : ListView(
                    padding: EdgeInsets.only(top: 0),
                    children: <Widget>[
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding: EdgeInsets.all(0),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: LinearGradient(
                                      colors: main_gradient,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        total_time,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 45,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                        transform: Matrix4.translationValues(
                                            0.0, -5.0, 0.0),
                                        child: Text(
                                          unit,
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
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 200,
                                  child: Text(
                                    "De ejercicio realizado esta semana",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 0),
                                  child: SizedBox(
                                    height: 0.5,
                                    width: double.infinity,
                                    child: const DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            Container(
                                child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 10),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        total_disciplines,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 45,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                        transform: Matrix4.translationValues(
                                            0.0, -5.0, 0.0),
                                        child: Text(
                                          "disciplina(s)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 200,
                                  child: Text(
                                    "Que has aprendido en todo el ciclo Zoul",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
