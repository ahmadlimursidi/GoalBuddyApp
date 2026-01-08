import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';
import '../models/drill_animation_data.dart';

/// Widget that plays a drill animation using CustomPainter
/// This is SAFE - we only render data, never execute generated code
class DrillAnimationPlayer extends StatefulWidget {
  final DrillAnimationData animationData;
  final double width;
  final double height;

  const DrillAnimationPlayer({
    super.key,
    required this.animationData,
    this.width = 300,
    this.height = 200,
  });

  @override
  State<DrillAnimationPlayer> createState() => _DrillAnimationPlayerState();
}

class _DrillAnimationPlayerState extends State<DrillAnimationPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationData.durationMs),
      vsync: this,
    )..repeat(); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF2D5016), // Football field green
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Field markings
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: FieldPainter(),
          ),
          // Animated drill
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.width, widget.height),
                painter: DrillAnimationPainter(
                  animationData: widget.animationData,
                  progress: _controller.value,
                ),
              );
            },
          ),
          // Play/Pause button
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                _controller.isAnimating ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              onPressed: () {
                setState(() {
                  if (_controller.isAnimating) {
                    _controller.stop();
                  } else {
                    _controller.repeat();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the field background with lines
class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.15,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Main painter that renders the drill animation
/// This is the SAFE rendering engine - it only draws data, never executes code
class DrillAnimationPainter extends CustomPainter {
  final DrillAnimationData animationData;
  final double progress; // 0.0 to 1.0

  DrillAnimationPainter({
    required this.animationData,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final currentTimeMs = (progress * animationData.durationMs).toInt();

    // 1. Draw equipment (static)
    for (var equip in animationData.equipment) {
      _drawEquipment(canvas, size, equip);
    }

    // 2. Draw ball trails and current positions
    for (var ball in animationData.balls) {
      _drawBall(canvas, size, ball, currentTimeMs);
    }

    // 3. Draw player trails and current positions
    for (var player in animationData.players) {
      _drawPlayer(canvas, size, player, currentTimeMs);
    }
  }

  void _drawEquipment(Canvas canvas, Size size, Equipment equip) {
    final pos = Offset(
      equip.position.x * size.width,
      equip.position.y * size.height,
    );

    final paint = Paint()..color = _parseColor(equip.color);

    switch (equip.type.toLowerCase()) {
      case 'cone':
        // Draw triangle for cone
        final path = Path();
        path.moveTo(pos.dx, pos.dy - 8);
        path.lineTo(pos.dx - 6, pos.dy + 8);
        path.lineTo(pos.dx + 6, pos.dy + 8);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case 'goal':
        // Draw rectangle for goal
        canvas.drawRect(
          Rect.fromCenter(center: pos, width: 40, height: 20),
          paint..style = PaintingStyle.stroke..strokeWidth = 3,
        );
        break;
      default:
        // Draw circle for other equipment
        canvas.drawCircle(pos, 6, paint);
    }
  }

  void _drawBall(Canvas canvas, Size size, AnimatedBall ball, int currentTimeMs) {
    if (ball.path.isEmpty) return;

    // Draw path trail
    final trailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool first = true;
    for (var pos in ball.path) {
      final offset = Offset(pos.x * size.width, pos.y * size.height);
      if (first) {
        path.moveTo(offset.dx, offset.dy);
        first = false;
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawPath(path, trailPaint);

    // Calculate current position
    final currentPos = _interpolatePosition(ball.path, currentTimeMs);
    if (currentPos != null) {
      final offset = Offset(
        currentPos.x * size.width,
        currentPos.y * size.height,
      );

      // Draw ball
      final ballPaint = Paint()..color = Colors.white;
      canvas.drawCircle(offset, 8, ballPaint);

      // Draw ball outline
      final outlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(offset, 8, outlinePaint);
    }
  }

  void _drawPlayer(Canvas canvas, Size size, AnimatedPlayer player, int currentTimeMs) {
    if (player.path.isEmpty) return;

    final color = _parseColor(player.color);

    // Draw path trail
    final trailPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool first = true;
    for (var pos in player.path) {
      final offset = Offset(pos.x * size.width, pos.y * size.height);
      if (first) {
        path.moveTo(offset.dx, offset.dy);
        first = false;
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }

    // Draw dashed trail
    _drawDashedPath(canvas, path, trailPaint);

    // Add arrows along the path
    _drawPathArrows(canvas, size, player.path, color);

    // Calculate current position
    final currentPos = _interpolatePosition(player.path, currentTimeMs);
    if (currentPos != null) {
      final offset = Offset(
        currentPos.x * size.width,
        currentPos.y * size.height,
      );

      // Draw player circle
      final playerPaint = Paint()..color = color;
      canvas.drawCircle(offset, 12, playerPaint);

      // Draw player outline
      final outlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(offset, 12, outlinePaint);

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: player.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawPathArrows(Canvas canvas, Size size, List<Position> path, Color color) {
    if (path.length < 2) return;

    for (int i = 0; i < path.length - 1; i++) {
      final start = Offset(path[i].x * size.width, path[i].y * size.height);
      final end = Offset(path[i + 1].x * size.width, path[i + 1].y * size.height);

      // Calculate midpoint for arrow
      final mid = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      // Calculate direction
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final angle = atan2(dy, dx);

      // Draw small arrow
      final arrowPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final arrowSize = 8.0;
      final arrowPath = Path();
      arrowPath.moveTo(
        mid.dx - arrowSize * cos(angle - pi / 6),
        mid.dy - arrowSize * sin(angle - pi / 6),
      );
      arrowPath.lineTo(mid.dx, mid.dy);
      arrowPath.lineTo(
        mid.dx - arrowSize * cos(angle + pi / 6),
        mid.dy - arrowSize * sin(angle + pi / 6),
      );

      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)?.position;
        distance += dashWidth;
        final end = metric.getTangentForOffset(distance)?.position;
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
        distance += dashSpace;
      }
    }
  }

  Position? _interpolatePosition(List<Position> path, int currentTimeMs) {
    if (path.isEmpty) return null;
    if (path.length == 1) return path[0];

    // Find the two waypoints we're between
    for (int i = 0; i < path.length - 1; i++) {
      final startTime = path[i].timeMs ?? 0;
      final endTime = path[i + 1].timeMs ?? animationData.durationMs;

      if (currentTimeMs >= startTime && currentTimeMs <= endTime) {
        // Interpolate between these two points
        final segmentDuration = endTime - startTime;
        final segmentProgress = segmentDuration > 0
            ? (currentTimeMs - startTime) / segmentDuration
            : 0.0;

        return Position(
          x: path[i].x + (path[i + 1].x - path[i].x) * segmentProgress,
          y: path[i].y + (path[i + 1].y - path[i].y) * segmentProgress,
        );
      }
    }

    // If we're past all waypoints, return the last one
    return path.last;
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(DrillAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
