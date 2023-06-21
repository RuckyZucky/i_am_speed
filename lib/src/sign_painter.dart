import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TrainSignPainter extends CustomPainter {

  final String text;

  TrainSignPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black..strokeWidth = 4.0..style = PaintingStyle.stroke);
    final height = math.sqrt(math.pow(size.width, 2) - math.pow(size.width / 2, 2));
    final polePaint = Paint()..strokeWidth = 7.0..shader = ui.Gradient.linear(Offset(size.width / 2 - 7, 0), Offset(size.width / 2 + 7, 0), [Color(0xFF777777), Color(0xFFBBBBBB), Color(0xFF777777)], [0, 0.6, 1]);
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width / 2, height - 20), polePaint);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.relativeLineTo(-size.width / 2, height);
    path.close();
    canvas.drawShadow(path.transform((Matrix4.identity()..translate(-(size.width * 0.1) / 2, -(height * 0.1) / 2)).scaled(1.1).storage), Colors.black, 4, true);
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.black..strokeWidth = 2.0..style = PaintingStyle.stroke);
    // canvas.drawPath(path, Paint()..color = Colors.white..strokeWidth = 6.0..style = PaintingStyle.stroke);
    final txtPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.w900, fontFamily: 'CabinCondensed_regular', color: Colors.black)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 12.0 - 12.0);
    txtPainter.paint(canvas, Offset((size.width - txtPainter.width) / 2, (height - txtPainter.height) / 2 - 14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
