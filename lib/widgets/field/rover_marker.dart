import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';

/// Custom rover marker widget for the field map.
class RoverMarker extends StatelessWidget {
  final Offset position;
  final double directionDegrees;

  const RoverMarker({
    super.key,
    required this.position,
    this.directionDegrees = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 12,
      top: position.dy - 12,
      child: Transform.rotate(
        angle: directionDegrees * 3.14159 / 180,
        child: CustomPaint(
          size: const Size(24, 24),
          painter: _RoverMarkerPainter(),
        ),
      ),
    );
  }
}

class _RoverMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.7);
    path.lineTo(0, size.height);
    path.close();

    // Drop shadow
    canvas.drawShadow(path, Colors.black, 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
