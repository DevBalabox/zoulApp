import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoul/coach_login.dart';
import 'package:zoul/revenuecat.dart';
import 'home_user.dart';
import 'home_coach.dart';
import 'login.dart';
import 'testy.dart';
import 'home_coach.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
    //return MaterialApp(debugShowCheckedModeBanner: false, home: InitialScreen());
  }
}

/* Future<bool> checkUserAndNavigate(BuildContext context) async {
  return false;
} */

Future<String> checkUserAndNavigate(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_type");
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkUserAndNavigate(context).then((res) {
      if (res == "coach") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeCoach()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeUser()),
            (Route<dynamic> route) => false);
      }
    });

    return Container(
      color: Colors.white,
    );
  }
}
