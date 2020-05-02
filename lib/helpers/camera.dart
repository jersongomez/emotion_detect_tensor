import 'package:camera/camera.dart';
import 'package:emotion_detect_tensor/helpers/app_helper.dart';
import 'package:emotion_detect_tensor/helpers/tflite.dart';
import 'package:flutter/foundation.dart';

class Camera {
  static CameraController camera;

  static bool isDetecting = false;
  static CameraLensDirection _direction = CameraLensDirection.back;
  static Future<void> initializeControllerFuture;

  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static void initializeCamera() async {
    AppHelper.log("_initializeCamera", "Initializing camera..");

    camera = CameraController(
        await _getCamera(_direction),
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.low
            : ResolutionPreset.high,
        enableAudio: false);
    initializeControllerFuture = camera.initialize().then((value) {
      AppHelper.log(
          "_initializeCamera", "Camera initialized, starting camera stream..");

      camera.startImageStream((CameraImage image) {
        if (!TFLite.modelLoaded) return;
        if (isDetecting) return;
        isDetecting = true;
        try {
          TFLite.classifyImage(image);
        } catch (e) {
          print(e);
        }
      });
    });
  }
}