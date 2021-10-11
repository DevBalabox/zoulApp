import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:zoul/extras/config.dart';

void main() => runApp(MyAppUpgd());

class MyAppUpgd extends StatelessWidget {
  MyAppUpgd({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();

    // On Android, setup the Appcast.
    // On iOS, the default behavior will be to use the App Store version of
    // the app, so update the Bundle Identifier in example/ios/Runner with a
    // valid identifier already in the App Store.
    final appcastURL =
        sparkle;
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);

    return MaterialApp(
      title: 'Upgrader Example',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Upgrader Example'),
          ),
          body: UpgradeAlert(
            appcastConfig: cfg,
            debugLogging: true,
            child: Center(child: Text('Checking...')),
          )),
    );
  }
}