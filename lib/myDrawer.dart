import 'package:flutter/material.dart';
import 'package:flutter_tabs/GoogleMapScreen.dart';
import 'package:flutter_tabs/src/Server.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'avatars.dart';
import 'login.dart';
import 'mapPicker.dart';
import 'mapPickerEvent.dart';
import 'sugerencias.dart';

class myDrawer extends StatefulWidget {
  @override
  _myDrawerState createState() => _myDrawerState();
}

class _myDrawerState extends State<myDrawer> {
  String usuario = "";
  localStorage storage = new localStorage();
  Future<String> loadedImage;
  var response;
  String avatar_image = '';

  @override
  void initState() {
    super.initState();
    loadUser();

    usuario = storage.getUser();

    loadedImage = loadAvatarImage();
  }

  loadUser() async {
    await _getUser();
    setState(() {});
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuario = prefs.getString('usuario');
    //print('el usuarui es: ' + usuario);
  }

  Future<String> loadAvatarImage() async {
    //print('-------------------------------');
    await _getUser();
    if (usuario
        .toString()
        .contains('-')) //quiere decir que el usuario ha inciado sesión
    {
      List<String> temp = usuario.split("-");
      String id = temp[1];

      String uploadurl = server.getUrl() + "php/users.php";
      response = await http.post(Uri.parse(uploadurl),
          body: {'action': 'get_avatar_image', 'id': id});

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        print('RESPUESTA: ' + jsondata["message"]);
        if (jsondata["message"] != "error" &&
            jsondata["message"].toString().contains('.')) {
          avatar_image = jsondata["message"];
          // setState(() {});
        } else {
          avatar_image = 'php/avatars/avatar0.png';
          // setState(() {});
        }
      } else {
        print("Error during connection to server");
      }
    } else {
      print('USUARIO NO HA INICIADO SESIÓN');
      avatar_image = 'php/avatars/avatar0.png';
      setState(() {});
    }

    return "done";
  }

  @override
  Widget build(BuildContext context) {
    usuario = storage.getUser();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Container(
            color: Colors.white,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                FutureBuilder(
                  future: loadedImage,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) return AvatarImage();
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  getUserName(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffD21D5B)),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/images/icon_sesion.png'),
                    width: 20,
                  ),
                  title: Text('Iniciar sesión'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/images/icon_alta_sitio.png'),
                    width: 20,
                  ),
                  title: Text('Agregar ubicación'),
                  onTap: () {
                    if (usuario == "") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => mapPicker()));
                    }
                  },
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/images/icon_event.png'),
                    width: 20,
                  ),
                  title: Text('Crear un evento'),
                  onTap: () {
                    if (usuario == "") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => mapPickerEvent()));
                    }
                  },
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/images/icon_sujerencias.png'),
                    width: 20,
                  ),
                  title: Text('Sugerencias'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Sugerencias()));
                  },
                ),
                /*ListTile(
                  leading: Image(
                    image: AssetImage('assets/images/icon_error.png'),
                    width: 20,
                  ),
                  title: Text('Reportar error'),
                  onTap: () {},
                ),*/
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.green,
                  ),
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    storage.remove();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoogleMapScreen()));
                  },
                ),
                Image(
                    image: AssetImage('assets/images/banner_menu.png'),
                    height: 100),
                Image(
                  image: AssetImage('assets/images/pnud_logo.png'),
                  height: 70,
                ),
                Image(
                  image: AssetImage('assets/images/banner_fab_menu.png'),
                  height: 60,
                )
              ],
            )),
      ),
    );
  }

  String getUserName() {
    if (usuario == '') {
      return '<Inicie sesión>';
    } else {
      List<String> temporal = usuario.split('-');
      return temporal[0];
    }
  }

  Widget AvatarImage() {
    return GestureDetector(
      child: Container(
        width: 150,
        height: 150,
        child: null,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(server.getUrl() + avatar_image),
              fit: BoxFit.cover,
            ),
            color: Colors.white,
            border: Border.all(color: Color(0xFF23D5D1)),
            shape: BoxShape.circle,
            boxShadow: [
              //color: Colors.white, //background color of box
              BoxShadow(
                color: Color(0xFFBBF3F4),
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 5.0, //extend the shadow
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  0.0, // Move to bottom 10 Vertically
                ),
              )
            ]
            //color: Color(0xFFe0f2f1)
            ),
      ),
      onTap: () {
        if (usuario == '') {
          Fluttertoast.showToast(
              msg: "Debe iniciar sesión para acceder a esta sección",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Avatars()));
        }
      },
    );
  }
}
