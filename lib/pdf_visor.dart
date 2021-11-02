import 'package:flutter/material.dart';
import 'package:flutter_tabs/src/sphere_bottom_navigation_bar.dart';
import 'package:flutter_tabs/src/util.dart';

import 'GoogleMapScreen.dart';
import 'VideoPlayerScreen.dart';
import 'consumo_responsable.dart';
import 'educacion.dart';
import 'myDrawer.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class PdfVisor extends StatefulWidget {
  final String pdf_url;
  PdfVisor({Key key, @required this.pdf_url}) : super(key: key);

  @override
  _PdfVisorState createState() => _PdfVisorState(pdf_url);
}

class _PdfVisorState extends State<PdfVisor> {
  String pdf_url;
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  _PdfVisorState(pdf_url) {
    this.pdf_url = pdf_url;
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(pdf_url);

    setState(() => _isLoading = false);
  }

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
        body: Center(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : PDFViewer(
                    document: document,
                    zoomSteps: 1,
                  )),
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
