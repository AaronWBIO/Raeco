import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_tabs/src/localStorage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
//import 'package:path_provider/path_provider.dart';

import 'package:async/async.dart';
import 'package:path/path.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:select_form_field/select_form_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tabs/src/server.dart';

import 'package:flutter_tabs/src/util.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'myDrawer.dart';

class EventForm extends StatefulWidget {
  final String last_location;
  EventForm({Key key, @required this.last_location}) : super(key: key);

  @override
  _EventFormState createState() => _EventFormState(last_location);
}

class _EventFormState extends State<EventForm> {
  BuildContext mycontext;
  localStorage storage = new localStorage();

  final format = DateFormat("yyyy-MM-dd");
  final formatTime = DateFormat("HH:mm");

  File _image;
  File _image2;
  File _image3;
  File _image4;
  final imagePicker = ImagePicker();

  ProgressDialog pr;

  final formKey = GlobalKey<FormState>();

  GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(45.521563, -122.677433);

  DateTime _date;
  DateTime _time1;
  DateTime _time2;

  String last_location;

  String eventName = "";
  String ownerName = "";
  String address = "";
  String country = "";
  String state = "";
  String description = "";

  String website = "";
  String cel = "";
  String email = "";
  String facebook = "";
  String instagram = "";
  var response;

  _EventFormState(location) {
    this.last_location = location;
  }

  final List<Map<String, dynamic>> _country = [
    {
      'value': 'M??xico',
      'label': 'M??xico',
    },
  ];

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
      'value': 'Ciudad de M??xico',
      'label': 'Ciudad de M??xico',
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
      'value': 'Estado de M??xico',
      'label': 'Estado de M??xico',
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
      'value': 'Michoac??n de Ocampo',
      'label': 'Michoac??n de Ocampo',
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
      'value': 'Nuevo Le??n',
      'label': 'Nuevo Le??n',
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
      'value': 'Quer??taro',
      'label': 'Quer??taro',
    },
    {
      'value': 'Quintana Roo',
      'label': 'Quintana Roo',
    },
    {
      'value': 'San Luis Potos??',
      'label': 'San Luis Potos??',
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
      'value': 'Yucat??n',
      'label': 'Yucat??n',
    },
    {
      'value': 'Zacatecas',
      'label': 'Zacatecas',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'value': '1',
      'label': 'Centro de acopio',
    },
    {
      'value': '2',
      'label': 'Centro de reparaci??n',
    },
    {
      'value': '3',
      'label': 'Sitio de disposici??n oficial',
    },
    {
      'value': '4',
      'label': 'Sitio de mantenimineto',
    }
  ];

  Future getImage(int posImage) async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      switch (posImage) {
        case 1:
          _image = File(image.path);
          break;
        case 2:
          _image2 = File(image.path);
          break;
        case 3:
          _image3 = File(image.path);
          break;
        case 4:
          _image4 = File(image.path);
          break;
      }
    });
  }

  Future getImageCamera(int posImage) async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      switch (posImage) {
        case 1:
          _image = File(image.path);
          break;
        case 2:
          _image2 = File(image.path);
          break;
        case 3:
          _image3 = File(image.path);
          break;
        case 4:
          _image4 = File(image.path);
          break;
      }
    });
  }

  Future<void> save2(action, cabeceras, valores, img_status) async {
    //show your own loading or progressing code here
    print("save2");
    pr.show();
    //server servidor = new server();
    String uploadurl = server.getUrl() + "php/events.php";

    response = await http.post(Uri.parse(uploadurl), body: {
      'action': action,
      'cabeceras': cabeceras,
      'valores': valores,
      'img_status': img_status
    });

    if (response.statusCode == 200) {
      print(response.body);
      //if (response.body.contains('ok')) {
      pr.hide();

      Fluttertoast.showToast(
          msg: "Informaci??n guardada exitosamente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.push(mycontext,
          MaterialPageRoute(builder: (context) => GoogleMapScreen()));
      //}
    } else {
      print("Error during connection to server");
      //there is error during connecting to server,
      //status code might be 404 = url not found
    }
    pr.hide();
  }

//---------------------------------------------------------------
  Upload() async {
    //--------------
    var parts = last_location.split(',');
    var lat = parts[0].trim();
    var lon = parts[1].trim();

    parts = _date.toString().split(" ");
    String only_date = parts[0];

    parts = _time1.toString().split(" ");
    String time1 = parts[1];

    parts = _time2.toString().split(" ");
    String time2 = parts[1];

    String cabeceras =
        "name, owner_name, date, time_begin, time_end, country, state, description, address, lat, lon, url, facebook, instagram, cel, email, activation,setup_by, category";
    String valores = "'" +
        eventName.toUpperCase() +
        "' , '" +
        ownerName.toUpperCase() +
        "' , '" +
        only_date +
        "' , '" +
        time1 +
        "' , '" +
        time2 +
        "' , '" +
        country.toUpperCase() +
        "' , '" +
        state.toUpperCase() +
        "' , '" +
        description +
        "' , '" +
        address +
        "', '" +
        lat +
        "' , '" +
        lon +
        "' , '" +
        website +
        "' , '" +
        facebook +
        "' , '" +
        instagram +
        "' , '" +
        cel +
        "' , '" +
        email +
        "' , '' ,'" +
        storage.getUser() +
        "' , 'event'";

    String action = 'save';
    String img_status = "";

    //--------------

    if (_image != null) {
      String img_status = "yes";
      pr.show();

      String uploadURL = server.getUrl() + "php/events.php";

      var uri = Uri.parse(uploadURL);

      var request = new http.MultipartRequest("POST", uri);

      //contentType: new MediaType('image', 'png'));

      if (_image != null) {
        File imageFile = _image;
        var stream =
            new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        var multipartFile = new http.MultipartFile(
            'uploaded_file', stream, length,
            filename: basename(imageFile.path));
        request.files.add(multipartFile);
      }

      if (_image2 != null) {
        File imageFile2 = _image2;
        var stream2 =
            new http.ByteStream(DelegatingStream.typed(imageFile2.openRead()));
        var length2 = await imageFile2.length();
        var multipartFile2 = new http.MultipartFile(
            'uploaded_file2', stream2, length2,
            filename: basename(imageFile2.path));
        request.files.add(multipartFile2);
      }

      if (_image3 != null) {
        File imageFile3 = _image3;
        var stream3 =
            new http.ByteStream(DelegatingStream.typed(imageFile3.openRead()));
        var length3 = await imageFile3.length();
        var multipartFile3 = new http.MultipartFile(
            'uploaded_file3', stream3, length3,
            filename: basename(imageFile3.path));
        request.files.add(multipartFile3);
      }

      if (_image4 != null) {
        File imageFile4 = _image4;
        var stream4 =
            new http.ByteStream(DelegatingStream.typed(imageFile4.openRead()));
        var length4 = await imageFile4.length();
        var multipartFile4 = new http.MultipartFile(
            'uploaded_file4', stream4, length4,
            filename: basename(imageFile4.path));
        request.files.add(multipartFile4);
      }

      request.fields['action'] = 'save';
      request.fields['cabeceras'] = cabeceras;
      request.fields['valores'] = valores;
      request.fields['img_status'] = img_status;

      var response = await request.send();
      print(response.statusCode);
      response.stream.transform(utf8.decoder).listen((value) {
        print("valor:" + value);
        if (value.contains('ok')) {
          pr.hide();
          Fluttertoast.showToast(
              msg:
                  "Informaci??n guardada exitosamente, se validar?? su informaci??n antes de publicarla",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);

          Navigator.push(mycontext,
              MaterialPageRoute(builder: (context) => GoogleMapScreen()));
        }
      });

      pr.hide();
    } else {
      img_status = 'no';
      save2(action, cabeceras, valores, img_status);
    }
  }
//----------------------------------------

//----------------------------------------

  void _selectImageSource(int posImage) async {
    await showDialog(
        context: mycontext,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Cargar Imagen'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  getImageCamera(posImage);

                  Navigator.pop(context);
                  print("camara");
                },
                child: const Text('Tomar foto'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  print("biblioteca");
                  getImage(posImage);
                },
                child: const Text('Seleccionar de biblioteca'),
              ),
            ],
          );
        });
  }

  void validar() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      Upload();
    } else {
      Fluttertoast.showToast(
          msg: "llene los campos obligatorios",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
                Navigator.push(mycontext,
                    MaterialPageRoute(builder: (context) => GoogleMapScreen()));
              });
              break;
            case 1:
              setState(() {
                // heightContainer = 0.0;
                Navigator.push(
                    mycontext,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen()));
              });
              break;
            case 2:
              setState(() {
                // heightContainer = 0.0;
                Navigator.push(
                    mycontext,
                    MaterialPageRoute(
                        builder: (context) => Consumo_Responsable()));
              });
              break;
            case 3:
              Navigator.push(mycontext,
                  MaterialPageRoute(builder: (context) => Educacion()));
              /*
              setState(() {
                // heightContainer = 0.0;
                Navigator.push(mycontext,
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

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    pr = new ProgressDialog(context);
    pr.style(message: 'Espere un momento...');

    double sizeImage = (MediaQuery.of(context).size.width / 4) - 15;
    double borderRadius = 12.0;
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
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Text(
                  'Registrar Evento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                Divider(
                  height: 25,
                ),
                _returnCarouselImage(sizeImage, borderRadius),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Nombre del Evento:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    eventName = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Nombre del organizador:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    ownerName = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                ),
                Divider(
                  height: 25,
                ),
                DateTimeField(
                    decoration: InputDecoration(
                        labelText: "Fecha:",
                        labelStyle: TextStyle(color: Colors.green),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        )),
                    format: format,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    onChanged: (value) {
                      _date = value;
                    },
                    onSaved: (value) {
                      _date = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Debe llenar este campo";
                      }
                    }),
                Divider(
                  height: 25,
                ),
                DateTimeField(
                    decoration: InputDecoration(
                        labelText: "Hora de inicio:",
                        labelStyle: TextStyle(color: Colors.green),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        )),
                    format: formatTime,
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.convert(time);
                    },
                    onChanged: (value) {
                      _time1 = value;
                    },
                    onSaved: (value) {
                      _time1 = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Debe llenar este campo";
                      }
                    }),
                Divider(
                  height: 25,
                ),
                DateTimeField(
                    decoration: InputDecoration(
                        labelText: "Hora de fin:",
                        labelStyle: TextStyle(color: Colors.green),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        )),
                    format: formatTime,
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.convert(time);
                    },
                    onChanged: (value) {
                      _time2 = value;
                    },
                    onSaved: (value) {
                      _time2 = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Debe llenar este campo";
                      }
                    }),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Direcci??n:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    address = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                  maxLines: 5,
                ),
                Divider(
                  height: 25,
                ),
                SelectFormField(
                  initialValue: '',
                  items: _country,
                  onChanged: (val) => country = val,
                  onSaved: (val) => country = val,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Pa??s:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                ),
                Divider(
                  height: 25,
                ),
                SelectFormField(
                  initialValue: '',
                  items: _states,
                  onChanged: (val) => state = val,
                  onSaved: (val) => state = val,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: "Estados:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Breve rese??a o descripci??n:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    description = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                  maxLines: 5,
                ),
                Divider(
                  height: 25,
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Sitio web:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    website = value;
                  },
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Facebook:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    facebook = value;
                  },
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Instagram:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    instagram = value;
                  },
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Email:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (!util.isValidEmail(value)) {
                      return "email no valido";
                    }
                    return null;
                  },
                ),
                Divider(
                  height: 25,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "T??lefono de contacto:",
                      labelStyle: TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  onSaved: (value) {
                    cel = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Debe llenar este campo";
                    }
                  },
                ),
                Divider(
                  height: 25,
                ),
                // Container(
                //   //show image here after choosing image
                //   child: _image == null
                //       ? Container()
                //       : //if uploadimage is null then show empty container
                //       Container(
                //           //elese show image here
                //           child: SizedBox(
                //               height: 150,
                //               child: Image.file(_image) //load image from file
                //               ),
                //         ),
                // ),
                // _returnCarouselImage(sizeImage, borderRadius),
                // ElevatedButton.icon(
                //     icon: Icon(
                //       Icons.folder_open,
                //       color: Colors.white,
                //       size: 24.0,
                //     ),
                //     label: Text('Seleccione una imagen'),
                //     // onPressed: _selectImageSource,
                //     onPressed: null,
                //     style: ElevatedButton.styleFrom(
                //       shape: StadiumBorder(),
                //       textStyle: TextStyle(fontSize: 15),
                //       primary: Color(0xFF8BC540),
                //     )),
                // Divider(
                //   height: 25,
                // ),
                ElevatedButton(
                  onPressed: validar,
                  child: Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    textStyle: TextStyle(fontSize: 15),
                    primary: Color(0xFF8BC540),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _returnCarouselImage(double sizeImage, double borderRadius) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _selectImageSource(1);
            },
            child: _returnCarouselImageItem(sizeImage, borderRadius, _image),
          ),
          GestureDetector(
            onTap: () {
              _selectImageSource(2);
            },
            child: _returnCarouselImageItem(sizeImage, borderRadius, _image2),
          ),
          GestureDetector(
            onTap: () {
              _selectImageSource(3);
            },
            child: _returnCarouselImageItem(sizeImage, borderRadius, _image3),
          ),
          GestureDetector(
            onTap: () {
              _selectImageSource(4);
            },
            child: _returnCarouselImageItem(sizeImage, borderRadius, _image4),
          ),
        ],
      ),
    );
  }

  Widget _returnCarouselImageItem(
      double sizeImage, double borderRadius, File _image) {
    return Container(
      width: sizeImage,
      height: sizeImage,
      // color: Colors.red,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.green),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius - 2)),
              child: _image == null
                  ? Container()
                  : Image.file(
                      _image,
                      fit: BoxFit.cover,
                      width: sizeImage - 4,
                      height: sizeImage - 4,
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _image == null
                ? Container(
                    width: sizeImage - 4,
                    height: sizeImage - 4,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius - 2),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
