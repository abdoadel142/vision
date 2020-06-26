import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class barcodeScan extends StatefulWidget {
  final String text;

  barcodeScan({this.text});

  @override
  _barcodeScanState createState() => _barcodeScanState(text: this.text);
}

class _barcodeScanState extends State<barcodeScan> {
  final String text;

  _barcodeScanState({this.text});
  String barcodeContent = "";
  bool again = false;
  Future barcodeScanning() async {
//imageSelectorGallery();

    try {
      var barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcodeContent = barcode.rawContent;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcodeContent = 'No camera permission!';
        });
      } else {
        setState(() => this.barcodeContent = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcodeContent = 'Nothing captured.');
    } catch (e) {
      setState(() => this.barcodeContent = 'Unknown error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Scan Barcode'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      again == true ? barcodeContent : text,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: RaisedButton(
                color: Colors.black,
                child: Text(
                  "Scan Again",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  barcodeScanning();
                  setState(() {
                    again = true;
                  });
                },
              ),
            )
          ],
        ));
  }
}
