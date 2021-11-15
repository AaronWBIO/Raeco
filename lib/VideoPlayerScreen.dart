import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tabs/GoogleMapScreen.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/welcome.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tabs/src/server.dart';

import 'package:url_launcher/url_launcher.dart';

import 'consumo_responsable.dart';
import 'educacion.dart';
import 'myDrawer.dart';

//import 'package:flutter_tabs/pdf_visor.dart';
import 'package:flutter_tabs/image_visor.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen() : super();

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool showPlay = true;

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  List<String> _list = [];

  var response;
  Future<void> loadInfo() async {
    //show your own loading or progressing code here
    //ProgressDialog progressD = new ProgressDialog(context);
    //progressD.style(message: 'Espere un momento...');
    //progressD.show();

    String uploadurl = server.getUrl() + "php/recicla_comparte.php";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'action': "get",
      });

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        for (var i = 0; i < jsondata.length; i++) {
          _list.add(jsondata[i]['name'] +
              "-" +
              jsondata[i]['cover_image'] +
              "-" +
              jsondata[i]['file']);
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

  String usuario = '';
  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      server.getUrl() + 'videos/recicla_comparte.mp4',
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(false);

    super.initState();

    //--------------
    loadInfo();

    loadUser();
    localStorage storage = new localStorage();
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

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
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
    return name.replaceAll('}', '');
  }

  _launchURL(String _url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

//----------avatar image---------------------------
  Future<String> loadedImage;
  String avatar_image = '';
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
      backgroundColor: Colors.white,
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
                    color: Color(0xFFFDB13B),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  //border: Border.all(color: Color(0xFF23D5D1)),
                  //shape: BoxShape.circle,
                  //borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    //color: Colors.white, //background color of box
                    BoxShadow(
                      color: Color(0xFFFDB13B),
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
        GestureDetector(
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return AspectRatio(
                  aspectRatio: 5 / 2,
                  //aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: Stack(children: [
                    VideoPlayer(_controller),
                    Center(
                        child: Visibility(
                            visible: showPlay,
                            child: Image.asset(
                              'assets/images/icon_play.png',
                              width: 50,
                            )))
                  ]),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          onTap: () {
            setState(() {
              // If the video is playing, pause it.
              if (_controller.value.isPlaying) {
                _controller.pause();
                showPlay = true;
              } else {
                // If the video is paused, play it.
                _controller.play();
                showPlay = false;
              }
            });
          },
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
                margin: const EdgeInsets.only(top: 20.0, left: 10),
                child: Text(
                  'Recicla, repara y comparte',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ))),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
                margin: const EdgeInsets.only(top: 5.0, left: 10),
                child: Text(
                  'En esta sección encontrarás diferentes guías para llevar a cabo acciones que te permitan prolongar la vida útil de los aparatos electrónicos evitando que se conviertan en residuos "RAE"',
                  style: TextStyle(fontSize: 12, color: Colors.black),
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
                          width: 100),
                      onTap: () {
                        //_launchURL(getFile("{$value}"));
                        print(getFile("{$value}"));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    image_visor(pdf_url: getFile("{$value}"))));
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
      shadowColor: Color(0xFFFDB13B),
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

                if (_controller.value.isPlaying) {
                  _controller.pause();
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GoogleMapScreen()));
              });
              break;
            case 1:
              /*setState(() {
                // heightContainer = 0.0;

                if (_controller.value.isPlaying) {
                  _controller.pause();
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen()));
              });*/
              break;
            case 2:
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                }
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
                if (_controller.value.isPlaying) {
                  _controller.pause();
                }
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
            itemColor: Color(0xFFFDB13B),
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
