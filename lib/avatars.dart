import 'dart:async';
import 'dart:convert';
import 'package:flutter_tabs/consumo_responsable.dart';
import 'package:flutter_tabs/educacion.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tabs/VideoPlayerScreen.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tabs/src/server.dart';

import 'GoogleMapScreen.dart';
import 'myDrawer.dart';

class Avatars extends StatefulWidget {
  Avatars() : super();

  @override
  _AvatarsState createState() => _AvatarsState();
}

class _AvatarsState extends State<Avatars> {
  Future<String> loadedUserInfo;
  List<String> avatar_list = [];
  String avatar_image = '';

  List<String> _list = [];
  String selectedAvatar = '';

  String selectedAvatarID = '';
  String selectedPoints = '';
  String user = '';
  String userName = '';
  String userID = '';
  String points = '';
  Future<String> loadedPoints;
  BuildContext mycontext;
  String data = '';

  var response;
  Future<void> loadInfo() async {
    await _getUser();
    //await loadUserInfo();
    List<String> temp = user.split("-");
    userName = temp[0];
    userID = temp[1];

    String uploadurl = server.getUrl() + "php/education.php";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': "get_avatars",
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        for (var i = 0; i < jsondata.length; i++) {
          _list.add(jsondata[i]['name'] +
              "-" +
              jsondata[i]['image'] +
              '-' +
              jsondata[i]['id'] +
              '-' +
              jsondata[i]['points']);
          setState(() {});
        }
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
      //progressD.hide();
      //there is error during converting file image to base64 encoding.
    } finally {
      //progressD.hide();
    }
  }

  @override
  void initState() {
    super.initState();

    //--------------
    loadInfo();

    loadedPoints = loadPoints();

    loadedUserInfo = loadUserInfo();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getString('usuario');
    //print('el usuarui es: ' + user);
  }

  Future<String> loadPoints() async {
    String uploadurl = server.getUrl() + "php/education.php";
    await _getUser();
    List<String> temp = user.split("-");
    String id = temp[1];

    //print('user ID: ' + id);
    response = await http
        .post(Uri.parse(uploadurl), body: {'action': "get_points", 'id': id});

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body); //decode json data
      if (jsondata["message"] != "error") {
        points = jsondata["message"];
        print('Puntos:' + points);
        setState(() {});
      }
    } else {
      print("Error during connection to server");
    }

    return "done";
  }

  Future<String> loadUserInfo() async {
    //print('-------------------------------');
    avatar_list.clear();
    await _getUser();
    List<String> temp = user.split("-");
    String id = temp[1];

    String uploadurl = server.getUrl() + "php/users.php";
    response = await http.post(Uri.parse(uploadurl),
        body: {'action': 'get_user_info', 'id': id});

    if (response.statusCode == 200) {
      //print('Respuesta: ' + response.body);
      var jsondata = json.decode(response.body); //decode json data

      if (jsondata.length > 0) {
        avatar_image = jsondata[0]['avatar_id'];

        //print('datos: ' + jsondata[0]['avatar_list']);
        if (jsondata[0]['avatar_list'].toString().contains('-')) {
          List<String> temp1 = jsondata[0]['avatar_list'].toString().split("-");
          for (int i = 0; i < temp1.length; i++) {
            avatar_list.add(temp1[i]);
          }
        }
      }
    } else {
      print("Error during connection to server");
    }

    return "done";
  }

  Future<String> buyAvatar() async {
    String uploadurl = server.getUrl() + "php/education.php";

    List<String> temp = user.split("-");
    String id = temp[1];

    response = await http.post(Uri.parse(uploadurl), body: {
      'action': 'buy_avatar',
      'id': id,
      'avatar_id': selectedAvatarID,
      'avatar_points': selectedPoints
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body); //decode json data
      if (jsondata["message"] != "error") {
        Navigator.push(
            mycontext, MaterialPageRoute(builder: (context) => Avatars()));
      }
    } else {
      print("Error during connection to server");
    }

    return "done";
  }

  Future<String> changeAvatar() async {
    String uploadurl = server.getUrl() + "php/users.php";

    List<String> temp = user.split("-");
    String id = temp[1];

    response = await http.post(Uri.parse(uploadurl), body: {
      'action': 'change_avatar',
      'id': id,
      'avatar_id': selectedAvatarID
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body); //decode json data
      if (jsondata["message"] != "error") {
        Navigator.push(
            mycontext, MaterialPageRoute(builder: (context) => Avatars()));
      }
    } else {
      print("Error during connection to server");
    }

    return "done";
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.

    super.dispose();
  }

  String getName(data) {
    String name = "";

    List<String> temp = data.split("-");
    name = temp[0];
    return name;
  }

  String getImage(data) {
    List<String> temp = data.split("-");

    String image_network = server.getUrl() + temp[1];
    return image_network;
  }

  String getId(data) {
    List<String> temp = data.split("-");

    return temp[2];
  }

  String getPoints(data) {
    String intro = "";

    List<String> temp = data.split("-");

    return temp[3];
  }

  /*printAvatarList() {
    for (int i = 0; i < avatar_list.length; i++) {
      print('avtars:' + avatar_list[i]);
    }
  }*/

  bool getVisibility(data) {
    for (int i = 0; i < avatar_list.length; i++) {
      //print(avatar_list[i] + '==' + data);
      if (avatar_list[i].toString() == data) {
        //print('coincide');
        return false;
      }
    }
    return true;
  }

  String getAvatarImage() {
    //print('avatar image:' + avatar_image);

    if (avatar_image == '0') {
      return server.getUrl() + 'php/avatars/avatar0.png';
    } else {
      for (int i = 0; i < _list.length; i++) {
        List<String> temp = _list[i].split("-");

        String tid = temp[2];
        //print('tid: ' + tid);
        if (tid == avatar_image) {
          //print('IMAGE: ' + temp[1]);
          return server.getUrl() + temp[1];
        }
      }

      return server.getUrl() + 'php/avatars/avatar0.png';
    }
  }

  showInitDialog(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        //transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20),
              color: Colors.black45,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '¿Quieres adquirir este avatar?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 140,
                    backgroundImage: NetworkImage(selectedAvatar),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Costo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        selectedPoints,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Image(
                        image: AssetImage('assets/images/change_white.png'),
                        width: 35,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Table(
                    /*defaultColumnWidth:
              FixedColumnWidth(MediaQuery.of(context).size.width / 2 - 10),*/
                    columnWidths: {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(0.5),
                      2: FlexColumnWidth(4),
                    },
                    children: [
                      TableRow(children: [
                        GestureDetector(
                          child: Image(
                            image:
                                AssetImage('assets/images/button_cancel.png'),
                            height: 100,
                            width: 100,
                          ),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          child: Image(
                            image: AssetImage('assets/images/button_ok.png'),
                            height: 100,
                            width: 100,
                          ),
                          onTap: () async {
                            Navigator.of(context, rootNavigator: true).pop();
                            await buyAvatar();
                          },
                        ),
                      ]),
                      TableRow(children: [
                        Text('Cancelar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        SizedBox(width: 10),
                        Text('Aceptar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ]),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    return Scaffold(
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
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

      backgroundColor: Colors.white,
      body: getBody(),
      bottomNavigationBar: _returnSphereBottomNavigationBar(),
    );
  }

  Widget getBody() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Stack(
          overflow: Overflow.visible,
          children: [
            FutureBuilder(
              future: loadedUserInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData)
                    return CircleAvatar(
                        backgroundColor: Color(0xFF66E3E6),
                        radius: 100,
                        backgroundImage: NetworkImage(getAvatarImage()));
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.

                  return Center(child: CircularProgressIndicator());
                }
                return null;
              },
            ),
            Positioned(
                bottom: -20,
                left: 160,
                child: Container(
                  width: 100,
                  height: 100,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Image(
                        image: AssetImage('assets/images/change_icon.png'),
                        width: 20,
                      ),
                      Center(
                          child: Text('Reciclacoins',
                              style: TextStyle(
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center)),
                      Center(
                          child: FutureBuilder(
                        future: loadedPoints,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData)
                              return Text(points,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                  textAlign: TextAlign.center);
                          } else {
                            // If the VideoPlayerController is still initializing, show a
                            // loading spinner.

                            return Center(child: CircularProgressIndicator());
                          }
                          return null;
                        },
                      ))
                    ],
                  ),
                  decoration: BoxDecoration(
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
                ))
          ],
        ),
        Align(
            alignment: Alignment.center,
            child: Container(
                margin: const EdgeInsets.only(top: 30.0, left: 10),
                child: Text(
                  userName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffD21D5B)),
                ))),
        new Expanded(
          child: FutureBuilder(
            future: loadedUserInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) return getListContent();
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.

                return Center(child: CircularProgressIndicator());
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget getListContent() {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this would produce 2 rows.
      crossAxisCount: 3,
      // Generate 100 Widgets that display their index in the List
      children: _list.map((value) {
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(8),
          child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,
                    children: [
                      Container(
                          //backgroundColor: Colors.white,
                          height: 90,
                          width: 90,
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: getImage("${value}"),
                              width: 30),
                          decoration: BoxDecoration(
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
                              )),
                      Visibility(
                          visible: getVisibility(getId("${value}")),
                          child: Positioned(
                            bottom: -20,
                            left: 50,
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Center(
                                      child: Image(
                                    image: AssetImage(
                                        'assets/images/change_white.png'),
                                    width: 20,
                                  )),
                                  Center(
                                      child: Text(getPoints("${value}"),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center))
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFFA1BF65),
                                  shape: BoxShape.circle,
                                  boxShadow: []
                                  //color: Color(0xFFe0f2f1)
                                  ),
                            ),
                          ))
                    ],
                  )
                ],
              ),
              onTap: () {
                selectedAvatar = getImage("${value}");
                selectedPoints = getPoints("${value}");
                selectedAvatarID = getId("${value}");
                //si no tiene visibilidad, solo cambiar el avatar
                if (!getVisibility(selectedAvatarID)) {
                  changeAvatar();
                }
                //comprar y cambiar
                else {
                  if (int.parse(points) >= int.parse(selectedPoints)) {
                    showInitDialog(context);
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            "Debes conseguir más Reciclacoins para obtener este avatar",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
              }),
        );
      }).toList(),
    );
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
                // heightContainer = 0.0;
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
            selectedItemColor: Color(0xFF23D5D1),
            title: 'Settings'),
      ],
    );
  }
}
