import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class LiquidGlassBackground extends StatefulWidget {
  const LiquidGlassBackground({super.key});

  @override
  State<LiquidGlassBackground> createState() => _LiquidGlassBackgroundState();
}

class _LiquidGlassBackgroundState extends State<LiquidGlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color(0xFF030303)),
            ),
            _buildBlob(
              top: -100 + 100 * math.sin(_controller.value * 2 * math.pi),
              left: -100 + 80 * math.cos(_controller.value * 2 * math.pi),
              color: Colors.blueAccent.withOpacity(0.4),
              size: 500,
            ),
            _buildBlob(
              bottom: -150 + 120 * math.cos(_controller.value * 2 * math.pi),
              right: -100 + 100 * math.sin(_controller.value * 2 * math.pi),
              color: Colors.purpleAccent.withOpacity(0.3),
              size: 600,
            ),
            _buildBlob(
              top: 300 + 150 * math.sin(_controller.value * 1.5 * math.pi),
              left: 200 + 100 * math.cos(_controller.value * 1.8 * math.pi),
              color: Colors.tealAccent.withOpacity(0.2),
              size: 400,
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlob({
    double? top,
    double? left,
    double? bottom,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
