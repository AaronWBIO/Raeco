import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:flutter_tabs/src/util.dart';
import 'package:flutter_tabs/src/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'login.dart';
import 'myDrawer.dart';

class Register extends StatelessWidget {
  ProgressDialog progressD;
  var response;

  BuildContext mycontext;

  final formKey = GlobalKey<FormState>();

  String name = "";
  String lastName = "";
  String email = "";
  String gender = "";
  String age = "";
  String ocupacy = "";
  String user = "";
  String pass1 = "";
  String pass2 = "";

  String usuario = '';
  Register() {
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

  final List<Map<String, dynamic>> _gender = [
    {
      'value': 'Masculino',
      'label': 'Masculino',
    },
    {
      'value': 'Femenino',
      'label': 'Femenino',
    },
    {
      'value': 'No binario',
      'label': 'No binario',
    },
    {
      'value': 'Omitir',
      'label': 'Omitir',
    }
  ];

  final List<Map<String, dynamic>> _ageRange = [
    {
      'value': 'Menor a 18',
      'label': 'Menor a 18',
    },
    {
      'value': '18 años a 24 años',
      'label': '18 años a 24 años',
    },
    {
      'value': '25 años a 34 añoss',
      'label': '25 años a 34 años',
    },
    {
      'value': '35 años a 44 años',
      'label': '35 años a 44 años',
    },
    {
      'value': '> 45 años',
      'label': '> 45 años',
    },
  ];

  final List<Map<String, dynamic>> _ocupacy = [
    {
      'value': 'Estudiante',
      'label': 'Estudiante',
    },
    {
      'value': 'Profesionista',
      'label': 'Profesionista',
    },
    {
      'value': 'Técnico',
      'label': 'Técnico',
    },
    {
      'value': 'Trabajador de la Educación',
      'label': 'Trabajador de la Educación',
    },
    {
      'value': 'Trabajador del Arte, Espectáculo y deportes',
      'label': 'Trabajador del Arte, Espectáculo y deportes',
    },
    {
      'value': 'Funcionario del sector público o prívado',
      'label': 'Funcionario del sector público o prívado',
    },
    {
      'value': 'Trabajador en Actividades Agrícolas',
      'label': 'Trabajador en Actividades Agrícolas',
    },
    {
      'value': 'Jefe, supervisor o directivo',
      'label': 'Jefe, supervisor o directivo',
    },
    {
      'value': 'Ama de casa',
      'label': 'Ama de casa',
    },
    {
      'value': 'Artesano',
      'label': 'Artesano',
    },
    {
      'value': 'Ayudante o peón',
      'label': 'Ayudante o peón',
    },
    {
      'value': 'Conductor',
      'label': 'Conductor',
    },
    {
      'value': 'Comerciante',
      'label': 'Comerciante',
    },
    {
      'value': 'Trabajador Administrativo',
      'label': 'Trabajador Administrativo',
    },
    {
      'value': 'Trabajador en servicios domésticos',
      'label': 'Trabajador en servicios domésticos',
    },
  ];

  Future<void> save_register() async {
    //show your own loading or progressing code here
    progressD.show();

    String uploadurl = server.getUrl() + "php/users.php";

    String action = "save";
    String cabeceras =
        "name, last_name, gender, age_range, ocupacy, email, password, points, avatar_id, avatar_list";
    String valores = "'" +
        name.toUpperCase() +
        "' , '" +
        lastName.toUpperCase() +
        "' , '" +
        gender +
        "' , '" +
        age +
        "' , '" +
        ocupacy +
        "' , '" +
        email +
        "', '" +
        pass1 +
        "' , '0', '0', ''";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': action,
        'cabeceras': cabeceras,
        'valores': valores,
      });

      print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        if (jsondata["message"] == "ok") {
          Fluttertoast.showToast(
              msg: "Información guardada exitosamente",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          progressD.hide();
          Navigator.push(
              mycontext, MaterialPageRoute(builder: (mycontext) => Login()));

          //if error return from server, show message from server
        } else {
          print("Ocurrio un error: " + jsondata["message"]);
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
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Error: " + e.toString());
      progressD.hide();
      //there is error during converting file image to base64 encoding.
    } finally {
      progressD.hide();
    }
  }

  void validar() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (pass1 == pass2) {
        save_register();
      } else {
        Fluttertoast.showToast(
            msg: "Las contraseñas no coinciden",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
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
      bottomNavigationBar: _returnSphereBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(
                    child: Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Registro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ))),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Nombre",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                      onSaved: (value) {
                        name = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Debe llenar este campo";
                        }
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Apellido:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                      onSaved: (value) {
                        lastName = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Debe llenar este campo";
                        }
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: SelectFormField(
                      initialValue: '',
                      items: _gender,
                      onChanged: (val) => gender = val,
                      onSaved: (val) => gender = val,
                      validator: (value) {
                        if (value.isEmpty) {
                          //return "Debe llenar este campo";
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Género:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: SelectFormField(
                      initialValue: '',
                      items: _ageRange,
                      onChanged: (val) => age = val,
                      onSaved: (val) => age = val,
                      validator: (value) {
                        if (value.isEmpty) {
                          //return "Debe llenar este campo";
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Rango de edad:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: SelectFormField(
                      initialValue: '',
                      items: _ocupacy,
                      onChanged: (val) => ocupacy = val,
                      onSaved: (val) => ocupacy = val,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Debe llenar este campo";
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Ocupación:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Correo electrónico:",
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
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Contraseña:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                      onSaved: (value) {
                        pass1 = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Debe llenar este campo";
                        }
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Confirmar contraseña:",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                      onSaved: (value) {
                        pass2 = value;
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
                      child: Text('Finalizar'),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 20),
                        primary: Color(0xFF8BC540),
                        padding:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
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
