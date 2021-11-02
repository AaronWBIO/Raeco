import 'package:flutter/material.dart';
import 'package:flutter_tabs/site_model.dart';

import 'package:flutter_tabs/welcome.dart';
import 'package:provider/provider.dart';

/*void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}*/
// asdasdasd
void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => new SiteModel()),
      ],
      child: MaterialApp(
        home: Welcome(),
        debugShowCheckedModeBanner: false,
      ),
    ));
