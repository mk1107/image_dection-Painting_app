//Mohanish Kashiwar
//BT19ECE026

// ref mentioned on top of each dart file, might modified the code and used it as needed.
// I have configured objects on screen with reference to pixel 4 XL (6.3'' screen size 1440px * 3040px)
// may vary on device to device, this may also affect touch area.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_color_picker.dart';
import 'image_recognition.dart';

void main() {
  runApp(MyApp());
}

class Theme with ChangeNotifier{
  static bool _isDark = false;

  ThemeMode currentTheme(){
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

Theme currentTheme = Theme();


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    currentTheme.addListener((){
      print('Changes');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final App',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: currentTheme.currentTheme(),
      home: MyHomePage(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Home Page', style: (TextStyle(fontSize: 28,)),),
        centerTitle: true,
      ),
      body: new Padding(
        padding: EdgeInsets.all(56.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            new RaisedButton(
              onPressed: () async{
                WidgetsFlutterBinding.ensureInitialized();
                final cameras = await availableCameras();
                final firstCamera = cameras.first;
                var status = await Permission.storage.status;
                if (status.isUndetermined) {
                  // You can request multiple permissions at once.
                  Map<Permission, PermissionStatus> statuses = await [
                    Permission.storage,
                    Permission.camera,
                  ].request();
                  print(statuses[Permission.storage]); // it should print PermissionStatus.granted
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera,),));
              },
              child: Row(
                children: <Widget>[
                  Text(' Image Recognition  ', style: (TextStyle(fontSize: 26,)),),
                  Icon(Icons.computer,),
                  Text(' ')
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.black12,
              splashColor: Colors.deepOrangeAccent,
            ),

            new Padding(padding: const EdgeInsets.all(20.0)),

            new RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ColorPickerWidget(),));

                },
              child: Row(
                children: <Widget>[
                  Text('            Art Zone  ', style: (TextStyle(fontSize: 26,)),),
                  Icon(Icons.color_lens,),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.black12,
              splashColor: Colors.deepOrangeAccent,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          currentTheme.switchTheme();
        },
        label: Text('Theme', style: (TextStyle(fontSize: 20,)),),
        icon: Icon(Icons.brightness_5),
      ),
    );
  }
}