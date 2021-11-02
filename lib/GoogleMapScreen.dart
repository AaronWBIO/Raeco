import 'package:flutter/material.dart';
import 'package:flutter_tabs/VideoPlayerScreen.dart';
import 'package:flutter_tabs/consumo_responsable.dart';
import 'package:flutter_tabs/educacion.dart';
import 'package:flutter_tabs/login.dart';
import 'package:flutter_tabs/site.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/src/util.dart';
import 'package:flutter_tabs/welcome.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tabs/src/localStorage.dart';

import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import 'dart:convert';
import 'package:select_form_field/select_form_field.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tabs/src/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';
import 'myDrawer.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController mapController;

  ProgressDialog progressD;

  String usuario = '';

  double capitalLat;
  double capitalLon;

  //---------
  var response;
  String selectedState = "";
  String selectedCategory = "";
  final Map<String, Marker> _markers = {};

  Set<Marker> _myMarkers = {};
  BitmapDescriptor acopio_icon;
  BitmapDescriptor reparacion_icon;
  BitmapDescriptor mantenimiento_icon;
  BitmapDescriptor oficial_icon;
  BitmapDescriptor evento_icon;

  LatLng _initialPosition;

  Geolocator geolocator = Geolocator();
  LatLng latLngPosition;

  String state = "";
  final List<Map<String, dynamic>> _states = [
    {
      'value': 'Aguascalientes',
      'label': 'Aguascalientes',
    },
    {
      'value': 'Baja California',
      'label': 'Baja California',
    },
    {
      'value': 'Baja California Sur',
      'label': 'Baja California Sur',
    },
    {
      'value': 'Campeche',
      'label': 'Campeche',
    },
    {
      'value': 'Chiapas',
      'label': 'Chiapas',
    },
    {
      'value': 'Chihuahua',
      'label': 'Chihuahua',
    },
    {
      'value': 'Ciudad de México',
      'label': 'Ciudad de México',
    },
    {
      'value': 'Coahuila de Zaragoza',
      'label': 'Coahuila de Zaragoza',
    },
    {
      'value': 'Colima',
      'label': 'Colima',
    },
    {
      'value': 'Durango',
      'label': 'Durango',
    },
    {
      'value': 'Estado de México',
      'label': 'Estado de México',
    },
    {
      'value': 'Guanajuato',
      'label': 'Guanajuato',
    },
    {
      'value': 'Guerrero',
      'label': 'Guerrero',
    },
    {
      'value': 'Hidalgo',
      'label': 'Hidalgo',
    },
    {
      'value': 'Jalisco',
      'label': 'Jalisco',
    },
    {
      'value': 'Michoacán de Ocampo',
      'label': 'Michoacán de Ocampo',
    },
    {
      'value': 'Morelos',
      'label': 'Morelos',
    },
    {
      'value': 'Nayarit',
      'label': 'Nayarit',
    },
    {
      'value': 'Nuevo León',
      'label': 'Nuevo León',
    },
    {
      'value': 'Oaxaca',
      'label': 'Oaxaca',
    },
    {
      'value': 'Puebla',
      'label': 'Puebla',
    },
    {
      'value': 'Querétaro',
      'label': 'Querétaro',
    },
    {
      'value': 'Quintana Roo',
      'label': 'Quintana Roo',
    },
    {
      'value': 'San Luis Potosí',
      'label': 'San Luis Potosí',
    },
    {
      'value': 'Sinaloa',
      'label': 'Sinaloa',
    },
    {
      'value': 'Sonora',
      'label': 'Sonora',
    },
    {
      'value': 'Tabasco',
      'label': 'Tabasco',
    },
    {
      'value': 'Tamaulipas',
      'label': 'Tamaulipas',
    },
    {
      'value': 'Tlaxcala',
      'label': 'Tlaxcala',
    },
    {
      'value': 'Veracruz de Ignacio de la Llave',
      'label': 'Veracruz de Ignacio de la Llave',
    },
    {
      'value': 'Yucatán',
      'label': 'Yucatán',
    },
    {
      'value': 'Zacatecas',
      'label': 'Zacatecas',
    },
  ];

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    controller.setMapStyle(util.getMapStyle()); //cambiar el estilo del mapa
    if (state == "") {
      /*Fluttertoast.showToast(
          msg: "Debe seleccionar un estado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);*/
    }
  }

//-----------------------------------------------------
  String cat = "0";
  Future<void> loadMarkers(String option) async {
    //show your own loading or progressing code here

    progressD.show();
    //server servidor = new server();

    String uploadurl = server.getUrl() + "php/get_points.php";

    //String option = "map";

    /*
      0 - todo
      1 - centro de acopio
      2 - centro de reparación
      3 - sitio de disposición oficial
      4 - sitio de mantenimineto
    */

    /*if (checked_cat1) {
      cat = "1";
      selectedCategory = 'Centro de acopio';
    }
    if (checked_cat2) {
      cat = "2";
      selectedCategory = 'Centro de reparación';
    }
    if (checked_cat3) {
      cat = "3";
      selectedCategory = 'Sitio de disposición oficial';
    }
    if (checked_cat4) {
      cat = "4";
      selectedCategory = 'Sitio de mantenimineto';
    }
    if (checkedEventos) {
      cat = "event";
      selectedCategory = 'Eventos';
    }*/

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'option': option,
        'category': cat,
        'state': state.toUpperCase()
      });

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        setState(() {
          this.selectedState = state;

          _myMarkers.clear();
          for (var i = 0; i < jsondata.length; i++) {
            if (jsondata[i]['category'] == "1") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: acopio_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "2") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: reparacion_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "3") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: mantenimiento_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }
            if (jsondata[i]['category'] == "4") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: oficial_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "event") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: evento_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['name'],
                  ),
                  onTap: () {
                    show_event(jsondata[i]['name']);
                  }));
            }
          }
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
      progressD.hide();
      //there is error during converting file image to base64 encoding.
    } finally {
      progressD.hide();
    }
  }

  loadMarkers2(String option) async {
    //show your own loading or progressing code here

    //progressD.show();
    //server servidor = new server();

    String uploadurl = server.getUrl() + "php/get_points.php";

    try {
      response = await http.post(Uri.parse(uploadurl), body: {
        'option': option,
        'category': cat,
      });

      //print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("gps: " + jsondata[i]['category']);
        setState(() {
          _myMarkers.clear();
          for (var i = 0; i < jsondata.length; i++) {
            if (jsondata[i]['category'] == "1") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: acopio_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "2") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: reparacion_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "3") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: mantenimiento_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }
            if (jsondata[i]['category'] == "4") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: oficial_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['business_name'],
                  ),
                  onTap: () {
                    show_site(jsondata[i]['business_name']);
                  }));
            }

            if (jsondata[i]['category'] == "event") {
              _myMarkers.add(Marker(
                  markerId: MarkerId("marker_" + i.toString()),
                  position: LatLng(double.parse(jsondata[i]['lat']),
                      double.parse(jsondata[i]['lon'])),
                  icon: evento_icon,
                  infoWindow: InfoWindow(
                    title: jsondata[i]['name'],
                  ),
                  onTap: () {
                    show_event(jsondata[i]['name']);
                  }));
            }
          }
        });
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    } catch (e) {
      print("Error: " + e.toString());
      //progressD.hide();
    } finally {
      //progressD.hide();
    }
  }

//-----------------------------------------------------

  void show_site(valor) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Site(siteName: valor)));
  }

  void show_event(valor) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Event(siteName: valor)));
  }

  void getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    SetCustomMarker();
    getUserLocation();

    loadMarkers2("all");

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

  void SetCustomMarker() async {
    acopio_icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/acopio_icon.png');

    reparacion_icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/reparacion_icon.png');

    mantenimiento_icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/mantenimiento_icon.png');

    oficial_icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/oficial_icon.png');

    evento_icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/evento_icon.png');
  }

  void moveCameraPosition() async {
    if (state != '') {
      util u1 = new util();

      var cadena = u1.getGPSPoint(state);
      var separados = cadena.split(",");
      //print("location: " + separados[0] + "," + separados[1]);
      capitalLat = double.parse(separados[0]);
      capitalLon = double.parse(separados[1]);

      setState(() {
        _myMarkers.clear();

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    double.parse(separados[0]), double.parse(separados[1])),
                zoom: 9.0),
          ),
        );
      });
      loadMarkers("map");
    } else {
      Fluttertoast.showToast(
          msg: "Debe seleccionar el Estado primero",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
/*
  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Color(0xFF7EC649),
              title: Text("Seleccione un estado",
                  style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: Container(
                height: 200,
                color: Color(0xFF7EC649),
                child: Column(
                  children: <Widget>[
                    SelectFormField(
                      initialValue: '',
                      items: _states,
                      onChanged: (val) => state = val,
                      onSaved: (val) => state = val,
                      decoration: InputDecoration(
                          labelText: "Estados:",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF274E21), width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          )),
                    ),
                    Divider(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (state != "") {
                          Navigator.pop(context);
                          moveCameraPosition();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Debe seleccionar un estado",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.green,
                              fontSize: 16.0);
                        }
                      },
                      child: Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 16),
                        primary: Color(0xFF274E21),
                      ),
                    ),
                  ],
                ),
              ));
        },
        barrierDismissible: false);
  }
*/
  /*Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF7EC649),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      CheckboxListTile(
                          title: Text("Todo",
                              style: TextStyle(color: Colors.white)),
                          value: checkedTodo,
                          onChanged: (value) {
                            setState(() {
                              checkedTodo = value;
                              checked_cat1 = false;
                              checked_cat2 = false;
                              checked_cat3 = false;
                              checked_cat4 = false;
                              checkedEventos = false;
                            });
                          }),
                      CheckboxListTile(
                          title: Text("Centro de acopio",
                              style: TextStyle(color: Colors.white)),
                          value: checked_cat1,
                          onChanged: (value) {
                            setState(() {
                              checkedTodo = false;
                              checked_cat2 = false;
                              checked_cat3 = false;
                              checked_cat4 = false;
                              checkedEventos = false;

                              checked_cat1 = value;
                            });
                          }),
                      CheckboxListTile(
                          title: Text("Centro de reparación",
                              style: TextStyle(color: Colors.white)),
                          value: checked_cat2,
                          onChanged: (value) {
                            setState(() {
                              checked_cat2 = value;

                              checkedTodo = false;
                              checked_cat1 = false;
                              checked_cat3 = false;
                              checked_cat4 = false;
                              checkedEventos = false;
                            });
                          }),
                      CheckboxListTile(
                          title: Text("Sitio de disposición oficial",
                              style: TextStyle(color: Colors.white)),
                          value: checked_cat3,
                          onChanged: (value) {
                            setState(() {
                              checked_cat3 = value;

                              checkedTodo = false;
                              checked_cat1 = false;
                              checked_cat2 = false;
                              checked_cat4 = false;
                              checkedEventos = false;
                            });
                          }),
                      CheckboxListTile(
                          title: Text("Sitio de mantenimiento",
                              style: TextStyle(color: Colors.white)),
                          value: checked_cat4,
                          onChanged: (value) {
                            setState(() {
                              checked_cat4 = value;

                              checkedTodo = false;
                              checked_cat1 = false;
                              checked_cat2 = false;
                              checked_cat3 = false;
                              checkedEventos = false;
                            });
                          }),
                      CheckboxListTile(
                          title: Text("Eventos",
                              style: TextStyle(color: Colors.white)),
                          value: checkedEventos,
                          onChanged: (value) {
                            setState(() {
                              checkedEventos = value;

                              checkedTodo = false;
                              checked_cat1 = false;
                              checked_cat2 = false;
                              checked_cat3 = false;
                              checked_cat4 = false;
                            });
                          }),
                      ElevatedButton(
                        onPressed: () {
                          if (state != "") {
                            Navigator.pop(context);
                            moveCameraPosition();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Debe seleccionar un estado primero",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          textStyle: TextStyle(fontSize: 16),
                          primary: Color(0xFF274E21),
                        ),
                      )
                    ],
                  )
                ],
              ),
              title: Text('Categorias', style: TextStyle(color: Colors.white)),
            );
          });
        },
        barrierDismissible: false);
  }*/

  @override
  Widget build(BuildContext context) {
    progressD = new ProgressDialog(context);
    progressD.style(message: 'Espere un momento...');

    return Scaffold(
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
        body: _returnBody()
        /*
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
            : Stack(
                //Se anexó el widget stack para poder manejar las diferentes ventanas (menu principal, ventanda de estados y ventada de categorías.)
                //se dejó de utilizar el floatingActionButton para una mejor manipulación del menú
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    markers: _myMarkers,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: _showMenu(),
                  ),
                  //Se llama la ventanda de estados pero con height 0 por default.
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: _selectState(context),
                  ),
                  //Se llama la ventanda de categorias pero con height 0 por default.
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: _selectCategories(context),
                  ),
                ],
              )

              */
        /*    : GoogleMap(
                onMapCreated: _onMapCreated,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                markers: _myMarkers,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14,
                ),
              ),
        
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 30),
            child: Container(
                height: 50,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                    Container(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDialog();
                          },
                          child: Text('Estados'),
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            textStyle: TextStyle(fontSize: 16),
                            primary: Color(0xFF274E21),
                          ),
                        )),
                    Spacer(
                      flex: 1,
                    ),
                    Container(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () async {
                          await showInformationDialog(context);
                        },
                        child: Text('Categorías'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          textStyle: TextStyle(fontSize: 16),
                          primary: Color(0xFF274E21),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(20)))))
                    
                    */

        );
  }

//Método para visualizar el menú principal (estados, categorías)
  Widget _showMenu() {
    return Container(
      height: 60,

      //margin: EdgeInsets.only(left: 15),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 30.0,
            ),
          ),
          Container(
              width: 130,
              child: ElevatedButton(
                onPressed: () {
                  // _showDialog();
                  setState(() {
                    //Para desplegar la ventana donde se seleccionan los estados.
                    //Por default tiene valor 0 y oculto
                    heightContainerState = 430.0;
                  });
                },
                child: Text(
                  state == '' ? 'Estados' : state,
                  overflow: TextOverflow.ellipsis,
                ), // Si la variable de estado tiene algún valor, se le anexa al texto del botón
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  textStyle: TextStyle(fontSize: 16),
                  primary: Color(0xFF274E21),
                ),
              )),
          Spacer(
            flex: 1,
          ),
          Container(
            width: 130,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  //Para desplegar la ventana donde se seleccionan las categorías.
                  //Por default tiene valor 0 y oculto
                  heightContainerCat = 430.0;
                });
              },
              child: Text(
                lsCategoriesSelect != null && lsCategoriesSelect.length > 0
                    ? lsCategoriesSelect[0].nbCategorie
                    : "Categorias", //Si hay alguna categoría en la lista, se le presenta el nombre en el texto del botón
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                textStyle: TextStyle(fontSize: 16),
                primary: Color(0xFF274E21),
              ),
            ),
          ),
          Expanded(
            child: Icon(
              Icons.menu,
              color: Colors.white,
              size: 30.0,
            ),
          ),
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

  //**********************Sección de Estados**********************
  double heightContainerState = 0.0;

  //Lista final de estados
  final List<StatesModel> _itemsState = [
    StatesModel('Aguascalientes', false),
    StatesModel('Baja California', false),
    StatesModel('Baja California Sur', false),
    StatesModel('Campeche', false),
    StatesModel('Chiapas', false),
    StatesModel('Chihuahua', false),
    StatesModel('Ciudad de México', false),
    StatesModel('Coahuila de Zaragoza', false),
    StatesModel('Colima', false),
    StatesModel('Durango', false),
    StatesModel('Estado de México', false),
    StatesModel('Guanajuato', false),
    StatesModel('Guerrero', false),
    StatesModel('Hidalgo', false),
    StatesModel('Jalisco', false),
    StatesModel('Michoacán de Ocampo', false),
    StatesModel('Morelos', false),
    StatesModel('Nayarit', false),
    StatesModel('Nuevo León', false),
    StatesModel('Oaxaca', false),
    StatesModel('Puebla', false),
    StatesModel('Querétaro', false),
    StatesModel('Quintana Roo', false),
    StatesModel('San Luis Potosí', false),
    StatesModel('Sinaloa', false),
    StatesModel('Sonora', false),
    StatesModel('Tabasco', false),
    StatesModel('Tamaulipas', false),
    StatesModel('Tlaxcala', false),
    StatesModel('Veracruz de Ignacio de la Llave', false),
    StatesModel('Yucatán', false),
    StatesModel('Zacatecas', false)
  ];

//Método que crea la ventana para seleccionar los estados.
  Widget _selectState(BuildContext context) {
    return Container(
      height: heightContainerState,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
            ),
            child: Text(
              'Selecciona la ubicación',
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
              child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 30.0),
            padding: EdgeInsets.only(left: 20.0, right: 60.0),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.white,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _itemsState.length,
                      itemBuilder: (BuildContext context, int index) {
                        return stateItem(_itemsState[index].nbState,
                            _itemsState[index].isSelected, index);
                      }),
                ),
              ],
            ),
          )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (state != '') {
                // Navigator.pop(context);
                moveCameraPosition();
                setState(() {
                  heightContainerState = 0.0;
                });
              } else {
                Fluttertoast.showToast(
                    msg: "Debe seleccionar un estado",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.green,
                    fontSize: 16.0);
              }
            },
            child: Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
              shape: StadiumBorder(),
              textStyle: TextStyle(fontSize: 16),
              primary: Color(0xFF274E21),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  //**********************Sección de Categorias**************************
  static const String todo = "Todo",
      centroAcopio = "Centro de acopio",
      centroReparacion = "Centro de reparación",
      sitioMantenimiento = "Sitio de mantenimiento",
      sitioDispocisionOficial = "Sitio de disposición oficial",
      eventos = "Eventos";

  double heightContainerCat = 0.0;

  //Lista de categorias, se utilizaron objetos de la clase CategoriesModel, por default en isSelected tiene valor false
  List<CategoriesModel> lsCategories = [
    CategoriesModel(todo, false),
    CategoriesModel(centroAcopio, false),
    CategoriesModel(centroReparacion, false),
    CategoriesModel(sitioMantenimiento, false),
    CategoriesModel(sitioDispocisionOficial, false),
    CategoriesModel(eventos, false)
  ];
  List<CategoriesModel> lsCategoriesSelect = [];

  Widget stateItem(String nbState, bool isSelected, int index) {
    return Container(
      decoration: BoxDecoration(
          color: isSelected ? Color(0xFF274E21) : Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(50.0))),
      child: ListTile(
        dense: true,
        // contentPadding: EdgeInsets.symmetric(vertical: 0),
        title: Row(
          children: [
            Expanded(
              child: Text(
                nbState,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            if (state != '') {
              if (state == _itemsState[index].nbState) {
                state = '';
                _itemsState[index].isSelected = !_itemsState[index].isSelected;
              } else {
                _itemsState
                    .where((element) => element.nbState == state)
                    .first
                    .isSelected = false;
                state = '';
                _itemsState[index].isSelected = !_itemsState[index].isSelected;
                if (_itemsState[index].isSelected) {
                  state = _itemsState[index].nbState;
                }
              }
            } else {
              _itemsState[index].isSelected = !_itemsState[index].isSelected;
              if (_itemsState[index].isSelected) {
                state = _itemsState[index].nbState;
              }
            }
            // lsCategories[index].isSelected = !lsCategories[index].isSelected;
          });
        },
      ),
    );
  }

  //Ventana principal de categorías
  Widget _selectCategories(BuildContext context) {
    return Container(
      height: heightContainerCat,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text('Selecciona la categoría de búsqueda',
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w800)),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: lsCategories.length,
                itemBuilder: (BuildContext context, int index) {
                  return categorieItem(lsCategories[index].nbCategorie,
                      lsCategories[index].isSelected, index);
                }),
          )),
          ElevatedButton(
            onPressed: () {
              if (lsCategoriesSelect != null && lsCategoriesSelect.length > 0) {
                //Navigator.pop(context);

                moveCameraPosition();
                setState(() {
                  heightContainerCat = 0.0;
                });
              } else {
                Fluttertoast.showToast(
                    msg: "Debe seleccionar una categoría",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            child: Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
              shape: StadiumBorder(),
              textStyle: TextStyle(fontSize: 16),
              primary: Color(0xFF274E21),
            ),
          )
        ],
      ),
    );
  }

  //Items de categorias
  Widget categorieItem(String nbCategorie, bool isSelected, int index) {
    return Container(
      decoration: BoxDecoration(
          color: isSelected ? Color(0xFF274E21) : Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(50.0))),
      child: ListTile(
        // leading: iconCategorieItem(index),
        title: Row(
          children: [
            iconCategorieItem(index),
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Text(
                nbCategorie,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            if (lsCategoriesSelect.length > 0) {
              if (lsCategoriesSelect[0].nbCategorie ==
                  lsCategories[index].nbCategorie) {
                lsCategoriesSelect.clear();
                lsCategories[index].isSelected =
                    !lsCategories[index].isSelected;
              } else {
                lsCategories
                    .where((element) =>
                        element.nbCategorie ==
                        lsCategoriesSelect[0].nbCategorie)
                    .first
                    .isSelected = false;
                lsCategoriesSelect.clear();
                lsCategories[index].isSelected =
                    !lsCategories[index].isSelected;
                if (lsCategories[index].isSelected) {
                  lsCategoriesSelect.add(lsCategories[index]);
                }
              }
            } else {
              lsCategories[index].isSelected = !lsCategories[index].isSelected;
              if (lsCategories[index].isSelected) {
                lsCategoriesSelect.add(lsCategories[index]);
              }
            }
            // lsCategories[index].isSelected = !lsCategories[index].isSelected;
            print('index: ' + index.toString());
            cat = index.toString();
          });
        },
      ),
    );
  }

  //Iconos de categorias
  Widget iconCategorieItem(int index) {
    String asset;
    switch (lsCategories[index].nbCategorie) {
      case todo:
        asset = "assets/images/icon_todo.png";
        break;
      case centroAcopio:
        asset = "assets/images/icon_acopio.png";
        break;
      case centroReparacion:
        asset = "assets/images/icon_reparacion.png";
        break;
      case sitioMantenimiento:
        asset = "assets/images/icon_mantenimiento.png";
        break;
      case sitioDispocisionOficial:
        asset = "assets/images/icon_oficial.png";
        break;
      case eventos:
        asset = "assets/images/icon_eventos.png";
        break;
    }

    return Image.asset(
      asset,
      width: 30.0,
      height: 30.0,
    );
  }

  Widget _returnBody() {
    setState(() {
      HeightContainer().height = _initialPosition == null ? 0 : 30.0;
    });
    return (_initialPosition == null
        ? Container(
            child: Center(
              child: Text(
                'Cargando mapa..',
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
              GoogleMap(
                onMapCreated: _onMapCreated,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                markers: _myMarkers,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 5,
                ),
              ),
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
                bottom: 120,
                child: _selectState(context),
              ),
              Positioned(
                left: 0,
                bottom: 80, //80
                child: _showMenu(),
              ),
              Positioned(
                left: 0,
                bottom: 80,
                child: _selectCategories(context),
              ),
            ],
          ));
  }

//----------------------
  int index = 0;
  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      defaultSelectedItem: 0,
      shadowColor: Colors.green,
      sheetRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      onItemPressed: (value) {
        // setState(() {
        this.index = value;
        print('Selected item is - $index');
        switch (value) {
          case 0:
            /*setState(() {
              //heightContainer = 30.0;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GoogleMapScreen()));
            });*/
            break;
          case 1:
            setState(() {
              // heightContainer = 0.0;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Educacion()));

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
            selectedItemColor: Color(0xFF23D5D1),
            title: 'Settings'),
      ],
    );
  }
}

class CategoriesModel {
  String nbCategorie;
  bool isSelected;

  CategoriesModel(this.nbCategorie, this.isSelected);
}

class StatesModel {
  String nbState;
  bool isSelected;

  StatesModel(this.nbState, this.isSelected);
}

class HeightContainer {
  double height = 30;

  // HeightContainer(this.height);
}
