//ref:-
//https://stackoverflow.com/questions/54982183/how-to-cancel-gesture-if-it-goes-beyond-containers-bound-in-flutter
//https://github.com/iampawan/fluttersignatureview/blob/master/lib/main.dart
//https://github.com/bdlukaa/color-picker/blob/master/lib/screens/image_picker/image_color_picker.dart


import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;



class ColorPickerWidget extends StatefulWidget {
  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}


Color imgcolor = Colors.green;

class drawingcolor{
  Offset point;
  Paint areaPaint;

  drawingcolor({this.point, this.areaPaint});

}


class _ColorPickerWidgetState extends State<ColorPickerWidget> {

  String imagePath = 'assets/bird.png';
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();
  List<drawingcolor> _points = [];



  bool useSnapshot = true;

  GlobalKey currentKey;

  

  final containerKey = GlobalKey();
  Rect get containerRect => containerKey.globalPaintBounds;


  final StreamController<Color> _stateController = StreamController<Color>();
  img.Image photo;

  @override
  void initState() {
    currentKey = useSnapshot ? paintKey : imageKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String title = useSnapshot ? "snapshot" : "basic";
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Color picker & Drawing Board',style: (TextStyle(fontSize: 28,)),),
          centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            //Row(
              //children: [
                StreamBuilder(
                    initialData: Colors.green[500],
                    stream: _stateController.stream,
                    builder: (buildContext, snapshot) {
                      Color selectedColor = snapshot.data ?? Colors.green;
                      imgcolor = selectedColor;
                      return Stack(
                        children: <Widget>[
                          RepaintBoundary(
                            key: paintKey,
                            child: GestureDetector(
                              onPanDown: (details) {
                                searchPixel(details.globalPosition);
                              },
                              onPanUpdate: (details) {
                                searchPixel(details.globalPosition);
                              },
                              child: Center(
                                child: Image.asset(
                                  imagePath,
                                  key: imageKey,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedColor,
                                border: Border.all(width: 2.0, color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ]),
                          ),
                          Positioned(
                            child: Text('${selectedColor}',
                                style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.black54)),
                            left: 35,
                            top: 12,
                          ),

                        ],
                      );

                    }),
           //   ],
            //),

                //new Padding(padding: const EdgeInsets.all(20.0)),

                Expanded(

                    child: new GestureDetector(

                      key: containerKey,
                      onPanDown: (DragDownDetails details) {
                        setState(() {
                          RenderBox object = context.findRenderObject();
                          Offset _localPosition = object.globalToLocal(_offsetInBox(details.globalPosition));
                          object.globalToLocal(details.globalPosition);
                          _points = new List.from(_points)..add(
                              drawingcolor(
                                  point: _localPosition,
                                  areaPaint: Paint()
                                    ..color= imgcolor
                                    ..strokeCap = StrokeCap.round
                                    ..strokeWidth = 10.0,
                              )

                          );
                        });
                      },
                      onPanUpdate: (DragUpdateDetails details) {
                        setState(() {
                          RenderBox object = context.findRenderObject();
                          Offset _localPosition = object.globalToLocal(_offsetInBox(details.globalPosition));
                          object.globalToLocal(details.globalPosition);
                          _points = new List.from(_points)..add(
                              drawingcolor(
                                point: _localPosition,
                                areaPaint: Paint()
                                  ..color= imgcolor
                                  ..strokeCap = StrokeCap.round
                                  ..strokeWidth = 10.0,
                              )
                          );
                        });
                      },
                      onPanEnd: (DragEndDetails details) => _points.add(null),

                      child: Container(
                        key: containerKey,
                        color: Colors.white,
                        child: new CustomPaint(
                          painter: new Signature(points: _points),
                          size: Size.infinite,
                        ),
                    ),
                    )
                ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new FloatingActionButton(
            child: new Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          ),

          SizedBox(
            width: 270,
          ),

          new FloatingActionButton(
            child: new Icon(Icons.clear),
            onPressed: () => _points.clear(),
          ),


        ],
      ),

    );
  }

  void searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
    }
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey.currentContext.findRenderObject();
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    if (!useSnapshot) {
      double widgetScale = box.size.width / photo.width;
      print(py);
      px = (px / widgetScale);
      py = (py / widgetScale);
    }

    int pixel32 = photo.getPixelSafe(px.toInt(), py.toInt());
    int hex = abgrToArgb(pixel32);

    _stateController.add(Color(hex));
  }

  Future<void> loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(imagePath);
    setImageBytes(imageBytes);
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes =
    await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    photo = null;
    photo = img.decodeImage(values);
  }



  Offset _offsetInBox(Offset globalOffset) {
    // Y coordinate
    double nearestY = 0;
    if (globalOffset.dy >= containerRect.top &&
        globalOffset.dy <= containerRect.bottom) {
      nearestY = globalOffset.dy;
    } else {
      if ((containerRect.top - globalOffset.dy).abs() >
          (containerRect.bottom - globalOffset.dy).abs()) {
        nearestY = containerRect.bottom;
      } else {
        nearestY = containerRect.top;
      }
    }

    // X coordinate
    double nearestX = 0;
    if (globalOffset.dx >= containerRect.left &&
        globalOffset.dx <= containerRect.right) {
      nearestX = globalOffset.dx;
    } else {
      if ((containerRect.left - globalOffset.dx).abs() >
          (containerRect.right - globalOffset.dx).abs()) {
        nearestX = containerRect.right;
      } else {
        nearestX = containerRect.left;
      }
    }
    print(
        "Global[${globalOffset.dx}, ${globalOffset.dy}], Found=[$nearestX, $nearestY]");

    return Offset(nearestX, nearestY - 370.0);
  }
}

// image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}

class Signature extends CustomPainter {
  List<drawingcolor> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {

    for (int i = 0; i < points.length - 1; i++) {

      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i].areaPaint;
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
      else if(points[i] != null && points[i + 1] == null){
        Paint paint = points[i].areaPaint;
        canvas.drawPoints(ui.PointMode.points,[points[i].point],paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}

extension GlobalKeyExtension on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

