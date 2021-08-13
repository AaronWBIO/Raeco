import 'package:flutter/material.dart';

import 'package:flutter_tabs/welcome.dart';

/*void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}*/

void main() => runApp(new MaterialApp(
      home: Welcome(),
      debugShowCheckedModeBanner: false,
    ));
