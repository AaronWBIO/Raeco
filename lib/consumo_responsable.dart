import 'package:flutter/material.dart';

import 'package:flutter_tabs/consumo_intro.dart';
import 'package:flutter_tabs/pdf_visor.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';

import 'package:flutter_tabs/src/util.dart';
import 'package:flutter_tabs/welcome.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import 'dart:convert';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tabs/src/server.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'educacion.dart';
import 'login.dart';
import 'myDrawer.dart';

class Consumo_Responsable extends StatefulWidget {
  @override
  _Consumo_ResponsableState createState() => _Consumo_ResponsableState();
}

class _Consumo_ResponsableState extends State<Consumo_Responsable> {
  List<String> _categories = [];
  List<String> _infographics = [];
  List<String> _recommendations = [];
  String filter = "todos";
  var cont = 0;
  //ProgressDialog progressD;
  var response;

  var flag = 0;
//-----------------------------------------------------
  Future<String> loaded_categories;
  Future<String> loaded_infographics;
  Future<String> loaded_recommendations;

  String infos = '';

  Future<String> dialog_loaded;
  Future<String> loadCategories() async {
    String uploadurl = server.getUrl() + "php/consumo_responsable.php";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': "get_categories",
      });

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        for (var i = 0; i < jsondata.length; i++) {
          _categories.add(jsondata[i]['name'] + "-" + jsondata[i]['image']);
          //_categories.add(jsondata[i]['name']);
          setState(() {});
        }
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
      //progressD.hide();
    } catch (e) {
      /*Fluttertoast.showToast(
          msg: "Ocurrio un error, inténtelo más tarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);*/
      print("Error: " + e.toString());

      //there is error during converting file image to base64 encoding.
    } finally {}
    cont = cont + 1;
    return "done";
  }

  Future<String> loadInfographics() async {
    _infographics.clear();
    String uploadurl = server.getUrl() + "php/consumo_responsable.php";

    try {
      response = await http.post(Uri.parse(uploadurl),
          body: {'action': "get", 'filter': filter});

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        //print(jsondata);
        for (var i = 0; i < jsondata.length; i++) {
          _infographics.add(jsondata[i]['name'] +
              "-" +
              jsondata[i]['cover_image'] +
              "-" +
              jsondata[i]['file'] +
              '-' +
              jsondata[i]['id']);

          setState(() {});
        }
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
      //progressD.hide();
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

      //there is error during converting file image to base64 encoding.
    } finally {
      //progressD.hide();
    }
    cont = cont + 1;
    return "done";
  }

  loadRecommendations() async {
    _recommendations.clear();

    List<String> temp = infos.split("-");

    for (int i = 0; i < _infographics.length; i++) {
      String id = getID(_infographics[i]);
      if (!temp.contains(id)) {
        _recommendations.add(_infographics[i]);
      }
    }

    if (_recommendations.length == 0 && _infographics.length > 0) {
      _recommendations.add(_infographics[0]);
    }
    setState(() {
      _recommendations;
    });
    return 'done';
  }

  infographicsLoaded(String name) async {
    String uploadurl = server.getUrl() + "php/consumo_responsable.php";
    try {
      response = await http.post(Uri.parse(uploadurl),
          body: {'action': "update_infographics", 'name': name});

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        setState(() {
          loadInfographics();
        });
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    } catch (e) {
      /*Fluttertoast.showToast(
          msg: "Ocurrio un error, inténtelo más tarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);*/
      print("Error: " + e.toString());
    } finally {}
  }

  String getName(String cadena) {
    String name = "";

    List<String> temp = cadena.split("-");
    name = temp[0];
    return name;
  }

  String getImage(String cadena) {
    String name = "";

    List<String> temp = cadena.split("-");

    name = server.getUrl() + temp[1];
    return name;
  }

  String getFile(String cadena) {
    String name = "";

    List<String> temp = cadena.split("-");

    name = server.getUrl() + temp[2];
    return name;
  }

  String getID(String cadena) {
    String name = "";

    List<String> temp = cadena.split("-");

    name = temp[3];
    return name;
  }

  bool getVisible(String cadena) {
    List<String> temp = cadena.split("-");
    if (temp[3] == "load") {
      return true;
    } else {
      return false;
    }
  }
//-----------------------------------------------------

  String usuario = '';
  @override
  void initState() {
    super.initState();
    loaded_categories = loadCategories();
    loaded_infographics = loadInfographics();
    //loaded_recommendations = loadRecommendations();

    initLocal();

    loadUser();
    localStorage storage = new localStorage();
    usuario = storage.getUser();
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

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  _launchURL(String _url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  Future<String> _showDialog_init(BuildContext context) async {
    if (flag == 0) {
      flag = flag + 1;
      showDialog(
        context: context,
        barrierColor: Color(0xFFD11D5B).withOpacity(0.4),
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            content: Consumo_intro(),
          );
        },
      ).then((value) {
        // load(context);
      });
      return "done";
    } else {
      return "empty";
    }
  }

  /*void load(BuildContext context) {
    progressD = ProgressDialog(context);
    progressD.style(
      message: 'Cargando información',
    );
    loadInfo();
  }*/

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => _showDialog_init(context));
    print(flag);
    return Scaffold(
      backgroundColor: Colors.white,
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
                      GestureDetector(
                        child: Image.asset(
                          'assets/images/banner2.png',
                          height: 30,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Welcome()));
                        },
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
                    color: Color(0xFFD11D5B),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  //border: Border.all(color: Color(0xFF23D5D1)),
                  //shape: BoxShape.circle,
                  //borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    //color: Colors.white, //background color of box
                    BoxShadow(
                      color: Color(0xFFFF97BA),
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
      body: getBody(),
      bottomNavigationBar: _returnSphereBottomNavigationBar(),
    );
  }

  Widget getBody() {
    return Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topCenter,
            child: Container(
                //height: 100,
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Filtrar por categoría',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ))),
        FutureBuilder(
          future: loaded_categories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData)
                return Container(
                  height: 130,
                  margin: const EdgeInsets.only(top: 20.0),
                  //child: new Expanded(
                  child: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this would produce 2 rows.
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 0.0,
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 1,
                    // Generate 100 Widgets that display their index in the List
                    children: _categories.map((value) {
                      return Container(
                        alignment: Alignment.center,
                        //height: 50,
                        /*decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black, // Set border color
                        width: 3.0), // Set border width
                  ),*/
                        //margin: EdgeInsets.all(40),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  print(getName("${value}"));
                                  this.filter = getName("${value}");
                                  //loadInfographics();
                                  setState(() {
                                    _infographics.clear();
                                    loadInfographics();
                                  });
                                },
                                child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loading.gif',
                                    image: getImage("${value}"),
                                    width: 80)
                                /*Image.network(getImage("${value}"),
                                    width: 80),
                                onTap: () {
                                  //_launchURL(getFile("${value}"));
                                }*/
                                ),
                            Text(
                              getName("${value}"),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  //),
                );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.

              return Center(child: CircularProgressIndicator());
            }
            return null;
          },
        ),
        /*Align(
            alignment: Alignment.topCenter,
            child: Container(
                //height: 100,
                margin: const EdgeInsets.only(top: 0.0),
                child: Text(
                  'Recomendaciones',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ))),*/
        /*FutureBuilder(
          future: loadRecommendations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData)
                return Container(
                  height: 130,
                  margin: const EdgeInsets.only(top: 20.0),
                  //child: new Expanded(
                  child: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this would produce 2 rows.
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 0.0,
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 1,
                    // Generate 100 Widgets that display their index in the List
                    children: _recommendations.map((value) {
                      return Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  _launchURL(getFile("${value}"));
                                },
                                child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loading.gif',
                                    image: getImage("${value}"),
                                    width: 80)),
                            Text(
                              getName("${value}"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  //),
                );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return Center(child: CircularProgressIndicator());
            }

            return null;
          },
        ),*/
        Align(
            alignment: Alignment.topCenter,
            child: Container(
                //height: 100,
                margin: const EdgeInsets.only(top: 0.0, bottom: 10),
                child: Text(
                  'Todos los títulos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ))),
        SizedBox(
          height: 20,
        ),
        FutureBuilder(
          future: loaded_infographics,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                //loadRecommendations();

                return new Expanded(
                    child: GridView.count(
                  //shrinkWrap: true,
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this would produce 2 rows.
                  //childAspectRatio: 1.3,
                  //mainAxisSpacing: 0,

                  //crossAxisSpacing: 15.0,
                  //scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  // Generate 100 Widgets that display their index in the List
                  children: _infographics.map((value) {
                    return Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                              child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/loading.gif',
                                  image: getImage("${value}"),
                                  width: 120),
                              onTap: () {
                                //print(getFile("${value}"));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfVisor(
                                            pdf_url: getFile("{$value}"))));
                              },
                            )),
                            Text(
                              getName("${value}"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            )
                          ],
                        ));
                    ;
                    /*Stack(
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              //funcion1(getID('${value}'));

                              var id = getID("${value}");

                              String name = "";
                              List<String> temp = infos.split("-");

                              _launchURL(getFile("${value}"));
                              if (!temp.contains(id)) {
                                updateInfos(infos + '-' + id);
                              }

                              //infographicsLoaded(getName("${value}"));
                            },
                            child: Container(
                                decoration:
                                    new BoxDecoration(color: Colors.white),
                                alignment: Alignment.center,
                                height: 90,
                                child: Image.network(getImage("${value}"),
                                    fit: BoxFit.fill))),
                        Container(
                          margin: const EdgeInsets.only(top: 30.0),
                          alignment: Alignment.center,
                          child: Text(getName("${value}"),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              textAlign: TextAlign.center),
                        ),
                        Visibility(
                            visible: getVisible("${value}"),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.check, color: Colors.green),
                            ))
                      ],
                    );*/
                  }).toList(),
                ));
              }
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return Center(child: CircularProgressIndicator());
            }
            return null;
          },
        ),
      ],
    );
  }

  void initLocal() {
    funcion4().then((res) {
      print(infos);
      //loaded_recommendations = loadRecommendations();
    });
  }

  void getInfos() {
    funcion5().then((res) {
      print('infos: ' + infos);
    });
  }

  void updateInfos(value) {
    funcion6(value).then((res) {
      print('infos: ' + infos);
    });
  }

  funcion4() async {
    // Add your onPressed code here!

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('infos');
    // Reading data

    infos = prefs.getString('infos');
    if (infos == null) {
      await prefs.setString('infos', '');
    }
  }

  funcion5() async {
    // Add your onPressed code here!

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('infos');
    // Reading data

    this.infos = prefs.getString('infos');
  }

  funcion6(value) async {
    // Add your onPressed code here!

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('infos');
    // Reading data

    await prefs.setString('infos', value);
  }

//----------------------
  int index = 0;
  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      shadowColor: Color(0xFFD11D5B),
      defaultSelectedItem: 0,
      sheetRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      onItemPressed: (value) => {
        setState(() {
          this.index = value;
          print('Selected item is - $index');
          switch (value) {
            case 0:
              setState(() {
                //heightContainer = 30.0;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GoogleMapScreen()));
              });
              break;
            case 1:
              setState(() {
                // heightContainer = 0.0;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen()));
              });
              break;
            case 2:
              setState(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Consumo_Responsable()));
              });
              break;
            case 3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Educacion()));

              /*setState(() {
                // heightContainer = 0.0;
                if (!usuario.toString().contains('-')) {
                  Fluttertoast.showToast(
                      msg: "Debe iniciar sesión para acceder a esta sección",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Educacion()));
                }
              });*/
              break;
            default:
          }
        })
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
            selectedItemColor: Color(0xFFFDB13B),
            title: 'Chat'),
        BuildNavigationItem(
            tooltip: 'Peoples',
            itemColor: Color(0xFFD11D5B),
            icon: new Image.asset(
              'assets/images/icon_bar3.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFD11D5B),
            title: 'Peoples'),
        BuildNavigationItem(
            tooltip: 'Settings',
            itemColor: Color(0xFFFFFF),
            icon: Image.asset(
              'assets/images/icon_bar4.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFB2D9),
            title: 'Settings'),
      ],
    );
  }
}
