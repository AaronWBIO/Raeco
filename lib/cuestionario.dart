import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_tabs/src/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'avatars.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';

import 'myDrawer.dart';

class Cuestionario extends StatefulWidget {
  final String id;
  Cuestionario({Key key, @required this.id}) : super(key: key);

  @override
  _CuestionarioState createState() => _CuestionarioState(id);
}

class _CuestionarioState extends State<Cuestionario> {
  localStorage storage = new localStorage();
  int selected = 0;
  String user = '';
  String bText = 'Aceptar';
  int color1 = 0xFF666666;
  int color2 = 0xFF666666;
  int color3 = 0xFF666666;
  int color4 = 0xFF666666;

  int points = 0;
  int currentPoints = 0;
  int totalPoints = 0;

  int activeColor = 0xFF23D5D1;
  int normalColor = 0xFF666666;

  String id = "";
  String title = '';
  List<String> _list = [];
  var response;
  Future<String> loadedData;
  int indexList = 0;
//-----------------------------------------------------

  _CuestionarioState(id) {
    List<String> temp = id.split("-");
    this.id = temp[0];
    this.title = temp[1];

    print("ID: " + this.id.toString());
  }

//-----------------------------------------------------

  Future<String> loadInfo() async {
    String uploadurl = server.getUrl() + "php/education.php";

    response = await http.post(Uri.parse(uploadurl),
        body: {'action': "get_questions", 'id': this.id});

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body); //decode json data
      //print("gps: " + jsondata[i]['category']);
      for (var i = 0; i < jsondata.length; i++) {
        _list.add(jsondata[i]['question'] +
            "-" +
            jsondata[i]['image'] +
            "-" +
            jsondata[i]['option1'] +
            '-' +
            jsondata[i]['option2'] +
            '-' +
            jsondata[i]['option3'] +
            '-' +
            jsondata[i]['option4'] +
            '-' +
            jsondata[i]['value1'] +
            '-' +
            jsondata[i]['value2'] +
            '-' +
            jsondata[i]['value3'] +
            '-' +
            jsondata[i]['value4']);

        var lst = [];
        lst.add(int.parse(jsondata[i]['value1']));
        lst.add(int.parse(jsondata[i]['value2']));
        lst.add(int.parse(jsondata[i]['value3']));
        lst.add(int.parse(jsondata[i]['value4']));
        lst.sort();
        int maximo = lst[lst.length - 1];
        totalPoints += maximo;
        setState(() {});
      }

      if (_list.length == 1) {
        bText = 'Terminar';
      }
    } else {
      print("Error during connection to server");
    }
    return 'done';
  }

  Future<String> savePoints() async {
    print('Guardando puntos...');
    String uploadurl = server.getUrl() + "php/education.php";

    await _getUser();

    if (user != null) {
      List<String> temp = user.split("-");
      String id = temp[1];
      //points--;
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': "save_points",
        'id': id,
        'points': points.toString()
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print('Respuesta: ' + response.body);
        if (jsondata["message"] != "error") {
          //Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Avatars()));
          print('Puntos guardados');
        }
      } else {
        print("Error during connection to server");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Debes iniciar sesión para guardar tus puntos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    return 'done';
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getString('usuario');
    //print('el usuarui es: ' + user);
  }

//-----------------------------------------------------

  @override
  void initState() {
    super.initState();

    loadedData = loadInfo();

    loadUser();
    localStorage storage = new localStorage();
    //usuario = storage.getUser();

    loadedImage = loadAvatarImage();
  }

  loadUser() async {
    await _getUser();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  //-------Getters-------------------
  String getImage(data) {
    List<String> temp = data.split("-");

    String image_network = server.getUrl() + temp[1];
    return image_network;
  }

  String getTitle(data) {
    List<String> temp = data.split("-");

    String image_network = server.getUrl() + temp[1];
    return image_network;
  }

  String getQuestion(data) {
    List<String> temp = data.split("-");
    return temp[0];
  }

  String getOption1(data) {
    List<String> temp = data.split("-");
    return temp[2];
  }

  String getOption2(data) {
    List<String> temp = data.split("-");
    return temp[3];
  }

  String getOption3(data) {
    List<String> temp = data.split("-");
    return temp[4];
  }

  String getOption4(data) {
    List<String> temp = data.split("-");
    return temp[5];
  }

  int getPoints(String data, int option) {
    int offset = 5;
    List<String> temp = data.split("-");

    return int.parse(temp[offset + option]);
  }
  //---------------------------------

  //----------avatar image---------------------------
  Future<String> loadedImage;
  String avatar_image = '';
  Future<String> loadAvatarImage() async {
    await _getUser();
    if (user
        .toString()
        .contains('-')) //quiere decir que el usuario ha inciado sesión
    {
      List<String> temp = user.split("-");
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

  Widget AvatarImage() {
    return Container(
      width: 50,
      height: 50,
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
    );
  }
//-------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
              child: AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FutureBuilder(
                        future: loadedImage,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) return AvatarImage();
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                          return null;
                        },
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
                    color: Color(0xFF23D5D1),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  //border: Border.all(color: Color(0xFF23D5D1)),
                  //shape: BoxShape.circle,
                  //borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    //color: Colors.white, //background color of box
                    BoxShadow(
                      color: Color(0xFFBBF3F4),
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
      body: FutureBuilder(
        future: loadedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) return getContent();
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
          return null;
        },
      ),
      bottomNavigationBar: _returnSphereBottomNavigationBar(),
    );
  }

  _showDialogEnd(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Color(0xFF8EE0D6).withOpacity(0.4),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: Container(
              height: 500,
              child: Column(
                children: <Widget>[
                  Center(
                      child: Text('Puntaje final',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center)),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    child: Center(
                        child: Text(
                            points.toString() + '/' + totalPoints.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center)),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(activeColor)),
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
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          child: Text(
                              'Felicidades, haz superado esta prueba. ¡¡Consigue más puntos para desbloquear nuevas imágenes para tu avatar personlizado!!',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              textAlign: TextAlign.center))),
                  Expanded(
                      child: Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        savePoints();

                        /*Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Avatars()));*/
                      },
                      child: Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(activeColor),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  )),
                ],
              )),
        );
      },
    ).then((value) {
      //Navigator.of(context).pop();

      //_showWaitDialog(context);
    });
  }

  _showWaitDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Color(0xFF8EE0D6).withOpacity(0.4),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Center(
                      child: FutureBuilder(
                    future: savePoints(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData)
                          return Text('Datos Guardados',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center);
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.

                        return Column(children: [
                          Text('Guardando información, espere un momento',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center),
                          Center(child: CircularProgressIndicator())
                        ]);
                      }
                      return null;
                    },
                  )),
                ],
              )),
        );
      },
    );
  }

  Widget getContent() {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center))),
          Center(
              child: Container(
            margin: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 230,
                decoration: BoxDecoration(
                    color: Colors.black87,
                    //backgroundBlendMode: BlendMode.colorBurn,
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(getImage(_list[indexList])))),
                //child: Image.network(image_network)
              ),
            ),
          )),
          Container(
            margin: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
            child: Text(getQuestion(_list[indexList]),
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Table(
                /*defaultColumnWidth:
              FixedColumnWidth(MediaQuery.of(context).size.width / 2 - 10),*/
                columnWidths: {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(0.5),
                  2: FlexColumnWidth(4),
                },
                children: [
                  TableRow(children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          color1 = activeColor;
                          color2 = normalColor;
                          color3 = normalColor;
                          color4 = normalColor;

                          selected = 1;

                          currentPoints = getPoints(_list[indexList], 1);
                        });
                      },
                      child: Text(getOption1(_list[indexList])),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(color1),
                        //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          color1 = normalColor;
                          color2 = activeColor;
                          color3 = normalColor;
                          color4 = normalColor;

                          selected = 1;

                          currentPoints = getPoints(_list[indexList], 2);
                        });
                      },
                      child: Text(getOption2(_list[indexList])),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(color2),
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ]),
                  TableRow(children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          color1 = normalColor;
                          color2 = normalColor;
                          color3 = activeColor;
                          color4 = normalColor;

                          selected = 1;

                          currentPoints = getPoints(_list[indexList], 3);
                        });
                      },
                      child: Text(getOption3(_list[indexList])),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(color3),
                        //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          color1 = normalColor;
                          color2 = normalColor;
                          color3 = normalColor;
                          color4 = activeColor;

                          selected = 1;

                          currentPoints = getPoints(_list[indexList], 4);
                        });
                      },
                      child: Text(getOption4(_list[indexList])),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(color4),
                        //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ]),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  if (selected == 1) {
                    points += currentPoints;
                    Fluttertoast.showToast(
                        msg: "Conseguiste " +
                            currentPoints.toString() +
                            ' Reciclacoins',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    color1 = normalColor;
                    color2 = normalColor;
                    color3 = normalColor;
                    color4 = normalColor;

                    if (bText == 'Terminar') {
                      _showDialogEnd(context);
                    }

                    int t = indexList;
                    if (t++ < _list.length - 1) {
                      setState(() {
                        indexList++;
                      });
                    }
                    if (t == _list.length - 1) {
                      bText = 'Terminar';
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Debe seleccionar una opción',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                  selected = 0;
                },
                child: Text(bText),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  textStyle: TextStyle(fontSize: 14),
                  primary: Color(activeColor),
                  padding: EdgeInsets.symmetric(horizontal: 50),
                ),
              )),
          Text((indexList + 1).toString() + "/" + _list.length.toString()),
          SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }

  //----------------------
  int index = 0;
  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      shadowColor: Color(0xFF23D5D1),
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
              setState(() {
                // heightContainer = 0.0;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Educacion()));
              });
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
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar3.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFD11D5B),
            title: 'Peoples'),
        BuildNavigationItem(
            tooltip: 'Settings',
            itemColor: Color(0xFF23D5D1),
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
