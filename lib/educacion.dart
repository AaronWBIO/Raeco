import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/welcome.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tabs/src/server.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'cuestionario.dart';
//import 'login.dart';
import 'myDrawer.dart';

class Educacion extends StatefulWidget {
  Educacion() : super();

  @override
  _EducacionState createState() => _EducacionState();
}

class _EducacionState extends State<Educacion> {
  List<String> _list = [];
  localStorage storage = new localStorage();
  Future<String> loadedPoints;
  BuildContext mycontext;
  String data = '';
  String points = '';
  var response;
  String user = '';

  Future<void> loadInfo() async {
    String uploadurl = server.getUrl() + "php/education.php";

    response = await http.post(Uri.parse(uploadurl), body: {
      'action': "get_surveys",
    });

    //print("RESPUESTA: " + response.body);

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
            jsondata[i]['intro']);
        setState(() {});
      }
    } else {
      print("Error during connection to server");
      //there is error during connecting to server,
      //status code might be 404 = url not found
    }
  }

  /*Future<String> loadPoints() async {
    String uploadurl = server.getUrl() + "php/education.php";
    if (!user.isEmpty) {
      List<String> temp = user.split("-");
      String id = temp[1];

      print('user ID: ' + id);
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
    } else {
      points = '0';
      return "done";
    }
  }*/
  Future<String> loadPoints() async {
    try {
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
    } catch (e) {
      points = '0';
    }
    return "done";
  }

  loadUser() async {
    await _getUser();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadUser();
    user = storage.getUser();

    loadInfo();
    loadedPoints = loadPoints();

    //loadedAvatarInfo = loadAvatarInfo();
    loadedAvatarInfo = loadAvatarImage();
    //--------------

    loadedImage = loadAvatarImage2();
  }

  _getUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      user = prefs.getString('usuario');
    } catch (e) {
      user = '';
      print('no hay usuario');
    }
  }

//----------Avatar section----------------------------
  Future<String> loadedAvatarInfo;
  List<String> avatar_list = [];
  String avatar_image = '';

  /*Future<String> loadUserInfo() async {
    //print('-------------------------------');
    avatar_list.clear();

    if (user.toString().contains('-')) {
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
            List<String> temp1 =
                jsondata[0]['avatar_list'].toString().split("-");
            for (int i = 0; i < temp1.length; i++) {
              avatar_list.add(temp1[i]);
            }
          }
        }
      } else {
        print("Error during connection to server");
      }
    } else {
      avatar_image = 'php/avatars/avatar0.png';
      setState(() {});
    }

    return "done";
  }
*/
  /*Future<String> loadAvatarInfo() async {
    await loadUserInfo();
    avatar_list.clear();
    if (!user.isEmpty) {
      List<String> temp = user.split("-");

      String uploadurl = server.getUrl() + "php/education.php";

      response = await http.post(Uri.parse(uploadurl), body: {
        'action': "get_avatars",
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        for (var i = 0; i < jsondata.length; i++) {
          avatar_list.add(jsondata[i]['name'] +
              "-" +
              jsondata[i]['image'] +
              '-' +
              jsondata[i]['id'] +
              '-' +
              jsondata[i]['points']);
        }
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    }

    return 'done';
  }
*/

  Future<String> loadAvatarImage() async {
    //print('-------------------------------');
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

  String getAvatarImage() {
    print('avatar image:' + avatar_image);

    if (avatar_image == '0') {
      return server.getUrl() + 'php/avatars/avatar0.png';
    } else {
      for (int i = 0; i < avatar_list.length; i++) {
        List<String> temp = avatar_list[i].split("-");

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

//--------------------------------------------------------

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
    String intro = "";

    List<String> temp = data.split("-");
    intro = temp[2] + '-' + getName(data);
    return intro;
  }

  String getIntro(data) {
    String intro = "";

    List<String> temp = data.split("-");
    intro = temp[3];
    return intro;
  }

  _showDialog_init(BuildContext context, String value) async {
    showDialog(
      context: context,
      barrierColor: Color(0xFF8EE0D6).withOpacity(0.4),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: Container(
              height: 600,
              child: Column(
                children: <Widget>[
                  Center(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                        //color: Colors.black87,
                        //backgroundBlendMode: BlendMode.colorBurn,
                        image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(getImage(value)))),
                    //child: Image.network(image_network)
                  )),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            getName(value),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ))),
                  Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          getIntro(value),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.justify,
                        )),
                  )),
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            mycontext,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Cuestionario(id: getId(value))));
                      },
                      child: Text('Comenzar'),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(0xFF23D5D1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  )),
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 12),
                        primary: Color(0xFF666666),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ))
                ],
              )),
        );
      },
    );
  }

  showInitDialog(context, value) {
    data = value;
    _showDialog_init(context, value);
  }

  //----------avatar image---------------------------
  Future<String> loadedImage;
  String avatar_image2 = '';
  Future<String> loadAvatarImage2() async {
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

      drawer: myDrawer(
          /*onTap: (ctx, i) {
        setState(() {
          Navigator.pop(ctx);
        });
      }
      */
          ),

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
              future: loadedAvatarInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData)
                    return CircleAvatar(
                        backgroundColor: Color(0xFF66E3E6),
                        radius: 100,
                        backgroundImage:
                            NetworkImage(server.getUrl() + avatar_image));
                } else {
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
                  'Sección Educativa',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffD21D5B)),
                ))),
        new Expanded(
          child: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this would produce 2 rows.
            crossAxisCount: 2,
            // Generate 100 Widgets that display their index in the List
            children: _list.map((value) {
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
                        showInitDialog(this.mycontext, "${value}");
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
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  //----------------------
  int index = 0;
  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      defaultSelectedItem: 0,
      shadowColor: Color(0xFF23D5D1),
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
                /* Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Educacion()));*/
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
            selectedItemColor: Color(0xFFFFFFFF),
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
