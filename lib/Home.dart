import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:traffic_ml/Infrastructor/Singleton.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Instance
  CameraController? cameraController;
  CameraImage? cameraImage;
  late List<CameraDescription> cameras;
  String output = '';

  Future? InitCamera;
  //Method
  Future initializeCamera() async {
    cameras = await availableCameras();
    // initModel();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await cameraController!.initialize();
    cameraController!.startImageStream((image) async {
      cameraImage = image;
      Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 0,
        imageStd: 255.0,
        threshold: 0.2,
      ).then((recognitions) {
        print(recognitions);
      });
    });
  }

  Future initModel() async {
    Tflite.close();
    var res = await Tflite.loadModel(
        model: 'assets/yolov2_tiny.tflite',
        labels: 'assets/yolov2_tiny.txt',
        useGpuDelegate: true);
    output = res!;
    setState(() {});
  }

  // void runModel() async {
  //   if (cameraImage != null) {
  //     var prediction = await Tflite.runModelOnFrame(
  //       bytesList: cameraImage!.planes.map(
  //         (e) {
  //           return e.bytes;
  //         },
  //       ).toList(),
  //       imageHeight: cameraImage!.height,
  //       imageWidth: cameraImage!.width,
  //       imageMean: 127.5,
  //       imageStd: 127.5,
  //       // rotation: 90,
  //       numResults: 2,
  //       threshold: 0.1,
  //       asynch: true,
  //     );
  //     prediction!.forEach((element) {
  //       setState(() {
  //         output = element['label'];
  //       });
  //     });
  //   }
  // }

  @override
  void initState() {
    InitCamera = initializeCamera();
    super.initState();
    initModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
          future: InitCamera,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  CameraPreview(cameraController!),
                  Text('Output=' + output),
                ],
              );
            }
            return Container(
              child: Text("hi"),
            );
          },
        ));
  }
}
