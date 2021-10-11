import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    ChewieDemo(),
  );
}

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {

  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _future;
  String videoUrl = 'https://player.vimeo.com/external/415594482.m3u8?s=24d28b2d625776c2fad06d9445df484d1ab23585';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(videoUrl);
    _future = initVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> initVideoPlayer() async{
    await _controller.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        aspectRatio: _controller.value.aspectRatio,
        autoPlay: true,
        looping: true,
        placeholder: buildPlaceholderImage()
      );
    });
  }

  buildPlaceholderImage(){
    return Center(
       child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) return buildPlaceholderImage();

            return Center(
               child: Chewie(controller: _chewieController,),
             );
          },
      )
    );
  }
}