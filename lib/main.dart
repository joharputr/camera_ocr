import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera2/api/api.dart';
import 'package:camera2/model/ocr_model.dart';
import 'package:camera2/view_model/camera_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  return runApp(
    ChangeNotifierProvider(
        create: (context) => CameraViewModel(),
        child: TakePictureScreen(
          camera: firstCamera,
        )),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  ApiOcr _apiOcr = ApiOcr();
  Timer timer;

  @override
  void initState() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
    setTimer();
    super.initState();
  }

  void setTimer() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(
          "timerPV = ${Provider.of<CameraViewModel>(context, listen: false).timer}");
      timer = Timer.periodic(
          Duration(
              seconds: Provider.of<CameraViewModel>(context, listen: false)
                  .timer), (timer) {
        print("testTImer");
        takeCamera(
            cameraViewModel:
                Provider.of<CameraViewModel>(context, listen: false));
      });
    });
  }

  void takeCamera({CameraViewModel cameraViewModel}) async {
    try {
      await _initializeControllerFuture;
      String timestamp() =>
          new DateTime.now().millisecondsSinceEpoch.toString();
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/OCR';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${timestamp()}.jpg';
      await _controller.takePicture(filePath);

      print("filepathTake = ${filePath}");

      File file = File(filePath);
      _apiOcr.postOcr(file).then((value) {
        if (value is! OcrModel) {
          Fluttertoast.showToast(
              msg: "${value}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "${value.results[0].plate}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          cameraViewModel.addPoliceNumber(value.results[0].plate);
          setState(() {});
        }
      });
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      Fluttertoast.showToast(
          msg: "${e}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  secTimer() {}

  @override
  Widget build(BuildContext context) {
    //Still called twice
    CameraViewModel viewModel =
        Provider.of<CameraViewModel>(context, listen: false);

    // Timer(Duration(milliseconds: viewModel.timer), () {
    //   takeCamera(cameraViewModel: viewModel);
    //   print("timerOn:) = ${viewModel.timer / 1000} detik");
    //   setState(() {});
    // });
    print("timerBuild  = ${viewModel.timer}");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ocr Test'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    _showMyDialog(context, viewModel);
                    print("dadd");
                  },
                  child: Icon(
                    Icons.timer,
                    size: 30.0,
                  ),
                );
              }),
            )
          ],
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(_controller),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      height: double.infinity,
                      child: ListView.builder(
                        itemCount: viewModel.policeNumber.length,
                        reverse: true,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${viewModel.policeNumber[i]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<void> _showMyDialog(
      BuildContext context, CameraViewModel cameraViewModel) async {
    TextEditingController timerController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (_) {
        return Dialog(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Text("Ubah Timer"),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: timerController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      cameraViewModel
                          .changeTimer(int.parse(timerController.text))
                          .then((value) {
                        timer.cancel();
                        setTimer();
                      });
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  )
                ],
              ),
            ],
          ),
        ));
      },
    );
  }
}
