// import 'package:flutter/material.dart';

// import '../lines.dart';

// //!Custom painter
// class Sketcher extends CustomPainter {
//   final List<DrawnLine> drawlines;

//   Sketcher({required this.drawlines});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.redAccent
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 5.0;

//     for (int i = 0; i < drawlines.length; ++i) {
//       if (drawlines[i] == null) continue;
//       for (int j = 0; j < drawlines[i].path.length - 1; ++j) {
//         paint.color = drawlines[i].color;
//         paint.strokeWidth = drawlines[i].width;
//         canvas.drawLine(drawlines[i].path[j], drawlines[i].path[j + 1], paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(Sketcher oldDelegate) {
//     return true;
//   }
// }
