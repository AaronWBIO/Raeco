import 'package:flutter/material.dart';
import 'package:flutter_tabs/siteForm.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/src/util.dart';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tabs/src/localStorage.dart';
import 'dart:convert';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'package:flutter_tabs/src/server.dart';

import 'myDrawer.dart';

class mapPicker extends StatefulWidget {
  @override
  _mapPickerState createState() => _mapPickerState();
}

class _mapPickerState extends State<mapPicker> {
  //int index = 0;

  ProgressDialog pr;

  Set<Marker> _myMarkers = {};

  GoogleMapController mapController;
  LatLng _initialPosition;
  Geolocator geolocator = Geolocator();

  String punto;

  _setMarker(LatLng point) {
    punto = point.latitude.toString() + "," + point.longitude.toString();
    _myMarkers.clear();
    setState(() {
      _myMarkers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'Nueva ubicación',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  String usuario = "";
  @override
  void initState() {
    super.initState();

    getUserLocation();

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

  void validar() {
    if (punto != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => siteForm(last_location: punto)));
    } else {
      Fluttertoast.showToast(
          msg: "Debe seleccionar un punto en el mapa",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

//----------------------------------------

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(util.getMapStyle()); //cambiar el estilo del mapa
  }

//----------avatar image---------------------------
  var response;

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
        body: _initialPosition == null
            ? Container(
                child: Center(
                  child: Text(
                    'Cargando mapa..',
                    style: TextStyle(
                        fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Seleccione la ubicación del sitio dando click en el mapa',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xffD21D5B)),
                            )),
                        Divider(
                          height: 5,
                        ),
                        Container(
                          height: 450,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            markers: _myMarkers,
                            onTap: _setMarker,
                            initialCameraPosition: CameraPosition(
                              target: _initialPosition,
                              zoom: 14,
                            ),
                          ),
                        ),
                        Divider(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: validar,
                          child: Text('Continuar'),
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            textStyle: TextStyle(fontSize: 20),
                            primary: Color(0xFF8BC540),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                        )
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
            selectedItemColor: Color(0xFFC4E49A),
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
