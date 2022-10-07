import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/datasource.dart';
import 'package:flutter_qr_code_scanner/qr_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar.dart';

import '../main.dart';

//https://github.com/sbis04/flutter_camera_demo/blob/main/lib/screens/camera_screen.dart
class CameraScreen extends StatefulWidget {
  final String id;

  const CameraScreen({
    Key key,
    this.id,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController controller;

  File _imageFile;
  File _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = false;
  Duration myDuration = const Duration(seconds: 7);
  Timer countdownTimer;
  bool pictureCaptured = false;
  int seconds = 7;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    getPermissionStatus();
    Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      onNewCameraSelected(cameras[1]);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> setCountDown() async {
    const reduceSecondsBy = 1;
    if (seconds > 0) {
      setState(() {
        seconds = myDuration.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          if (!pictureCaptured) {
            pictureCaptured = true;
          }
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    }

    print('detik $seconds');
    if (seconds == 1) {
      await postTakePicture();
    }
  }

  void showBottomDialog(result) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(result),
                SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> postTakePicture() async {
    final CameraController cameraController = controller;
    print('masuk postTakePicture');

    if (cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      // controller.pausePreview();
      XFile rawImage = await cameraController.takePicture();
      Uint8List fileBytes = await rawImage.readAsBytes();
      await uploadPhoto(fileBytes, widget.id);

      showSuccessFlashbar();

      await Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => QrScanner()));
      });

      // File imageFile = File(rawImage.path);

      // int currentUnix = DateTime.now().millisecondsSinceEpoch;

      // final directory = await getApplicationDocumentsDirectory();

      // String fileFormat = imageFile.path.split('.').last;

      // print(imageFile);

      // await imageFile.copy(
      //   '${directory.path}/$currentUnix.$fileFormat',
      // );

      // refreshAlreadyCapturedImages();

      // showBottomDialog(rawImage.name);
      // Flushbar(
      //   flushbarPosition: FlushbarPosition.TOP,
      // )
      //   ..title = "Hey Ninja"
      //   ..message =
      //       "Lorem Ipsum is simply dummy text of the printing and typesetting industry"
      //   ..duration = Duration(seconds: 3)
      //   ..show(context);
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
    }
  }

  void showSuccessFlashbar() {
    Flushbar(
      borderRadius: 8,
      padding: EdgeInsets.all(10),
      backgroundColor: Colors.green.shade700,
      boxShadows: [
        BoxShadow(color: Colors.black45, offset: Offset(3, 3), blurRadius: 3)
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: 'Success',
      message: 'Thank you for coming',
    )..show(context);
  }

  double getAspectRatio(mediaSize) {
    return 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraPermissionGranted
          ? _isCameraInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: ClipRect(
                        clipper: _MediaSizeClipper(mediaSize),
                        child: Transform.scale(
                          scale: 1,
                          alignment: Alignment.topCenter,
                          child: CameraPreview(
                            controller,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '$seconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        8.0,
                        16.0,
                        8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isCameraInitialized = false;
                                  });
                                  onNewCameraSelected(
                                      cameras[_isRearCameraSelected ? 1 : 0]);
                                  setState(() {
                                    _isRearCameraSelected =
                                        !_isRearCameraSelected;
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.black38,
                                      size: 60,
                                    ),
                                    Icon(
                                      _isRearCameraSelected
                                          ? Icons.camera_front
                                          : Icons.camera_rear,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'LOADING',
                    style: TextStyle(color: Colors.white),
                  ),
                )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                Text(
                  'Permission denied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    getPermissionStatus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Give permission',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
