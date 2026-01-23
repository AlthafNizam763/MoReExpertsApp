import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.size = 60.0,
    this.color,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ProfessionalWalkerPainter(
              progress: _controller.value,
              baseColor: widget.color ?? const Color(0xFF1B72B5),
            ),
          );
        },
      ),
    );
  }
}

class _ProfessionalWalkerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _ProfessionalWalkerPainter({
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // Earth blue colors
    const Color earthBlue = Color(0xFF1B72B5);

    final double walkCycle = math.sin(progress * 2 * math.pi);

    // --- Body (Suit) ---
    final suitPaint = Paint()..color = Colors.black87;
    final bodyRect =
        Rect.fromLTWH(cx - w * 0.15, cy - h * 0.1, w * 0.3, h * 0.35);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), suitPaint);

    // --- Head ---
    final headPaint = Paint()..color = const Color(0xFFFFDDBB);
    canvas.drawCircle(Offset(cx, cy - h * 0.22), w * 0.12, headPaint);

    // --- Hair (Professional) ---
    final hairPaint = Paint()..color = Colors.black;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy - h * 0.24), radius: w * 0.13),
      math.pi,
      math.pi,
      true,
      hairPaint,
    );

    // --- Earth-Blue Tie ---
    final tiePaint = Paint()..color = earthBlue;
    final tiePath = Path();
    tiePath.moveTo(cx, cy - h * 0.12); // Neck top
    tiePath.lineTo(cx - w * 0.03, cy - h * 0.08);
    tiePath.lineTo(cx, cy + h * 0.05); // Point
    tiePath.lineTo(cx + w * 0.03, cy - h * 0.08);
    tiePath.close();
    canvas.drawPath(tiePath, tiePaint);

    // --- Legs (Walking) ---
    final legPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    // Leg 1
    final leg1X = cx + walkCycle * w * 0.15;
    canvas.drawLine(
      Offset(cx - w * 0.05, cy + h * 0.2),
      Offset(leg1X - w * 0.05, cy + h * 0.45),
      legPaint,
    );

    // Leg 2
    final leg2X = cx - walkCycle * w * 0.15;
    canvas.drawLine(
      Offset(cx + w * 0.05, cy + h * 0.2),
      Offset(leg2X + w * 0.05, cy + h * 0.45),
      legPaint,
    );

    // --- Earth-Blue Bag ---
    final bagPaint = Paint()..color = earthBlue;
    final bagRect = Rect.fromLTWH(cx + w * 0.18 + (walkCycle * w * 0.05),
        cy - h * 0.05, w * 0.25, h * 0.2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bagRect, const Radius.circular(2)), bagPaint);

    // Bag handle
    final handlePaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(cx + w * 0.22 + (walkCycle * w * 0.05), cy - h * 0.1,
          w * 0.15, h * 0.1),
      math.pi,
      math.pi,
      false,
      handlePaint,
    );

    // --- Arms ---
    final armPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    // Arm 1 (Opposite to Leg 1)
    final arm1X = cx - walkCycle * w * 0.1;
    canvas.drawLine(
      Offset(cx - w * 0.15, cy - h * 0.05),
      Offset(arm1X - w * 0.2, cy + h * 0.15),
      armPaint,
    );

    // Arm 2 (Holding Bag)
    canvas.drawLine(
      Offset(cx + w * 0.15, cy - h * 0.05),
      Offset(cx + w * 0.25 + (walkCycle * w * 0.05), cy + h * 0.1),
      armPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfessionalWalkerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
