import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

getUserDataArray(BuildContext context) async {
  String user_id = "";
  String token = "";
  String user_data = "";

  SharedPreferences prefs = await SharedPreferences.getInstance();
  user_id = (prefs.getString('user_id') ?? null);
  token = (prefs.getString('token') ?? null);
  user_data = (prefs.getString('user_data') ?? null);
  if (user_data != null && token != null && user_id != null) {
    return user_data;
  } else {
    return null;
  }
}

getUserToken(BuildContext context) async {
  String token = "";

  SharedPreferences prefs = await SharedPreferences.getInstance();
  token = (prefs.getString('token') ?? null);
  if (token != null) {
    return token;
  } else {
    return null;
  }
}

setSubscriptionStatus(status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_status', status);
}

getSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('subscription_status') ?? "inactive";
}