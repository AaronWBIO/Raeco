import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabs/VideoPlayerScreen.dart';
import 'package:flutter_tabs/cuestionario.dart';
import 'package:flutter_tabs/educacion.dart';

import 'package:flutter_tabs/GoogleMapScreen.dart';
import 'package:flutter_tabs/home.dart';

import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';

import 'package:flutter_tabs/myDrawer.dart';

import 'consumo_responsable.dart';

class Menu extends StatefulWidget {
  final int index;
  //final String data;
  Menu({Key key, @required this.index}) : super(key: key);

  @override
  _MenuState createState() => _MenuState(index);
}

class _MenuState extends State<Menu> {
  Color backgroudColor = Color(0xFFFFD6B2);
  int index = 0;
  String data = "";

  double heightContainer = 30.0;

  List<Widget> list = [
    GoogleMapScreen(),
    VideoPlayerScreen(),
    Consumo_Responsable(),
    Educacion(),
    //Cuestionario(data: 'asdasd')
  ];

  _MenuState(index) {
    this.index = index;
    //this.data = data;
  }

  void _onItemTapped(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
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
              shape: Border(
                  bottom: BorderSide(color: Color(0xFF8BC540), width: 2))),
          body: list[index],
          drawer: myDrawer(
              /*onTap: (ctx, i) {
            setState(() {
              index = i;
              Navigator.pop(ctx);
            });
          }*/

              ),

          //colitas
          bottomNavigationBar: _returnSphereBottomNavigationBar(),
        ));
  }

  Widget _returnContainer() {
    return Container(
      //Container para efecto visual deseado en vista.
      width: MediaQuery.of(context).size.width,
      height: HeightContainer().height,
      color: Colors.green,
    );
  }

  Widget _returnSphereBottomNavigationBar() {
    return SphereBottomNavigationBar(
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
                heightContainer = 30.0;
              });
              break;
            case 1:
              setState(() {
                heightContainer = 0.0;
              });
              break;
            case 2:
              setState(() {
                heightContainer = 0.0;
              });
              break;
            case 3:
              setState(() {
                heightContainer = 0.0;
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
