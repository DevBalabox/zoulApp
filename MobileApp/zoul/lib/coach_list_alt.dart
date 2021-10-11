import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_feed.dart';
import 'extras/config.dart';

var categoria_plomeria = "1";
var categoria_electricidad = "2";
var categoria_especiales = "3";

class CoachList extends StatefulWidget {
  final String user_data;
  final String discipline_id;
  final String title;
  final String img_url;

  CoachList(this.user_data, this.discipline_id, this.title, this.img_url);

  @override
  _CoachList createState() => _CoachList();
}

class _CoachList extends State<CoachList> {
  bool loading_lists = true;
  bool fetch_error = false;
  bool logged = false;

  String mail = null;
  String password = null;
  String user_id = null;
  String user_data;
  String discipline_id;

  List<Map<String, dynamic>> listaCoaches;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    user_id = jsonDecode(widget.user_data)["user_id"] ?? null;
    user_data = widget.user_data;
    discipline_id = widget.discipline_id;
    loadServicesList(context);
  }

  Future<http.Response> loadServicesList(BuildContext context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "get_coaches_list",
        "user_id": user_id,
        "status": "active",
        "discipline_id": widget.discipline_id
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          listaCoaches =
              List<Map<String, dynamic>>.from(jsonResponse[1]['coaches_list']);
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
    return fetch_error ? null : modelListGenerator(context, "", listaCoaches);
  }

  modelListGenerator(context, category, list) {
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
              Text("¡Aún no hay coaches para esta disciplina!")
            ]),
      );
    }

    if (category == "") {
      listLength = list.length;
    } else {
      listLength =
          list.where((service) => service["category_id"] == category).length;
    }

    return Container(
      width: double.infinity,
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: listLength,
        padding: EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) => new Container(
            margin: EdgeInsets.only(left: 0, right: 0),
            child: Stack(children: <Widget>[
              Align(
                alignment: Alignment.center,
                child:Hero(
                tag: list[index]["user_id"].toString(),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(top: 0, bottom: 0),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                      border: Border.all(width: 0, color: Colors.white),
                      image: DecorationImage(
                        image: setImage(
                            "network",
                            list[index]['img_url'] != null
                                ? (images_path +
                                    list[index]['img_url'].toString())
                                : null,
                            true), // <-- BACKGROUND IMAGE
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              ),
              Container(
                height: 140,
                margin: EdgeInsets.only(top: 180),
                padding: EdgeInsets.all(0),
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.only(topRight:Radius.circular(20)),
                    gradient: new LinearGradient(
                        colors: main_gradient,
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.5, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                    image: DecorationImage(
                      image: NetworkImage(images_path + list[index]['img_url']),
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.05), BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
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
                          builder: (context) => CoachFeed(
                              user_data,
                              list[index]["user_id"],
                              list[index]['name'],
                              jsonEncode(list[index]),
                              discipline_id),
                        ));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: new LinearGradient(
                              colors: [
                                Colors.transparent,
                                zoul_secondary_color.withOpacity(0.4)
                              ],
                              begin: const FractionalOffset(0.0, 0.0),
                              end: const FractionalOffset(0.0, 1.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              list[index]['name'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              list[index]['biography'],
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
            ])),
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
    );
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
            child: Text(widget.title),
          ),
          Image.asset(
            "img/isotipo-w.png",
            height: 30,
          )
        ],
      ),
    );

    return Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Column(
          children: <Widget>[
            Hero(
              tag: widget.discipline_id,
              child: Container(
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
                    image: NetworkImage(widget.img_url),
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.0), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
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
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(280.0);
}
