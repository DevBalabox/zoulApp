import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zoul/home_coach.dart';
import 'dart:async';
import 'extras/config.dart';

class EditCoachPicture extends StatefulWidget {
  String user_data;
  String token;
  EditCoachPicture(this.user_data, this.token);
  @override
  _EditCoachPicture createState() => _EditCoachPicture();
}

class _EditCoachPicture extends State<EditCoachPicture> {
  @override
  void initState() {
    super.initState();
    user_id = jsonDecode(widget.user_data)["user_id"] ?? null;
    user_data = widget.user_data;
  }

  String user_id = "";
  String user_data = "";

  bool filling_form = false;
  final _editProfileForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String base64_img;

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 70,
        maxWidth: 700,
        maxHeight: 700);

    setState(() {
      _image = image;
      base64_img = base64Encode(_image.readAsBytesSync());
    });
    //print(base64Encode(_image.readAsBytesSync()));
  }

  Future<http.Response> uploadPicture(context) async {
    setState(() {
      filling_form = true;
    });
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "update_profile_picture",
        "user_id": user_id,
        "profile_picture_base64": base64_img,
        "token": widget.token
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      if (jsonResponse[0]['status'] == "true") {
        setState(() {
          filling_form = false;
        });
        goHome(context);
      } else {
        setState(() {
          filling_form = false;
        });
         _displaySnackBar(context,jsonResponse[0]['message'].toString());
      }
    } else {
      setState(() {
        filling_form = false;
      });
      _displaySnackBar(context, "No se ha podido actualizar la foto de perfil");
      throw Exception('Failed to update picture.');
    }
  }

  _displaySnackBar(context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  goHome(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeCoach()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String profile_pic_link = jsonDecode(widget.user_data)["img_url"] ?? null;
    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.5),
      elevation: 0,
      title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Editar foto de perfil"),
                Image.asset(
                  "img/isotipo-w.png",
                  height: 30,
                )
              ],
            ),
    );
    return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: appBar,
            key: _scaffoldKey,
            body: filling_form
        ? loader()
        : Container(
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: 25,
                        right: 25,
                        bottom: 0,
                        top: appBar.preferredSize.height +
                            MediaQuery.of(context).padding.top),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height -
                          ((appBar.preferredSize.height +
                                  MediaQuery.of(context).padding.top) *
                              2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: getImage,
                              child: Hero(
                                tag: "profile_picture",
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  margin: EdgeInsets.only(top: 0, bottom: 10),
                                  decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(250),
                                    border: Border.all(
                                        width: 3, color: Colors.white),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: _image == null
                                          ? setImage(
                                              "network",
                                              profile_pic_link != ""
                                                  ? (images_path +
                                                      profile_pic_link
                                                          .toString())
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
                            ),
                            Container(
                              width: 230,
                              margin: EdgeInsets.only(
                                  bottom: 10, left: 10, right: 10, top: 20),
                              child: RaisedButton(
                                onPressed: () {
                                  base64_img != null
                                      ? uploadPicture(context)
                                      : null;
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: base64_img != null
                                            ? [Colors.lime, Colors.lightGreen]
                                            : [Colors.grey, Colors.grey],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: double.infinity,
                                        minHeight: 40.0),
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Establecer como foto de perfil",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ));
  }
}
