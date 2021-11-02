import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tabs/Register.dart';
import 'package:flutter_tabs/src/util.dart';
import 'package:flutter_tabs/src/server.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:progress_dialog/progress_dialog.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';

import 'myDrawer.dart';

class Login extends StatelessWidget {
  localStorage storage = new localStorage();

  final formKey = GlobalKey<FormState>();
  ProgressDialog progressD;
  var response;
  BuildContext mycontext;

  String email = "";
  String pass = "";

  String usuario = '';
  Login() {
    loadUser();
    localStorage storage = new localStorage();
    usuario = storage.getUser();
  }

  loadUser() async {
    await _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuario = prefs.getString('usuario');
    //print('el usuarui es: ' + usuario);
  }

  void validar() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      sign_in();
    }
  }

  Future<void> sign_in() async {
    //show your own loading or progressing code here
    progressD.show();

    String uploadurl = server.getUrl() + "php/users.php";

    String action = "login";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': action,
        'email': email,
        'password': pass,
      });

      print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        if (jsondata["message"] != "error") {
          String nombre_app = jsondata["message"];
          List<String> temp = nombre_app.split("-");

          String nombret = temp[0].toLowerCase();
          nombret = nombret[0].toUpperCase() + nombret.substring(1);

          String apellidot = temp[1].toLowerCase();
          apellidot = apellidot[0].toUpperCase() + apellidot.substring(1);

          storage.guardar(nombret + " " + apellidot + '-' + temp[2]);
          //_save(jsondata["message"]);
          Fluttertoast.showToast(
              msg: "Sesion iniciada",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          progressD.hide();
          Navigator.push(mycontext,
              MaterialPageRoute(builder: (mycontext) => GoogleMapScreen()));

          //if error return from server, show message from server
        } else {
          Fluttertoast.showToast(
              msg: "Usuario o contraseña no válidos",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Ocurrio un error, inténtelo más tarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Error: " + e.toString());
      progressD.hide();
      //there is error during converting file image to base64 encoding.
    } finally {
      progressD.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    progressD = new ProgressDialog(context);
    progressD.style(message: 'Espere un momento...');

    return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
                child: AppBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/banner1.png',
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/banner2.png',
                          height: 30,
                        )
                      ],
                    ),
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Color(0xFFD11D5B)),
                    shape: RoundedRectangleBorder(
                      //side: BorderSide(color: Color(0xFF99CC33), width: 2.0),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    )),
                decoration: BoxDecoration(
                    //color: Colors.black,
                    border: Border.all(
                      color: Color(0xFF99CC33),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    //border: Border.all(color: Color(0xFF23D5D1)),
                    //shape: BoxShape.circle,
                    //borderRadius: BorderRadius.all(Radius.circular(50)),
                    boxShadow: [
                      //color: Colors.white, //background color of box
                      BoxShadow(
                        color: Color(0xFFC4E49A),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 6.0, //extend the shadow
                        offset: Offset(
                          0.0, // Move to right 10  horizontally
                          0.0, // Move to bottom 10 Vertically
                        ),
                      )
                    ]
                    //color: Color(0xFFe0f2f1)
                    ))),
        drawer: myDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Image.asset('assets/images/bg1.png'),
                    height: 140,
                  )),
                  Container(
                      margin:
                          const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Correo electrónico:",
                            labelStyle: TextStyle(color: Colors.green),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            )),
                        onSaved: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (!util.isValidEmail(value)) {
                            return "email no valido";
                          }
                          return null;
                        },
                      )),
                  Container(
                      margin:
                          const EdgeInsets.only(top: 30.0, left: 20, right: 20),
                      child: TextFormField(
                        obscureText: true,
                        obscuringCharacter: "*",
                        decoration: InputDecoration(
                            labelText: "Contraseña:",
                            labelStyle: TextStyle(color: Colors.green),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            )),
                        onSaved: (value) {
                          pass = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Debe llenar este campo";
                          }
                        },
                      )),
                  Container(
                      margin: const EdgeInsets.only(top: 30.0),
                      child: ElevatedButton(
                        onPressed: validar,
                        child: Text('Ingresar'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Color(0xFF8BC540),
                          padding: EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.only(top: 30.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Recuperar contraseña'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          textStyle: TextStyle(fontSize: 12),
                          primary: Color(0xFF666666),
                          padding:
                              EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        ),
                      )),
                  Divider(
                    height: 40,
                    thickness: 3,
                    color: Color(0xFFD31C5B),
                  ),
                  Text(
                    '¿Aún no tienes cuenta?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                        child: Text('Registrarse'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Color(0xFF666666),
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 15),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _returnSphereBottomNavigationBar());
  }

  //------------------------------------
  int index = 0;

  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      shadowColor: Color(0xFFC4E49A),
      defaultSelectedItem: 0,
      sheetRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      onItemPressed: (value) {
        switch (value) {
          case 0:
            Navigator.push(mycontext,
                MaterialPageRoute(builder: (context) => GoogleMapScreen()));
            break;
          case 1:
            Navigator.push(mycontext,
                MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
            break;
          case 2:
            Navigator.push(mycontext,
                MaterialPageRoute(builder: (context) => Consumo_Responsable()));
            break;
          case 3:

           Navigator.push(mycontext,
                    MaterialPageRoute(builder: (context) => Educacion()));
            /*if (!usuario.toString().contains('-')) {
              Fluttertoast.showToast(
                  msg: "Debe iniciar sesión para acceder a esta sección",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);

              Navigator.push(
                  mycontext, MaterialPageRoute(builder: (context) => Login()));
            } else {
              Navigator.push(mycontext,
                  MaterialPageRoute(builder: (context) => Educacion()));
            }*/
            break;
          default:
        }
      },
      navigationItems: [
        BuildNavigationItem(
            tooltip: 'Home',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar1.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Home'),
        BuildNavigationItem(
            tooltip: 'Chat',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar2.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Chat'),
        BuildNavigationItem(
            tooltip: 'Peoples',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar3.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Peoples'),
        BuildNavigationItem(
            tooltip: 'Settings',
            itemColor: Color(0xFFFFFF),
            icon: Image.asset(
              'assets/images/icon_bar4.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Settings'),
      ],
    );
  }
}
