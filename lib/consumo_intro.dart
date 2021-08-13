import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tabs/src/server.dart';

import 'package:url_launcher/url_launcher.dart';

class Consumo_intro extends StatefulWidget {
  Consumo_intro() : super();

  @override
  _Consumo_introState createState() => _Consumo_introState();
}

class _Consumo_introState extends State<Consumo_intro> {
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
      Fluttertoast.showToast(
          msg: "Ocurrio un error, inténtelo más tarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Error: " + e.toString());
      //progressD.hide();
      //there is error during converting file image to base64 encoding.
    } finally {
      //progressD.hide();
    }
  }

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      server.getUrl() + 'videos/consumo_responsable.mp4',
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(false);

    super.initState();

    //--------------
    loadInfo();
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
    return name;
  }

  _launchURL(String _url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 550,
        /*decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red[500],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),*/
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio(
                      aspectRatio: 1.5,
                      //aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
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
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              },
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Consumo Responsable',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ))),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      'El cuidado del medio ambiente es responsabilidad de todos, y aunque vivimos en una sociedad que incentiva el consumo, es importante formarnos un carácter crítico y consiente sobre nuestro consumo.\nEn esta sección encontrarás una serie de infografías con información interesante para tener un consumo responsable, consiente y ambientalmente sustentable.',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ))),
            Center(
                child: Container(
              margin: const EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  textStyle: TextStyle(fontSize: 12),
                  primary: Color(0xFFD11D5B),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ))
          ],
        ));
  }
}
