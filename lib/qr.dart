import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey qrKey = GlobalKey();
  String barcode = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scanner'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: QRView(
                key: qrKey,
                onQRViewCreated: (controller) {
                  controller.scannedDataStream.listen((value) {
                    setState(() {
                      barcode = value.code;
                    });
                  });
                },
              ),
            ),
            Expanded(
              child: Center(
                child: Text('Result: $barcode'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('CONTAINED BUTTON'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
