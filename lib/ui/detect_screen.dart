import 'package:emotion_detect_tensor/helpers/app_helper.dart';
import 'package:emotion_detect_tensor/helpers/camera.dart';
import 'package:emotion_detect_tensor/helpers/tflite.dart';
import 'package:emotion_detect_tensor/models/result.dart';
import 'package:emotion_detect_tensor/ui/recording_part.dart';
import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

class DetectScreen extends StatefulWidget {
  DetectScreen({Key key}) : super(key: key);

  @override
  _DetectScreenState createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  List<Result> outputs;
  ScrollController controller = ScrollController();
  List<VideoController> vcs = [];
  List<String> videosAssets = [
    'assets/11.mp4',
    'assets/21.mp4',
    'assets/31.mp4',
    'assets/41.mp4'
  ];
  String faceList = "";
  String faceData = "";

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
            faceList += out.id.toString() +
                ":" +
                out.confidence.toStringAsFixed(3) +
                "/";
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

    // Video Configuration
    for (var video in videosAssets) {
      vcs.add(VideoController(source: VideoPlayerController.asset(video))
        ..initialize()
        //..addListener(holiboli)
        );
    }
  }

  holiboli(VideoController vc) {
    if (vc.value.position.inSeconds == 1) {
      faceList += vc.value.dataSource.substring(vc.value.dataSource.indexOf('/'));
      print('PANDA -> ' + faceList);
    }
    if (vc.value.position < vc.value.duration) {
      faceList += faceData;
      print('PANDA faceList en cada second ' + faceList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview face control'),
      ),
      body: FutureBuilder<void>(
        future: Camera.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return ListView(
              controller: controller,
              children: <Widget>[
                for (var vc in vcs)
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Estado del video: '),
                      vc.value.duration == vc.value.position
                      ? Row(children: <Widget>[Icon(Icons.check_circle, color: Colors.green,), Text('Hecho')],) 
                      : Row(children: <Widget>[Icon(Icons.error, color: Colors.red,), Text('Falta')],),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: AspectRatio(
                          aspectRatio: 1/1,
                          child: VideoBox(controller: vc),
                        ),
                      ),
                    ],
                  ),
                Recording(faceList: faceList)
              ],
            );
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
    //TFLite.disposeModel();
    Camera.camera.dispose();
    AppHelper.log("dispose", "Clear resources.");

    // Video dispose
    for (var vc in vcs) {
      vc.dispose();
    }
    super.dispose();
  }
}
