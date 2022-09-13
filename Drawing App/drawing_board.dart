import 'dart:async';

import 'package:expandable_menu_flutter/Drawing%20App/lines.dart';
import 'package:flutter/material.dart';

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({Key? key}) : super(key: key);

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  //!List of colors
  List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.yellow,
    Colors.purple,
    Colors.green,
    Colors.blue,
    Colors.blueGrey,
    Colors.teal,
    Colors.orange,
    Colors.brown,
    Colors.lime,
    Colors.indigo,
    Colors.cyan,
    Colors.black,
  ];
  //!Scrollbar controller
  ScrollController con = ScrollController();
  final GlobalKey _globalKey = GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine? line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  //!Stream Controllers
  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            buildCurrentPath(context),
            buildAllPaths(context),
            //!clear and stroke buttons
            Positioned(
              top: 40,
              right: 30,
              child: Row(
                children: [
                  //!Strokes
                  Slider(
                    min: 0,
                    max: 40,
                    value: selectedWidth,
                    onChanged: (val) => setState(() => selectedWidth = val),
                  ),
                  //!Board clear button
                  ElevatedButton.icon(
                    onPressed: () => setState(() => lines = []),
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      //!Color palates
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: MediaQuery.of(context).size.height / 8,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Scrollbar(
            //!for web scroll
            trackVisibility: false,
            thumbVisibility: false,
            thickness: 2,
            controller: con,
            child: SingleChildScrollView(
              controller: con,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                //!for horizontal scroll
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(
                    colors.length,
                    (index) => colorPalates(
                      colors[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//!Current path
  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder(
            stream: currentLineStreamController.stream,
            builder: (context, AsyncSnapshot<DrawnLine> snapshot) {
              return CustomPaint(
                painter: Sketcher(lines: []),
              );
            },
          ),
        ),
      ),
    );
  }

//!All PATHS
  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  //!Pan Start Function
  void onPanStart(DragStartDetails details) {
    Offset point = details.localPosition;
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

//!Pan Update Function
  void onPanUpdate(DragUpdateDetails details) {
    Offset point = details.localPosition;

    List<Offset> path = List.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

//!Pan End Function
  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line!);

    linesStreamController.add(lines);
  }

//!Color Palates Function
  GestureDetector colorPalates(Color color) {
    bool isSelect = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        height: isSelect ? 50 : 40,
        width: isSelect ? 50 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelect ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}

//!Custom painter
class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        paint.color = lines[i].color;
        paint.strokeWidth = lines[i].width;
        canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
