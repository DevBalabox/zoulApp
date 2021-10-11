import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:zoul/extras/config.dart';

class CoachVideoPlayer extends StatefulWidget {
  String url;
  CoachVideoPlayer(this.url);

  @override
  State<StatefulWidget> createState() {
    return _CoachVideoPlayer();
  }
}

class _CoachVideoPlayer extends State<CoachVideoPlayer> {
  @override
  void initState() {
    super.initState();

    if (widget.url != "" && widget.url != null) {
      videoUrl = widget.url;
    }
    appbarOpacity = 0.0;
    _controller = VideoPlayerController.network(videoUrl);
    _future = initVideoPlayer();
    _controller
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != playing) {
          setState(() {
            playing = isPlaying;
          });
          print(playing.toString());
          checkVideo();
        }
      });
  }

  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _future;
  //String videoUrl = 'https://player.vimeo.com/external/415594482.m3u8?s=24d28b2d625776c2fad06d9445df484d1ab23585';
  String videoUrl = '';

  Timer _timer;
  int _start = 0;
  bool _vibrationActive = false;
  bool playing = true;
  int needed_time = 60;

  String user_id = "";
  String user_data = "";
  String video_id = "";

  double appbarOpacity;

  void startTimer(int timerDuration) {
    if (_timer != null) {
      _timer.cancel();
    }
    setState(() {
      _start = timerDuration;
    });
    const oneSec = const Duration(seconds: 1);
    print('test');
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            print('Registro de vista');
            /* print(user_id);
            print(video_id); */
            //pauseVideo();
            //función para registrar la vista
            //new_view(context, needed_time);
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void pauseTimer() {
    if (_timer != null) _timer.cancel();
  }

  void unpauseTimer() => startTimer(_start);

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_controller.value.isPlaying) {
      print('video Started');
      setState(() {
        playing = true;
      });
      unpauseTimer();
    } else {
      print('video Stopped');
      pauseTimer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    pauseVideo();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> initVideoPlayer() async {
    await _controller.initialize();
    setState(() {
      _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: _controller.value.aspectRatio,
          autoPlay: true,
          looping: false,
          placeholder: buildPlaceholderImage());
      startTimer(needed_time);
    });
  }

  buildPlaceholderImage() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  pauseVideo() {
    _controller?.pause();
    _chewieController?.pause();
  }

  /* Future<http.Response> new_view(BuildContext context, duration) async {
    final http.Response response = await http.post(
      api_url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "action": "new_view",
        "user_id": user_id,
        "video_id": video_id,
        "video_duration": duration.toString()
      }),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //print(jsonResponse[0]['message'].toString());
      if (jsonResponse[0]['status'] == "true") {
      } else {}
    } else {}
  } */

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return buildPlaceholderImage();
            return Center(
              child: Chewie(
                controller: _chewieController,
              ),
            );
          },
        ));
  }
}
