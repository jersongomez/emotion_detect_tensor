import 'package:emotion_detect_tensor/helpers/app_helper.dart';
import 'package:emotion_detect_tensor/helpers/camera.dart';
import 'package:emotion_detect_tensor/helpers/tflite.dart';
import 'package:emotion_detect_tensor/models/result.dart';
import 'package:emotion_detect_tensor/repo/repository.dart';
import 'package:emotion_detect_tensor/ui/recording_part.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DetectScreen extends StatefulWidget {
  DetectScreen({Key key, this.title, this.videoAssets, this.repository})
      : super(key: key);

  final String title;
  final String videoAssets;
  final Repository repository;

  @override
  _DetectScreenState createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  List<Result> outputs;
  VideoPlayerController _controller;
  String faceList = "";

  @override
  void initState() {
    super.initState();

    //Load TFLite Model
    TFLite.loadModel().then((value) {
      setState(() {
        TFLite.modelLoaded = true;
      });
    });

    //Initialize Camera
    Camera.initializeCamera();

    //Subscribe to TFLite's Classify events
    TFLite.tfLiteResultsController.stream.listen(
        (value) {
          value.forEach((element) {});

          //Set Results
          outputs = value;

          outputs.forEach((Result out) {
            faceList +=
                out.id.toString() + ":" + out.confidence.toString() + "/";
          });

          //Update results on screen
          setState(() {
            //Set bit to false to allow detection again
            Camera.isDetecting = false;
          });
        },
        onDone: () {},
        onError: (error) {
          AppHelper.log("listen", error);
        });

    // VideoPlayer Configuration
    _controller = VideoPlayerController.asset(widget.videoAssets)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: Camera.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Recording(
                  faceList: faceList,
                  repo: widget.repository,
                )
              ],
            ));
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    TFLite.disposeModel();
    Camera.camera.dispose();
    AppHelper.log("dispose", "Clear resources.");
    _controller.dispose();
    super.dispose();
  }

  Widget showVideo() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                Text(
                  _controller.value.isPlaying ? 'Pausar Video' : 'Play Video',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
