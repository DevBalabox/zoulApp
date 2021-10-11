import 'package:flutter/material.dart';
import 'package:zoul/extras/config.dart';
import 'edit_user_profile.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  String user_data;
  ProfileScreen(this.user_data);
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    String user_name = jsonDecode(widget.user_data)["name"] ?? null;
    String first_lastname =
        jsonDecode(widget.user_data)["first_lastname"] ?? null;
    String second_lastname =
        jsonDecode(widget.user_data)["second_lastname"] ?? null;
    String mail = jsonDecode(widget.user_data)["mail"] ?? null;
    String birthdate = jsonDecode(widget.user_data)["birth_date"] ?? null;
    String profile_pic_link = jsonDecode(widget.user_data)["img_url"] ?? null;

    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.0),
      elevation: 0,
      title: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Perfil"),
          )
        ],
      ),
    );

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.only(top: 0),
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
                          "¡Hola, " + user_name.toString() + "!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.all(10),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 3, color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Nombre Completo: ',
                                  style: new TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              user_name.toString() +
                                  " " +
                                  first_lastname.toString() +
                                  " " +
                                  second_lastname.toString(),
                              style: TextStyle(color: Colors.black87))
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: SizedBox(
                        height: 0.5,
                        width: double.infinity,
                        child: const DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.mail,
                                size: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Correo: ',
                                  style: new TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(mail.toString(),
                              style: TextStyle(color: Colors.black87))
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: SizedBox(
                        height: 0.5,
                        width: double.infinity,
                        child: const DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.grey),
                        ),
                      ),
                    ),
                    /* Text(
                      "Miembro desde el 30 de Abril del 2020",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic),
                    ) */
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 25, left: 10, right: 10),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditUserProfile(
                              widget.user_data, profile_pic_link)),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: secondary_button_gradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, minHeight: 40.0),
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Editar mi perfil",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  go_to_link(delete_account_link);
                },
                child: Text(
                  "Dar de baja mi cuenta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
