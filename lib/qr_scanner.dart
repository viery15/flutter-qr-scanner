import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/camera_screen.dart';
import 'package:flutter_qr_code_scanner/datasource.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey();
  String result = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildQrView(context),
        Positioned(
          top: 30,
          left: 3,
          child: Container(
            margin: EdgeInsets.fromLTRB(1, 1, 1, 1), //margin here
            child: FloatingActionButton(
              elevation: 2,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            margin: EdgeInsets.fromLTRB(1, 1, 1, 1), //margin here
            child: FloatingActionButton(
              elevation: 2,
              onPressed: () async {
                await controller.flipCamera();
              },
              child: Icon(Icons.flip_camera_android),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      var id = scanData.code;
      final invitation = await getInvitation(id);
      print(invitation);
      setState(() {
        result = invitation.fullname;
      });

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: const Text('Take Selfie'),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CameraScreen()));
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Finish'),
                        onPressed: () async {
                          setState(() {
                            Navigator.pop(context, true);
                          });
                          await controller.resumeCamera();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
