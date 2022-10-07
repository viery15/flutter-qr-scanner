import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/camera_screen.dart';
import 'package:flutter_qr_code_scanner/datasource.dart';
import 'package:flutter_qr_code_scanner/home.dart';
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Home()));
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
      if (invitation == null) {
        showResultModal(false);
        return;
      }

      setState(() {
        result = invitation.fullname;
      });

      showResultModal(true, id: id);
    });
  }

  void showResultModal(bool isSuccess, {String id}) {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: false,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isSuccess ? Icons.check_circle : Icons.close_sharp,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 100.0,
                ),
                Text(
                  isSuccess ? result : 'Data tidak ditemukan',
                  style: TextStyle(
                    fontSize: 24,
                    height: 2,
                    letterSpacing: 5,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isSuccess
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                              onPrimary: Colors.white,
                              shadowColor: Colors.greenAccent,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: Size(120, 40), //////// HERE
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.camera_alt, size: 20),
                                  ),
                                  TextSpan(
                                    text: " Take Selfie",
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                    id: id,
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox.shrink(),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: Size(120, 40), //////// HERE
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.check, size: 20),
                            ),
                            TextSpan(
                              text: " Finish",
                            ),
                          ],
                        ),
                      ),
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
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
