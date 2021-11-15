import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/src/util.dart';
import 'package:http/http.dart' as http;

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'myDrawer.dart';
import 'package:photo_view/photo_view.dart';

import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class image_visor extends StatefulWidget {
  final String pdf_url;
  image_visor({Key key, @required this.pdf_url}) : super(key: key);

  @override
  _image_visorState createState() => _image_visorState(pdf_url);
}

class _image_visorState extends State<image_visor> {
  String pdf_url;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    loadUser();
    localStorage storage = new localStorage();
    usuario = storage.getUser();

    loadedImage = loadAvatarImage();

    print('url: ' + pdf_url);
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

  _image_visorState(pdf_url) {
    this.pdf_url = pdf_url;
  }

  //----------avatar image---------------------------
  String usuario = '';
  var response;
  String avatar_image = '';
  Future<String> loadedImage;

  Future<String> loadAvatarImage() async {
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
        body: Center(
            child: PhotoView(
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 60.0,
              height: 60.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
          imageProvider: NetworkImage(this.pdf_url),
          backgroundDecoration: BoxDecoration(color: Colors.white),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            if (pdf_url.contains("infographics")) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Consumo_Responsable()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
            }
          },
          child: const Icon(Icons.arrow_back),
          backgroundColor: Colors.green,
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Educacion()));
              /* setState(() {
                // heightContainer = 0.0;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Educacion()));
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
            itemColor: Color(0xFFFFFF),
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
