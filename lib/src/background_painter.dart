import 'dart:math';

import 'package:flutter/material.dart';
import 'package:i_am_speed/src/cloud_data.dart';

class CloudBackgroundPainter extends CustomPainter {

  final double animation;

  final List<Cloud> clouds = [];

  final Random rnd;

  CloudBackgroundPainter({required this.animation, int seed = 1337}) : rnd = Random(seed) {
    for(int i = 0; i < 75; i++) {
      final angle = rnd.nextDouble() * (2 * pi);
      final radius = rnd.nextDouble();
      final path = Path();
      for(int i = 0; i < 4 + rnd.nextInt(2); i++) {
        path.addOval(Rect.fromCircle(center: Offset(rnd.nextInt(30) - 15, rnd.nextInt(16) - 8), radius: 10.0 + rnd.nextInt(10)));
      }

      clouds.add(Cloud(angle, radius, path));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white70;
    // print(animation);
    for (var cloud in clouds) {
      final radius = cloud.radius + animation;
      drawCloud(size, radius, cloud.angle, canvas, cloud.path, paint);
      drawCloud(size, max(radius - 1.0, 0.0), cloud.angle, canvas, cloud.path, paint);
    }
  }

  void drawCloud(Size size, double radius, double angle, Canvas canvas, Path path, Paint paint) {
    var value = (15 * pow(radius, 8)).toDouble();
    final x = size.shortestSide * value * cos(angle) + (size.width / 2);
    final y = size.shortestSide * value * sin(angle) + (size.height / 2);
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(value * 3);


    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Path getCloudPath(Size size) {
    Path path = Path();
    path = Path();
    var width = size.width;
    var halfWidth = size.width / 2;
    var height = size.height;
    var halfHeight = size.height / 2;
    path.addOval(Rect.fromLTWH(-15, 0, width / 2, height / 2));
    path.addOval(Rect.fromLTWH(10, -7, width / 4, width / 4));
    path.addOval(Rect.fromLTWH(0, 5, width / 4, width / 4.5));
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class ColorBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.lightBlueAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
