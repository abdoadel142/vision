import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vision/Screens/barcodeScan.dart';
import 'package:barcode_scan/barcode_scan.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with AutomaticKeepAliveClientMixin {
  CameraController _controller;
  List<CameraDescription> _cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //final _timerKey = GlobalKey<VideoTimerState>();
  bool labeled = false;
  bool switcher = false;
  bool readed = false;
  bool isImageLoaded = false;
  File pickedImage;
  List text = [];
  List<ImageLabel> mylabels = [];
  final FlutterTts _flutterTts = FlutterTts();
  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  String barcodeContent = "";

  Future barcodeScanning() async {
//imageSelectorGallery();

    try {
      var barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcodeContent = barcode.rawContent;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => barcodeScan(
                  text: barcodeContent,
                )),
      );
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

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_controller != null) {
      if (!_controller.value.isInitialized) {
        return Container();
      }
    } else {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Vision",
          style: TextStyle(letterSpacing: 5),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                  child: Text(
                'Vision',
                style: TextStyle(color: Colors.white, letterSpacing: 6),
              )),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              title: Text('Scan Barcode'),
              trailing: Icon(Icons.scanner),
              onTap: () {
                barcodeScanning();
              },
            ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('Settings'),
              trailing: Icon(Icons.settings),
              onTap: () {},
            ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('FeedBack'),
              trailing: Icon(Icons.feedback),
              onTap: () {},
            ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('Contact Us'),
              trailing: Icon(Icons.call),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          _buildCameraPreview(),
          Positioned(
            top: 24.0,
            left: 12.0,
            child: IconButton(
              icon: Icon(
                Icons.switch_camera,
                color: Colors.white,
              ),
              onPressed: () {
                _onCameraSwitch();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: _controller.value.aspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
        color: Theme.of(context).bottomAppBarColor,
        height: 100.0,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Center(
              //backgroundColor: Colors.white,
              child: switcher != true
                  ? Text(
                      "Objects",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    )
                  : Text("Texts",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0)),
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28.0,
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  size: 28.0,
                  color: Colors.black,
                ),
                onPressed: _captureImage,
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28.0,
              child: IconButton(
                icon: Icon(
                  Icons.swap_horiz,
                  size: 28.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    switcher == true ? switcher = false : switcher = true;
                    say(switcher != true
                        ? "Recognising objects"
                        : "Recognising texts");
                  });
                },
              ),
            ),
          ],
        ));
  }

  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (_controller.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _captureImage() async {
    print('_captureImage');
    if (_controller.value.isInitialized) {
      SystemSound.play(SystemSoundType.click);

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${_timestamp()}.jpeg';
      print('path: $filePath');

      await _controller.takePicture(filePath);
      if (switcher == true) {
        readText(filePath);
      } else {
        labelImage(filePath);
      }
    }
  }

  Future labelImage(String fpath) async {
//    final FirebaseVisionImage visionImage =
//        FirebaseVisionImage.fromFile(pickedImage);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFilePath(fpath);

    final ImageLabeler labelDetector = FirebaseVision.instance
        .imageLabeler(ImageLabelerOptions(confidenceThreshold: 0.50));
    final List<ImageLabel> labels =
        await labelDetector.processImage(visionImage);
    setState(() {
      mylabels = labels;
      labeled = true;
    });
    List<ImageLabel> labelstexts = [];
    for (ImageLabel label in labels) {
      final String labelText = label.text;
      labelstexts.add(label);
      //labelstexts.add(label.text);
      //schoSnackBar(labelText);
    }
    //   await _flutterTts.speak(labelstexts.join("    "));
    labelstexts.sort((a, b) => a.confidence.compareTo(b.confidence));
    labelstexts.forEach((ImageLabel l) {
      print(l.confidence);
    });
    await _flutterTts.speak(labelstexts.last.text);
  }

  Future readText(String fpath) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFilePath(fpath);
    TextRecognizer recognizerText = FirebaseVision.instance.textRecognizer();
    VisionText readtext = await recognizerText.processImage(ourImage);

    for (TextBlock block in readtext.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            text.add(word.text);
          });
          print(word.text);
        }
      }
    }
    setState(() {
      readed = true;
    });
    speak();
  }

  Future speak() async {
    await _flutterTts.setPitch(1.0);
    print(await _flutterTts.getLanguages);
    print(await _flutterTts.getVoices);
    await _flutterTts.speak(text.join(" "));
  }

  Future say(String mess) async {
    await _flutterTts.setPitch(1.0);

    await _flutterTts.speak(mess);
  }

  void schoSnackBar(message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();

//  Future<String> startVideoRecording() async {
//    print('startVideoRecording');
//    if (!_controller.value.isInitialized) {
//      return null;
//    }
//    setState(() {
//      _isRecording = true;
//    });
//    _timerKey.currentState.startTimer();
//
//    final Directory extDir = await getApplicationDocumentsDirectory();
//    final String dirPath = '${extDir.path}/media';
//    await Directory(dirPath).create(recursive: true);
//    final String filePath = '$dirPath/${_timestamp()}.mp4';
//
//    if (_controller.value.isRecordingVideo) {
//      // A recording is already started, do nothing.
//      return null;
//    }
//
//    try {
////      videoPath = filePath;
//      await _controller.startVideoRecording(filePath);
//    } on CameraException catch (e) {
//      _showCameraException(e);
//      return null;
//    }
//    return filePath;
//  }
//
//  Future<void> stopVideoRecording() async {
//    if (!_controller.value.isRecordingVideo) {
//      return null;
//    }
//    _timerKey.currentState.stopTimer();
//    setState(() {
//      _isRecording = false;
//    });
//
//    try {
//      await _controller.stopVideoRecording();
//    } on CameraException catch (e) {
//      _showCameraException(e);
//      return null;
//    }
//  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  @override
  bool get wantKeepAlive => true;
}
