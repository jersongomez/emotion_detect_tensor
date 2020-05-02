import 'dart:async';

import 'package:camera/camera.dart';
import 'package:emotion_detect_tensor/helpers/app_helper.dart';
import 'package:emotion_detect_tensor/models/result.dart';
import 'package:tflite/tflite.dart';

class TFLite {
  static StreamController<List<Result>> tfLiteResultsController = StreamController.broadcast();
  static List<Result> _outputs = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async{
    AppHelper.log("loadModel", "Loading model..");

    return Tflite.loadModel(
      model: "assets/model_100.tflite",
      labels: "assets/labels_100.txt",
    );
  }

  static classifyImage(CameraImage image) async {

    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: image.height, 
            imageWidth: image.width,   
            imageMean: 125.0,        
            imageStd: 125.0,         
            rotation: 90,            
            numResults: 2,           
            threshold: 0.7,          
            asynch: true,
            )
        .then((value) {
      if (value.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));

          AppHelper.log("classifyImage",
              "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      //Sort results according to most confidence
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel(){
    Tflite.close();
    tfLiteResultsController.close();
  }
}