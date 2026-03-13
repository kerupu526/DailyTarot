import 'dart:math';

import 'package:flutter/material.dart';

class ClockHandPainter extends CustomPainter {
  final int value;
  final bool isHour;

  ClockHandPainter({required this.value, required this.isHour});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    double angle = isHour
        ? (value * 30 - 90) * pi / 180
        : (value * 6 - 90) * pi / 180;

    final handLength = size.width * 0.3;
    final endPoint = Offset(
      center.dx + handLength * cos(angle),
      center.dy + handLength * sin(angle),
    );

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, endPoint, paint);

    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}