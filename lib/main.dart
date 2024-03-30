import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class Parameters {
  Parameters(this.blendMode);

  BlendMode blendMode;
}

void _paint(Canvas canvas, Size size, ui.Image? src, ui.Image? dst,
    Parameters parameters) {
  if (src != null && dst != null) {
    canvas.saveLayer(null, Paint()..blendMode = BlendMode.srcOver);
    canvas.drawImageRect(
        dst,
        Rect.fromLTWH(0, 0, dst.width.toDouble(), dst.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint());
    canvas.restore();
    canvas.saveLayer(null, Paint()..blendMode = parameters.blendMode);
    canvas.drawImageRect(
        src,
        Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint());
    canvas.restore();
  }
}

class MyPainter extends CustomPainter {
  final ui.Image? _src;
  final ui.Image? _dst;
  final Parameters _parameters;

  MyPainter(this._src, this._dst, this._parameters);

  @override
  void paint(Canvas canvas, Size size) =>
      _paint(canvas, size, _src, _dst, _parameters);
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(MyPainter oldDelegate) => false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? _src;
  ui.Image? _dst;
  Parameters _parameters = Parameters(BlendMode.multiply);

  Future<ui.Image> loadImageFromAssets(String path) async {
    final ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void initState() {
    super.initState();
    loadImageFromAssets('assets/src.png').then((value) {
      setState(() {
        _src = value;
      });
    });
    loadImageFromAssets('assets/dst.png').then((value) {
      setState(() {
        _dst = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: MyPainter(_src, _dst, _parameters),
        );
      }),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const Text('foo:'),
            Slider(value: 0.5, onChanged: (double newValue) {}),
            DropdownMenu<BlendMode>(
                initialSelection: _parameters.blendMode,
                onSelected: (BlendMode? value) {
                  setState(() {
                    if (value != null) {
                      _parameters.blendMode = value;
                    }
                  });
                },
                dropdownMenuEntries:
                    BlendMode.values.map((BlendMode blendMode) {
                  return DropdownMenuEntry<BlendMode>(
                      value: blendMode, label: blendMode.name);
                }).toList())
          ],
        ),
      ),
    );
  }
}
