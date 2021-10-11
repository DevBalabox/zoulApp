import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zoul/coach_discipline_video_list.dart';
import 'package:zoul/user_profile.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'extras/config.dart';

var categoria_plomeria = "1";

class CoachDisciplines extends StatefulWidget {
  String user_id;
  CoachDisciplines(this.user_id);
  @override
  _CoachDisciplines createState() => _CoachDisciplines();
}

class _CoachDisciplines extends State<CoachDisciplines> {
  bool loading_lists = true;
  bool fetch_error = false;
  bool logged = false;

  String user_id = null;
  String user_data;
  String token;

  String user_name;
  String profile_pic_link;

  List<Map<String, dynamic>> listaServicios;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //getStoredData(context);
    loadServicesList(context);
  }

  Future<http.Response> loadServicesList(BuildContext context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "get_coach_disciplines_list",
        "user_id": widget.user_id,
        "status": "active"
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          listaServicios = List<Map<String, dynamic>>.from(
              jsonResponse[1]['disciplines_list']);
        });
        //print(jsonResponse[0]['message'].toString());
      } else {
        setState(() {
          loading_lists = false;
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
    return fetch_error
        ? null
        : modelListGenerator(context, "", listaServicios, user_data);
  }

  getNetImg(link, decoration) {
    var imageWidget;

    if (decoration) {
      if (link == null || link == "") {
        imageWidget = AssetImage("img/featured3.jpg");
      } else {
        imageWidget = NetworkImage(link);
      }
    } else {
      if (link == null || link == "") {
        imageWidget = Image.asset(
          "img/featured3.jpg",
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

  modelListGenerator(context, category, list, user_data) {
    var listLength;

    if (list == null || list == "") {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.mood_bad,
                size: 35,
              ),
              SizedBox(
                height: 5,
              ),
              Text("¡Aún no tienes disciplinas asignadas!")
            ]),
      );
    }

    if (category == "") {
      listLength = list.length;
    } else {
      listLength =
          list.where((service) => service["category_id"] == category).length;
    }

    return new Container(
      width: double.infinity,
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 1,
        itemCount: listLength,
        padding: EdgeInsets.only(top: 130),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoachDisciplineVideoList(list[index]["discipline_id"].toString(),list[index]["name"].toString())));
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
                            Colors.blue.withOpacity(0.6),
                            Colors.deepPurple.withOpacity(0.4)
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.0, 2.0),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF114a9e).withOpacity(0.9),
        elevation: 0,
        title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Tus disciplinas"),
                Image.asset(
                  "img/isotipo-w.png",
                  height: 30,
                )
              ],
            ),
      ),
      body: loading_lists
          ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: const CircularProgressIndicator(),
              ))
          : Stack(
              children: <Widget>[
                SizedBox.fromSize(
                  size: preferredSize,
                  child: new LayoutBuilder(builder: (context, constraint) {
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
                                bottom: width / 2 - preferredSize.height / 2),
                            child: new DecoratedBox(
                              decoration: new BoxDecoration(
                                gradient: new LinearGradient(
                                    colors: [
                                      Color(0xFF114a9e),
                                      Colors.deepPurple
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(3.0, 12.0),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(280.0);
}
