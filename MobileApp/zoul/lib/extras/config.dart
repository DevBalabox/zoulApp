import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

String api_url = "https://zoulapp.com/zadmin/app/mods/mods";
String sparkle = "https://zoulapp.com/zadmin/app/zoulappcast.xml";
String coach_web_dashboard = "https://zoulapp.com/coach/";
String images_path = "https://zoulapp.com/zadmin/app/images/";
String privacy_link = "https://zoulapp.com/aviso-de-privacidad";
String support_number = "2225548302";
String delete_account_link = "https://zoulapp.com/eliminar-cuenta";
String change_password_link = "https://zoulapp.com/restablecer-contrasena";

String stripe_publishable_key =
    "pk_live_0esKpjYQornqtN44OpuxhAJF00McTi8jiL";

String revenuecat_key = "UKPkbCPhUTlBvKqErfHvhwsKTqPJvhiY";

//var zoul_primary_color = Color(0xFF114a9e);
Color zoul_primary_color = Color(0xFFff62c4);
Color zoul_secondary_color = Color(0xFFfece63);
var main_gradient = [zoul_primary_color, zoul_secondary_color];

Color main_action_color = Colors.lightGreen;
Color light_action_color = Colors.limeAccent;
var main_button_gradient = [main_action_color, light_action_color];

Color secondary_action_color = zoul_secondary_color;
Color light_secondary_action_color = Colors.orange;
var secondary_button_gradient = [
  light_secondary_action_color,
  secondary_action_color
];

Color facebook_main_color = Color(0xFF1a77f2);
Color facebook_light_color = Color(0xFF17a5fb);
var main_fb_gradient = [facebook_main_color, facebook_light_color];
var white_vertical_logo = 'img/logo-w-v.png';

setImage(type, link, decoration) {
  var imageWidget;

  if (type == "network") {
    if (decoration) {
      if (link == null || link == "") {
        imageWidget = AssetImage("img/featured2.jpg");
      } else {
        imageWidget = NetworkImage(link);
      }
    } else {
      if (link == null || link == "") {
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
  }

  return imageWidget;
}

loader() {
  return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: const CircularProgressIndicator(),
      ));
}

callSupportCenter(phone) async {
  if (phone == "" || phone == null) {
    phone = support_number;
  }
  var url = 'tel:' + phone;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No se pudo hacer la llamada $url';
  }
}

go_to_link(url) async {
  if (url != "" && url != "") {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'Hubo un problema para acceder a: $url';
    }
  }
}

Future<http.Response> register_fcm_token(user_id, fcm_token) async {
  await http.post(
    api_url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'action': "register_fcm_token",
      'user_id': user_id,
      'fcm_token': fcm_token
    }),
  );
}

Future<http.Response> clear_session_data(user_id, token, fcm_token) async {
  await http.post(
    api_url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'action': "clear_session_data",
      'user_id': user_id,
      'token': token,
      'fcm_token': fcm_token
    }),
  );
}
