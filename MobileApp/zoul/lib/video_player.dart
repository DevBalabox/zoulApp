import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import 'package:zoul/extras/config.dart';

class VideoPlayer extends StatefulWidget {
  String url;
  String video_id;
  int required_time;
  final String user_data;
  VideoPlayer(this.url, this.video_id, this.required_time, this.user_data);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayer();
  }
}

class _VideoPlayer extends State<VideoPlayer> {
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    user_id = jsonDecode(widget.user_data)["user_id"] ?? null;
    user_data = widget.user_data;
    video_id = widget.video_id;
    needed_time = widget.required_time;
    print("Needed Time: " + needed_time.toString());

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
          print("Playing:" + playing.toString());
          checkVideo();
        }

        if (_controller.value.position == _controller.value.duration) {
          print('video Ended');
          new_user_view(context, mTime);
          pauseTimer();
          setState(() {
            mTime = 0;
          });
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
  int needed_time = 5;
  int mTime = 0;

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
          mTime++;
          print(mTime);
          if (_start < 1) {
            //timer.cancel();
            /* print(user_id);
            print(video_id); */
            //pauseVideo();
            //función para registrar la vista
            if ((mTime - 1) == needed_time) {
              print('Registro de vista');
              new_view(context, needed_time);
            }
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
        mTime = 0;
      });
      unpauseTimer();
    } else {
      print('video Stopped');
      if (mTime > 0) {
        new_user_view(context, mTime);
      }

      pauseTimer();
    }
  }

  @override
  void dispose() {
    //new_view(context, needed_time);
    new_user_view(context, mTime);
    _controller.dispose();
    _chewieController.dispose();
    pauseVideo();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    pauseTimer();
    setState(() {
      mTime = 0;
      Wakelock.disable();
    });
    super.dispose();
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

  Future<http.Response> new_view(BuildContext context, duration) async {
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
  }

  Future<http.Response> new_user_view(BuildContext context, duration) async {
    if (mTime > 0) {
      print("New User view: " + duration.toString());
      final http.Response response = await http.post(
        api_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "action": "new_user_view",
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
    } else {
      print("Time is 0");
    }
  }

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
