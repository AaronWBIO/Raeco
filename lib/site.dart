import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_tabs/site_model.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';

import 'package:flutter_tabs/src/server.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'myDrawer.dart';

class Site extends StatefulWidget {
  final String siteName;
  Site({Key key, @required this.siteName}) : super(key: key);

  @override
  _SiteState createState() => _SiteState(siteName);
}

class _SiteState extends State<Site> {
  Future<String> loaded_data = null;
  //ProgressDialog progressD;
  var response;

  String site_name = "";
  String description = "";
  String tag_image = "assets/images/tag_acopio.png";
  String image_profile = "assets/images/perfil_no_verificado.png";
  String image_network = server.getUrl() + "php/uploads/image1.png";
  String image_network2 = server.getUrl() + "php/uploads/image1.png";
  String image_network3 = server.getUrl() + "php/uploads/image1.png";
  String image_network4 = server.getUrl() + "php/uploads/image1.png";
  String facebook = '';
  String horario = '';
  String insta = '';
  bool fgFirstAccess = true;

  String phone = '';
  _SiteState(siteName) {
    this.site_name = siteName;
  }
  @override
  void initState() {
    super.initState();
    loaded_data = loadInfo();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final siteModel = Provider.of<SiteModel>(context, listen: false);
      siteModel.urlImage = '';
    });
  }

  //------load info
  Future<String> loadInfo() async {
    //show your own loading or progressing code here
    String uploadurl = server.getUrl() + "php/get_points.php";

    try {
      response = await http.post(Uri.parse(uploadurl),
          body: {'option': 'get_info', 'name': site_name});

      print("RESPUESTA: " + response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        //print("DATOS: " + jsondata[0]['description']);
        setState(() {
          description = jsondata[0]['description'];

          image_profile = "assets/images/perfil_no_verificado.png";
          if (jsondata[0]['activation'] != '') {
            image_profile = "assets/images/perfil_verificado.png";
          }

          if (jsondata[0]['horario'] != '') {
            horario = jsondata[0]['horario'];
          }

          if (jsondata[0]['image_url'] != "") {
            image_network = server.getUrl() + jsondata[0]['image_url'];
          }

          if (jsondata[0]['image_url2'] != "") {
            image_network2 = server.getUrl() + jsondata[0]['image_url2'];
          }

          if (jsondata[0]['image_url3'] != "") {
            image_network3 = server.getUrl() + jsondata[0]['image_url3'];
          }

          if (jsondata[0]['image_url4'] != "") {
            image_network4 = server.getUrl() + jsondata[0]['image_url4'];
          }

          //print("CATEGORIA: " + jsondata[0]['category']);

          if (jsondata[0]['category'] == "1") {
            tag_image = "assets/images/tag_acopio.png";
          }
          if (jsondata[0]['category'] == "2") {
            tag_image = "assets/images/tag_reparacion.png";
            // image_profile = "assets/images/perfil_verificado.png";
          }
          if (jsondata[0]['category'] == "3") {
            tag_image = "assets/images/tag_mantenimiento.png";
          }
          if (jsondata[0]['category'] == "4") {
            tag_image = "assets/images/tag_oficial.png";
            //image_profile = "assets/images/perfil_no_verificado.png";
          }

          facebook = jsondata[0]['facebook'];
          insta = jsondata[0]['instagram'];

          phone = jsondata[0]['cel'];
        });
      } else {
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
        /*Fluttertoast.showToast(
            msg: "Ocurrio un error, inténtelo más tarde",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);*/
      }
    } catch (e) {
      /*Fluttertoast.showToast(
          msg: "Ocurrio un error, inténtelo más tarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);*/
      print("Error: " + e.toString());
    } finally {}
    return "Done";
  }

  _launchURL(String _url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  //--------------

  @override
  Widget build(BuildContext context) {
    //progressD = new ProgressDialog(context);
    //progressD.style(message: 'Espere un momento...');
    //loadInfo();
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
      drawer: myDrawer(),
      body: _returnBody(),
      //bottomNavigationBar:,
    );
  }

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
              getBody(context),
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
              /*Positioned(
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
              ),*/
            ],
          ));
  }

//***************************************************
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
            mainAxisAlignment: selectedIcon != 'assets/images/icon_watts.png'
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
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
                width: selectedIcon != 'assets/images/icon_watts.png' ? 30 : 5,
              ),
              selectedIcon != 'assets/images/icon_watts.png'
                  ? Text(menuValue,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      textAlign: TextAlign.center)
                  : GestureDetector(
                      onTap: () {
                        print('hola');
                        if (menuValue.length < 10) {
                          Fluttertoast.showToast(
                            msg: "Número de teléfono no válido.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.green,
                            fontSize: 16.0,
                          );
                        } else {
                          String phone = menuValue.contains('+52')
                              ? menuValue
                              : "+52" + menuValue;
                          print(phone);
                          var whatsappUrl = "whatsapp://send?phone=$phone";
                          try {
                            launch(whatsappUrl);
                          } catch (ex) {}
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25)),
                        // width: 100.0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 100.0, vertical: 15.0),
                        child: Text(menuValue,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                            textAlign: TextAlign.center),
                      ),
                    ),
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

  Widget getBody(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    // if (fgFirstAccess) {
    //   setState(() {
    //     fgFirstAccess = false;
    //   });
    // }
    return Container(
      width: screen.width,
      height: screen.height,
      // color: Colors.black,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: _returnImageHeader(screen.width, 200.0),
          ),
          Positioned(
            // bottom: 0,
            top: 180,
            left: 0,
            child: Container(
              width: screen.width,
              height: screen.height - 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    returnImagesCarousel(context),
                    // _ImageCarousel(),
                    _returnNameSate(),
                    _returnTags(),
                    _returnDescription(),
                    // _returnDescription(),
                    // _returnDescription(),
                    // _returnDescription(),
                    // _returnDate(),
                    _returnTime(),
                    SizedBox(
                      height: 50.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnImageHeader(double width, double height) {
    final siteModel = Provider.of<SiteModel>(context);
    return Container(
      // color: Colors.deepOrange,
      child: ClipRRect(
        // borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Image.network(
          siteModel.urlImage != '' ? siteModel.urlImage : image_network,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget returnImagesCarousel(BuildContext context) {
    double sizeImage = (MediaQuery.of(context).size.width / 4) - 15;
    double borderRadius = 12.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network: image_network,
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network: image_network2,
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network: image_network3,
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network: image_network4,
          ),
        ],
      ),
    );
  }

  Widget _returnNameSate() {
    return Container(
        margin: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
        child: Row(
          children: <Widget>[
            Image.asset(
              'assets/images/gold_icon.png',
              height: 40,
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                this.site_name,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                // maxLines: 1,
                // overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ));
  }

  Widget _returnTags() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset(
              tag_image,
              height: 35.0,
            ),
            Image.asset(image_profile, height: 35.0)
          ]),
    );
  }

  Widget _returnDescription() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(description),
        // child: Text(
        //     'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.'),
      ),
    );
  }

  Widget _returnDate() {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fecha',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Text('12/07/2021'),
        ],
      ),
    );
  }

  Widget _returnTime() {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Horario',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Text(horario),
        ],
      ),
    );
  }

//----------------------
  int index = 0;
  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
      shadowColor: Colors.green,
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
            selectedItemColor: Color(0xFFFFFF),
            title: 'Chat'),
        BuildNavigationItem(
            tooltip: 'Peoples',
            itemColor: Color(0xFFFFFF),
            icon: new Image.asset(
              'assets/images/icon_bar3.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Peoples'),
        BuildNavigationItem(
            tooltip: 'Settings',
            itemColor: Color(0xFFFFFF),
            icon: Image.asset(
              'assets/images/icon_bar4.png',
              height: 50,
            ),
            selectedItemColor: Color(0xFFFFFF),
            title: 'Settings'),
      ],
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({Key key, this.image_network}) : super(key: key);
  final String image_network;

  @override
  Widget build(BuildContext context) {
    double sizeImage = (MediaQuery.of(context).size.width / 4) - 15;
    double borderRadius = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network: image_network,
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network:
                'https://images-eu.ssl-images-amazon.com/images/I/51VpVuFELXL.jpg',
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network:
                'https://dbdzm869oupei.cloudfront.net/img/photomural/medium/20480.jpg',
          ),
          _ImageCarouselBox(
            sizeImage: sizeImage,
            borderRadius: borderRadius,
            image_network:
                'https://vinilos.info/wp-content/uploads/100403-182-0.jpg',
          ),
        ],
      ),
    );
  }
}

class _ImageCarouselBox extends StatelessWidget {
  const _ImageCarouselBox({
    Key key,
    @required this.borderRadius,
    @required this.sizeImage,
    @required this.image_network,
  }) : super(key: key);

  final double borderRadius;
  final double sizeImage;
  final String image_network;
  @override
  Widget build(BuildContext context) {
    final siteModel = Provider.of<SiteModel>(context);
    return GestureDetector(
      onTap: () {
        final siteModel = Provider.of<SiteModel>(context, listen: false);
        siteModel.urlImage = this.image_network;
      },
      child: Container(
        // color: Colors.deepOrange,
        width: sizeImage,
        height: sizeImage,
        child: Stack(
          children: [
            Positioned(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Image.network(
                  image_network,
                  width: sizeImage,
                  height: sizeImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              child: image_network == siteModel.urlImage
                  ? Container(
                      width: sizeImage,
                      height: sizeImage,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.4),
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(width: 1.5, color: Colors.green),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
        // child: ClipRRect(
        //   borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        //   child: Image.network(
        //     'image_network',
        //     width: sizeImage,
        //     height: sizeImage,
        //     fit: BoxFit.cover,
        //   ),
        // ),
      ),
    );
  }
}
