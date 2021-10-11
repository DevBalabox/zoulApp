import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoul/coach_video_player.dart';
import 'package:zoul/extras/config.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_list.dart';
import 'video_player.dart';

class CoachDisciplineVideoList extends StatefulWidget {
  final String discipline_id;
  String discipline_name;

  CoachDisciplineVideoList(this.discipline_id, this.discipline_name);

  @override
  _CoachDisciplineVideoList createState() => _CoachDisciplineVideoList();
}

class _CoachDisciplineVideoList extends State<CoachDisciplineVideoList> {
  bool loading_lists = true;
  bool fetch_error = false;
  String coach_id = "";
  String coach_data = "";

  String imgm;

  List<Map<String, dynamic>> list;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getStoredCoachData(context);
  }

  getStoredCoachData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    coach_data = (prefs.getString('coach_data') ?? null);
    if (coach_data != null) {
      coach_id = jsonDecode(coach_data)["coach_id"];
      loadServicesList(context);
    } else {
      //Logout
      //logout();
      Navigator.pop(context);
    }
  }

  getNetImg(link, decoration) {
    var imageWidget;

    if (decoration) {
      if (link == null) {
        imageWidget = AssetImage("img/bg-2.jpg");
      } else {
        imageWidget = NetworkImage(link);
      }
    } else {
      if (link == null) {
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

  Future<http.Response> loadServicesList(BuildContext context) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "get_video_playlist",
        "user_id": "user_id",
        "status": "active",
        "coach_id": coach_id,
        "discipline_id": widget.discipline_id
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          loading_lists = false;
          list =
              List<Map<String, dynamic>>.from(jsonResponse[1]['videos_list']);
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
    return fetch_error ? null : modelListGenerator(context, "");
  }

  var categoria_plomeria = "1";

  modelListGenerator(context, category) {
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
              Text("¡Aún no hay videos de este coach!")
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
        padding: EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) => new Container(
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.12),
                  blurRadius: 5.0, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                  offset: Offset(
                    0.0, // Move to right 10  horizontally
                    5.0, // Move to bottom 10 Vertically
                  ),
                )
              ]),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(0),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(list[index]['video_details']
                      ["thumbnail"]), // <-- BACKGROUND IMAGE
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        bottom: 25, left: 15, right: 15, top: 25),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: new LinearGradient(
                          colors: [
                            Colors.transparent.withOpacity(0.7),
                            Colors.blue.withOpacity(0.5)
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.0, 2.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                list[index]['title'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                list[index]['description'],
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                softWrap: false,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.timer,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    list[index]['video_details']["duration"],
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CoachVideoPlayer(list[index]['video_details']
                                                  ["url"])),
                                    );
                                  },
                                  child: Container(
                                    width: 185,
                                    padding: EdgeInsets.all(5),
                                    decoration: new BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white.withOpacity(0.5)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.play_circle_filled,
                                          size: 23,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Reproducir rutina",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        )
                                      ],
                                    ),
                                  ))
                            ],
                          ),
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

  visitSocialProfile(url) async {
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
      backgroundColor: Color(0xFF114a9e),
      elevation: 0,
      title: 
      Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.discipline_name),
                Image.asset(
                  "img/isotipo-w.png",
                  height: 30,
                )
              ],
            ),
    );

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      appBar: appBar,
      body: loading_lists
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
    );
  }
}
