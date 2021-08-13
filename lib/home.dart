import 'package:flutter/material.dart';
import 'dart:math' as math;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CollapsingList(),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CollapsingList extends StatelessWidget {
  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 60.0,
        maxHeight: 200.0,
        child: Container(
            color: Colors.lightBlue, child: Center(child: Text(headerText))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid.count(
          crossAxisCount: 2,
          children: [
            Container(
              alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  Container(
                      child: GestureDetector(
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image:
                                  'https://plataformaciudadanacovid.com/MovidataAdmin/php/infographics/73523ae302fc5fdaf1e2bf8eccd50767.png',
                              width: 80)
                          /*Image.network(getImage("${value}"),
                                    width: 80),
                                onTap: () {
                                  //_launchURL(getFile("${value}"));
                                }*/
                          )),
                  Container(
                      child: Text(
                    'este es un ejemplo de texto largo',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ))
                ],
              ),
            ),
            Container(
                height: 130,
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    Container(
                        decoration: new BoxDecoration(color: Colors.white),
                        alignment: Alignment.center,
                        height: 80,
                        child: Image.network(
                            'https://plataformaciudadanacovid.com/MovidataAdmin/php/infographics/73523ae302fc5fdaf1e2bf8eccd50767.png',
                            fit: BoxFit.fill)),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'este es un ejemplo de texto largo',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.check, color: Colors.green),
                    )
                  ],
                )),
            Container(color: Colors.green, height: 150.0),
            Container(color: Colors.orange, height: 150.0),
            Container(color: Colors.yellow, height: 150.0),
            Container(color: Colors.pink, height: 150.0),
            Container(color: Colors.cyan, height: 150.0),
            Container(color: Colors.indigo, height: 150.0),
          ],
        ),
      ],
    );
  }
}
