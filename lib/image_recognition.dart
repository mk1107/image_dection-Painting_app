//ref:-
//https://flutter.dev/docs/cookbook/plugins/picture-using-camera
//https://medium.com/flutterdevs/using-firebase-ml-kit-in-flutter-9e72b8e45e96


import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';



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

  File _userImageFile;
  List<ImageLabel> _imageLabels = [];
  var result = "";

  void _pickedImage(String image) {
    _userImageFile = File(image);
  }

  //image_label_recognition
  processImageLabels() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    _imageLabels = await labeler.processImage(myImage);
    result = "";
    for (ImageLabel imageLabel in _imageLabels) {
      setState(() {
        result = result +
            imageLabel.text +
            ":" +
            imageLabel.confidence.toString() +
            "\n";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Take a picture',style: (TextStyle(fontSize: 28,)),),
        centerTitle: true,
      ),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.

            final image = await _controller.takePicture();

            _pickedImage(image?.path);

            await processImageLabels();

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image?.path,
                  result: result,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),



    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String result;
  const DisplayPictureScreen({Key key, this.imagePath, this.result}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Display the Picture',style: (TextStyle(fontSize: 28,)),),
        centerTitle: true,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body:new Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[

            Image.file(File(imagePath)),

            new Padding(padding: const EdgeInsets.all(5.0)),

            Text(result, style: (TextStyle(fontSize: 15,)),),

            new Padding(padding: const EdgeInsets.all(5.0)),

            Row(
              children: <Widget>[

                new Padding(padding: const EdgeInsets.all(7.0)),
                Column(
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(' Another Pic ', style: (TextStyle(fontSize: 24,)),),
                            Icon(Icons.photo_camera,),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.black12,
                        splashColor: Colors.deepOrangeAccent,
                      ),
                    ]
                ),

                new Padding(padding: const EdgeInsets.all(20.0)),

                Column(
                    children: <Widget>[
                      // ignore: deprecated_member_use
                      new RaisedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(' Home ', style: (TextStyle(fontSize: 24,)),),
                            Icon(Icons.home,),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.black12,
                        splashColor: Colors.deepOrangeAccent,
                      ),
                    ]
                ),

              ],
            )

          ],
        ),
      ),


    );
  }
}