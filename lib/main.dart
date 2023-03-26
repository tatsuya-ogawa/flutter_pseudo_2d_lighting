import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Pseudo Lighting'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  ui.Image? starImage;
  ui.Image? lightImage;
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(seconds: 360), vsync: this);
    animation = Tween(begin: 0.0, end: 360.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
    animationController.forward();
    Future(() async {
      final star = await rootBundle.load("assets/images/star.png");
      final starBuffer = Uint8List.view(star.buffer);
      ui.decodeImageFromList(starBuffer, (img) {
        starImage = img;
      });
      final light = await rootBundle.load("assets/images/light.png");
      final lightBuffer = Uint8List.view(light.buffer);
      ui.decodeImageFromList(lightBuffer, (img) {
        lightImage = img;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: PaintCanvas(
                star: starImage, light: lightImage, val: -animation.value),
          );
        },
      )),
    );
  }
}

class PaintCanvas extends CustomPainter {
  final ui.Image? star;
  final ui.Image? light;
  final double val;

  PaintCanvas({required this.star, required this.light, required this.val});

  void drawRotatedImage(Canvas canvas, Size size, Offset drawCenter,
      ui.Image image, double angle, Paint p, bool crop) {
    canvas.save();
    final rotateOffset = -0.5 * image.width;
    canvas.translate(-drawCenter.dx + size.width * .3 * sin(angle),
        -drawCenter.dy + size.height * .3 * cos(angle));
    canvas.translate(-rotateOffset, -rotateOffset);
    if (crop) {
      final ovalBreadth = 96.0;
      Rect rect =
          Rect.fromLTWH(0, -.5 * ovalBreadth, 1.0 * image.width, ovalBreadth);
      final lightAngle = pi * .275;
      canvas.rotate(-lightAngle);
      canvas.clipPath(Path()..addOval(rect));
      canvas.rotate(lightAngle);
    }
    canvas.rotate(angle);
    canvas.translate(rotateOffset, rotateOffset);
    canvas.drawImage(image, Offset(0, 0), p);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (star == null || light == null) return;
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final angle = val * 2;
    final offset = Offset(50.0, -50.0);
    drawRotatedImage(canvas, size, offset, star!, angle, paint, false);
    drawRotatedImage(canvas, size, offset, light!, angle, paint, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
