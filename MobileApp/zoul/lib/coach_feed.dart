import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoul/extras/config.dart';
import 'package:zoul/extras/storage.dart';
import 'package:zoul/suscription.dart';
import "login.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_list.dart';
import 'video_player.dart';

class CoachFeed extends StatefulWidget {
  final String user_data;
  final String coach_id;
  final String coach_name;
  final String coach_data;
  final String discipline_id;

  CoachFeed(this.user_data, this.coach_id, this.coach_name, this.coach_data,
      this.discipline_id);

  @override
  _CoachFeed createState() => _CoachFeed();
}

class _CoachFeed extends State<CoachFeed> {
  bool loading_lists = true;
  bool fetch_error = false;
  bool logged = false;

  String mail = null;
  String password = null;
  String user_id = null;
  String user_data;
  String coach_data;
  String subscription_status = "inactive";
  String token = "";

  double coach_card_height = 195.00;

  String imgm;

  List<Map<String, dynamic>> list;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  Future getAllData() async {
    String get_data = await getUserDataArray(context);
    String get_token = await getUserToken(context);
    String stored_subscription_status = await getSubscriptionStatus();

    setState(() {
      if (get_data != null) {
        user_data = get_data;
        user_id = jsonDecode(user_data)["user_id"] ?? null;
        subscription_status = stored_subscription_status;
        print(subscription_status);
      }

      if (get_token != null) {
        token = get_token;
      }
    });
    loadServicesList(context);
  }

  getStoredData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //user_id = (prefs.getString('user_id') ?? null);
    token = (prefs.getString('token') ?? null);
    //user_data = (prefs.getString('user_data') ?? null);
  }

  getNetImg(link, decoration) {
    var imageWidget;

    if (decoration) {
      if (link == null) {
        imageWidget = AssetImage("img/featured2.jpg");
      } else {
        imageWidget = NetworkImage(link);
      }
    } else {
      if (link == null) {
        imageWidget = Image.asset(
          "img/featured2.jpg",
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
        "user_id": user_id,
        "status": "active",
        "coach_id": jsonDecode(widget.coach_data)["coach_id"],
        "discipline_id": widget.discipline_id
      }),
    );
    var jsonResponse = jsonDecode(response.body);
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

  Future<http.Response> mark_video(
      BuildContext context, video_id, fav_action) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "mark_video",
        "user_id": user_id,
        "video_id": video_id,
        "fav_action": fav_action
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
      } else {}
    } else {}
  }

  _displaySnackBar(context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  var categoria_plomeria = "1";

  favFlagged(index) {
    var color = Colors.white.withOpacity(0.9);

    if (list[index]["is_favorite"] == "true") {
      color = Colors.pink.withOpacity(0.9);
    }

    return color;
  }

  addRemoveFav(index) {
    if (list[index]["is_favorite"] == "true") {
      setState(() {
        list[index]["is_favorite"] = "false";
      });
      mark_video(context, list[index]["video_id"], "unfav");
    } else {
      setState(() {
        list[index]["is_favorite"] = "true";
      });
      mark_video(context, list[index]["video_id"], "fav");
    }
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
      backgroundColor: Color(0xFF114a9e).withOpacity(0.0),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(widget.coach_name),
          ),
          Image.asset(
            "img/isotipo-w.png",
            height: 30,
          )
        ],
      ),
    );

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
          padding: EdgeInsets.only(top: appBar.preferredSize.height +
                    MediaQuery.of(context).padding.top+coach_card_height+10, left: 15, right: 15),
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
                              zoul_secondary_color.withOpacity(0.3),
                              Colors.black.withOpacity(0.4)
                            ],
                            begin: const FractionalOffset(0.0, 2.0),
                            end: const FractionalOffset(1.0, 2.0),
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
                                      if (subscription_status == "inactive") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SuscriptionPage(
                                                      user_data, token)),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoPlayer(
                                                  list[index]['video_details']
                                                      ["url"],
                                                  list[index]['video_id'],
                                                  list[index]['video_details']
                                                      ["required_time"],
                                                  widget.user_data)),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 185,
                                      padding: EdgeInsets.all(5),
                                      decoration: new BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                          ),
                          InkWell(
                            onTap: () {
                              addRemoveFav(index);
                              //list[index]["category_id"] = "1";
                            },
                            child: Icon(
                              Icons.favorite,
                              color: favFlagged(index),
                              size: 20,
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

    showLists(context) {
      return fetch_error ? null : modelListGenerator(context, "");
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(children: <Widget>[
        Container(
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
        ),
        Container(
            padding: EdgeInsets.only(
                top: appBar.preferredSize.height +
                    MediaQuery.of(context).padding.top -
                    10),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              gradient: new LinearGradient(
                  colors: main_gradient,
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.5, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              image: DecorationImage(
                image: getNetImg(
                    "https://img2.thejournal.ie/inline/3296654/original/?width=630&version=3296654",
                    true),
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.1), BlendMode.dstATop),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              height: coach_card_height,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: widget.coach_id,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: new BoxDecoration(
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
                        ],
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                        border: Border.all(width: 2, color: Colors.white),
                        image: DecorationImage(
                          image: setImage(
                              "network",
                              images_path +
                                  jsonDecode(widget.coach_data)["img_url"],
                              true),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      "Bio de " +
                                          jsonDecode(
                                              widget.coach_data)["name"] +
                                          ":",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      jsonDecode(
                                          widget.coach_data)["biography"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 6,
                                      softWrap: false,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          String facebook_url;
                                          var facebook_id =
                                              jsonDecode(widget.coach_data)[
                                                  "facebook_profile"];

                                          if (facebook_id != null &&
                                              facebook_id != "") {
                                            facebook_url =
                                                "https://facebook.com/" +
                                                    facebook_id;
                                            visitSocialProfile(facebook_url);
                                          }
                                        },
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Image.asset(
                                                "img/facebook.png"),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          String insta_url;
                                          var insta_id =
                                              jsonDecode(widget.coach_data)[
                                                  "instagram_profile"];

                                          if (insta_id != null &&
                                              insta_id != "") {
                                            insta_url =
                                                "https://www.instagram.com/" +
                                                    insta_id;
                                            visitSocialProfile(insta_url);
                                          }
                                        },
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Image.asset(
                                                "img/instagram.png"),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          String youtube_url;
                                          var youtube_id =
                                              jsonDecode(widget.coach_data)[
                                                  "youtube_profile"];

                                          if (youtube_id != null &&
                                              youtube_id != "") {
                                            youtube_url =
                                                "https://www.youtube.com/channel/" +
                                                    youtube_id;
                                            visitSocialProfile(youtube_url);
                                          }
                                        },
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Image.asset(
                                                "img/youtube.png"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ))
      ]),
    );
  }
}
