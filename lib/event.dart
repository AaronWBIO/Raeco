import 'package:flutter/material.dart';
import 'package:flutter_tabs/VideoPlayerScreen.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/src/util.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:flutter_tabs/src/server.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'GoogleMapScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';

import 'myDrawer.dart';

class Event extends StatefulWidget {
  final String siteName;
  Event({Key key, @required this.siteName}) : super(key: key);

  @override
  _EventState createState() => _EventState(siteName);
}

class _EventState extends State<Event> {
  //ProgressDialog progressD;
  Future<String> loaded_data = null;
  var response;

  String site_name = "Evento";
  String description = "Info";
  String fecha = "2021-07-07";
  String horario = "0:00";
  String tag_image = "assets/images/tag_evento.png";
  String image_site = 'assets/images/image1.png';
  String image_network = server.getUrl() + "php/uploads/image1.png";
  //String image_profile = "assets/images/perfil_no_verificado.png";

  _EventState(siteName) {
    this.site_name = siteName;
  }
  @override
  void initState() {
    super.initState();

    loaded_data = loadInfo();
  }

  //------load info
  Future<String> loadInfo() async {
    //show your own loading or progressing code here
    ProgressDialog progressD = new ProgressDialog(context);
    progressD.style(message: 'Espere un momento...');
    progressD.show();

    String uploadurl = server.getUrl() + "php/get_points.php";

    response = await http.post(Uri.parse(uploadurl),
        body: {'option': 'get_event_info', 'name': site_name});

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body); //decode json data
      //print("DATOS: " + jsondata[0]['description']);
      setState(() {
        description = jsondata[0]['description'];
        fecha = jsondata[0]['date'];
        horario = jsondata[0]['time_begin'] + " - " + jsondata[0]['time_end'];

        phone = jsondata[0]['cel'];
        if (jsondata[0]['image_url'] != "") {
          image_network = server.getUrl() + jsondata[0]['image_url'];
        }
        print(image_network);

        //print("CATEGORIA: " + server.getUrl() +"/php/"+jsondata[0]['image_url']);
      });
    } else {
      print("Error during connection to server");
    }

    return 'done';
  }

  //--------------

  @override
  Widget build(BuildContext context) {
    //progressD = new ProgressDialog(context);
    //progressD.style(message: 'Espere un momento...');

    return new Scaffold(
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
      body: _returnBody(),
      drawer: myDrawer(),
    );
  }

//------------------------------------------------------------

  Widget _returnBody() {
    return (loaded_data == null
        ? Container(
            child: Center(
              child: Text(
                'Cargando información..',
                style: TextStyle(
                    fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
              ),
            ),
          )
        : Stack(
            overflow: Overflow.visible,
            //Se anexó el widget stack para poder manejar las diferentes ventanas (menu principal, ventanda de estados y ventada de categorías.)
            //se dejó de utilizar el floatingActionButton para una mejor manipulación del menú
            children: [
              getBody(),
              Positioned(
                  left: 0,
                  bottom: 0,
                  child: Stack(
                    children: [
                      //Se anexó un stack para poder integrar un container que le pueda dar el efecto y apariencia deseado a la vista (Igual al mockup)
                      Container(
                        //Container para efecto visual deseado en vista.
                        width: MediaQuery.of(context).size.width,
                        height: 30.0,
                        color: Colors.green,
                      ),
                      _returnSphereBottomNavigationBar(),
                    ],
                  )),
              Positioned(
                left: 0,
                bottom: 80, //80
                child: _showMenu(),
              ),
              Positioned(
                left: 0,
                bottom: 80, //80
                child: _showMenuInfo(),
              )
            ],
          ));
  }

//***************************************************
  _launchURL(String _url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  String phone = '';
  String insta = '';
  String facebook = '';

  double heightContainerState = 0.0;
  double heightContainerCat = 0.0;
  double showMenuHeigh = 85;
  String selectedIcon = 'assets/images/icon_watts.png';
  String labelMenu = '';
  String menuValue = '';
  Widget _showMenu() {
    return Container(
      height: showMenuHeigh,

      //margin: EdgeInsets.only(left: 15),
      child: Column(
        children: [
          SizedBox(height: 5),
          Text('Medios de contacto',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 5),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //GestureDetector(
              Expanded(
                  child: GestureDetector(
                child: Image(
                    image: AssetImage('assets/images/icon_watts.png'),
                    height: 40),
                onTap: () {
                  print(phone);
                  setState(() {
                    selectedIcon = 'assets/images/icon_watts.png';
                    showMenuHeigh = 0;
                    showMenuInfoHeigh = 150;
                    labelMenu = 'Número telefónico';
                    menuValue = phone;
                  });
                },
              )),

              //),
              Spacer(
                flex: 1,
              ),
              Expanded(
                  child: GestureDetector(
                child: Image(
                    image: AssetImage('assets/images/icon_insta.png'),
                    height: 40),
                onTap: () {
                  bool _validURL = Uri.parse(insta).isAbsolute;
                  if (_validURL) {
                    _launchURL(insta);
                  } else {
                    Fluttertoast.showToast(
                        msg: "El sitio no cuenta con página de Instagram",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.green,
                        fontSize: 16.0);
                  }
                },
              )),
              Spacer(
                flex: 1,
              ),
              Expanded(
                  child: GestureDetector(
                child: Image(
                    image: AssetImage('assets/images/icon_face.png'),
                    height: 40),
                onTap: () {
                  bool _validURL = Uri.parse(facebook).isAbsolute;
                  if (_validURL) {
                    _launchURL(facebook);
                  } else {
                    Fluttertoast.showToast(
                        msg: "El sitio no cuenta con página de Facebook",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.green,
                        fontSize: 16.0);
                  }
                },
              )),

              Spacer(
                flex: 1,
              ),
              Expanded(
                  child: GestureDetector(
                child: Image(
                    image: AssetImage('assets/images/icon_phone.png'),
                    height: 40),
                onTap: () {
                  setState(() {
                    selectedIcon = 'assets/images/icon_phone.png';
                    showMenuHeigh = 0;
                    showMenuInfoHeigh = 150;
                    labelMenu = 'Número telefónico';
                    menuValue = phone;
                  });
                },
              )),
            ],
          )
        ],
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            //bottomLeft: Radius.circular(20),
            //bottomRight: Radius.circular(20)
          )),
    );
  }

  double showMenuInfoHeigh = 0;
  Widget _showMenuInfo() {
    return Container(
      height: showMenuInfoHeigh,

      //margin: EdgeInsets.only(left: 15),
      child: Column(
        children: [
          SizedBox(height: 5),
          Text(labelMenu,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: Image(image: AssetImage(selectedIcon), height: 40),
                onTap: () {
                  setState(() {
                    //showMenuHeigh = 0;
                  });
                },
              ),

              //),
              SizedBox(
                width: 30,
              ),

              Text(menuValue,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          Container(
              width: 130,
              child: ElevatedButton(
                onPressed: () {
                  // _showDialog();
                  setState(() {
                    showMenuInfoHeigh = 0;
                    showMenuHeigh = 85;
                  });
                },
                child: Text(
                  'Regresar',
                  overflow: TextOverflow.ellipsis,
                ), // Si la variable de estado tiene algún valor, se le anexa al texto del botón
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  textStyle: TextStyle(fontSize: 16),
                  primary: Color(0xFF274E21),
                ),
              )),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            //bottomLeft: Radius.circular(20),
            //bottomRight: Radius.circular(20)
          )),
    );
  }

//***************************************************************** */

  Widget getBody() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Center(
            child: Container(
          width: MediaQuery.of(context).size.width - 20,
          height: 150,
          decoration: BoxDecoration(
              color: Colors.black87,
              //backgroundBlendMode: BlendMode.colorBurn,
              image: DecorationImage(
                  fit: BoxFit.fitHeight, image: NetworkImage(image_network))),
          //child: Image.network(image_network)
        )),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        util.capitalize(this.site_name),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ))),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset(
                        tag_image,
                        height: 35.0,
                      ),
                      //Image.asset(image_profile, height: 35.0)
                    ]),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(description))),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Fecha",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(
                          util.dateformat(this.fecha),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Horario",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Text(
                          horario,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ])
            ])),
      ],
    );
  }

//------------------------------------------------------------
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
            selectedItemColor: Color(0xFFFFFFFF),
            title: 'Home'),
        BuildNavigationItem(
            tooltip: 'Chat',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar2.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFFFF),
            title: 'Chat'),
        BuildNavigationItem(
            tooltip: 'Peoples',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar3.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFFFF),
            title: 'Peoples'),
        BuildNavigationItem(
            tooltip: 'Settings',
            itemColor: Color(0xFFFFFFFF),
            icon: Image.asset(
              'assets/images/icon_bar4.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFFFF),
            title: 'Settings'),
      ],
    );
  }
}
