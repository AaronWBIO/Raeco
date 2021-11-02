import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tabs/GoogleMapScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tabs/src/server.dart';

class Welcome extends StatefulWidget {
  Welcome() : super();

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool showPlay = true;

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
      server.getUrl() + 'videos/intro.mp4',
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    /*_initializeVideoPlayerFuture =
        _controller.initialize().then((value) => _controller.play());]*/

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_welcome.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      child: Image.asset(
                        'assets/images/bg1.png',
                        width: 300,
                      ))),
              Container(
                  margin: const EdgeInsets.only(top: 50.0),
                  child: GestureDetector(
                    child: FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // If the VideoPlayerController has finished initialization, use
                          // the data it provides to limit the aspect ratio of the video.

                          return AspectRatio(
                            //aspectRatio: 5 / 2,
                            aspectRatio: _controller.value.aspectRatio,
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
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 80.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      }
                      _controller.pause();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleMapScreen()));
                    },
                    child: Text('Empezar'),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      textStyle: TextStyle(fontSize: 16),
                      primary: Color(0xFF8BC540),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  )),
              Expanded(
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/footer1.png',
                              width: MediaQuery.of(context).size.width,
                            )),
                        Container(
                            alignment: Alignment.bottomCenter,
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Image.asset(
                              'assets/images/footer2.png',
                              width: MediaQuery.of(context).size.width,
                            )),
                      ],
                    )),
              ),
            ],
          )),
    );
  }
}
