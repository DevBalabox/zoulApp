import 'package:flutter/material.dart';
import 'package:zoul/extras/config.dart';
import 'edit_coach_picture.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class CoachProfile extends StatefulWidget {
  String user_data;
  String token;
  CoachProfile(this.user_data,this.token);
  @override
  _CoachProfile createState() => _CoachProfile();
}

class _CoachProfile extends State<CoachProfile> {

  @override
  Widget build(BuildContext context) {
    String user_name = jsonDecode(widget.user_data)["name"] ?? null;
    String first_lastname =
        jsonDecode(widget.user_data)["first_lastname"] ?? null;
    String second_lastname =
        jsonDecode(widget.user_data)["second_lastname"] ?? null;
    String mail = jsonDecode(widget.user_data)["mail"] ?? null;
    String biography = jsonDecode(widget.user_data)["biography"] ?? null;
    String phone = jsonDecode(widget.user_data)["phone"] ?? null;
    String birthdate = jsonDecode(widget.user_data)["birth_date"] ?? null;
    String profile_pic_link = jsonDecode(widget.user_data)["img_url"] ?? null;

    AppBar appBar = AppBar(
      backgroundColor: Color(0xFF114a9e).withOpacity(0.5),
      elevation: 0,
      title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Perfil"),
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
                                      EditCoachPicture(widget.user_data, widget.token)),
                            );
                          },
                          child: Hero(
                            tag: "profile_picture",
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 0, bottom: 10),
                              decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border:
                                    Border.all(width: 3, color: Colors.white),
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
                          biography.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
                              user_name +
                                  " " +
                                  first_lastname +
                                  " " +
                                  second_lastname,
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
                          Text(mail, style: TextStyle(color: Colors.black87))
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
                                Icons.phone,
                                size: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Teléfono: ',
                                  style: new TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(phone, style: TextStyle(color: Colors.black87))
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
                                Icons.calendar_today,
                                size: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Fecha de nacimiento: ',
                                  style: new TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(birthdate,
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
                    Text(
                      "¡Hola, " +
                          user_name +
                          ", por políticas de Zoul, no podrás hacer ediciones a tu perfil diréctamente más que tu foto de perfil, si deseas corregir o cambiar algo llámanos!",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5, left: 10, right: 10),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditCoachPicture(widget.user_data, widget.token)),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF114a9e), Colors.lightBlue],
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
                            Icons.photo,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Editar mi foto de perfil",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 25, left: 10, right: 10),
                child: RaisedButton(
                  onPressed: () {
                    callSupportCenter(support_number);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lime, Colors.lime],
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
                            "Solicitar cambios en mi información",
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
                  callSupportCenter(support_number);
                },
                child: Text(
                  "Solicitar baja de mi cuenta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height:20),
              InkWell(
                onTap: () {
                  go_to_link(change_password_link);
                },
                child: Text(
                  "Cambiar contraseña",
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
