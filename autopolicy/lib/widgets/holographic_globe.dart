import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';

class HolographicGlobe extends ConsumerStatefulWidget {
  final double size;
  const HolographicGlobe({super.key, this.size = 280.0});

  @override
  ConsumerState<HolographicGlobe> createState() => _HolographicGlobeState();
}

class _HolographicGlobeState extends ConsumerState<HolographicGlobe> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragYaw = 0.0;
  double _dragPitch = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    return RepaintBoundary(
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dragYaw += details.delta.dx * 0.01;
            _dragPitch -= details.delta.dy * 0.01;
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double baseYaw = _controller.value * 2 * pi;
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _Globe3DPainter(
                yaw: baseYaw + _dragYaw,
                pitch: _dragPitch + 0.3, // slight tilt
                isDarkMode: isDarkMode,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GlobePoint {
  final double x, y, z;
  const _GlobePoint(this.x, this.y, this.z);

  _GlobePoint rotateY(double angle) {
    final double cosA = cos(angle);
    final double sinA = sin(angle);
    return _GlobePoint(
      x * cosA - z * sinA,
      y,
      x * sinA + z * cosA,
    );
  }

  _GlobePoint rotateX(double angle) {
    final double cosA = cos(angle);
    final double sinA = sin(angle);
    return _GlobePoint(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }
}

class _Globe3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final bool isDarkMode;
  final List<_GlobePoint> _globePoints = [];
  final List<List<int>> _latRings = [];

  _Globe3DPainter({required this.yaw, required this.pitch, required this.isDarkMode}) {
    _generateSpherePoints();
  }

  // Generates coordinate vertices for latitude and longitude grids
  void _generateSpherePoints() {
    const int latCount = 9;
    const int lonCount = 18;

    for (int lat = 1; lat < latCount; lat++) {
      final double phi = (lat * pi) / latCount;
      final ringIndex = <int>[];
      
      for (int lon = 0; lon < lonCount; lon++) {
        final double theta = (lon * 2 * pi) / lonCount;
        
        final double x = sin(phi) * cos(theta);
        final double y = cos(phi);
        final double z = sin(phi) * sin(theta);
        
        _globePoints.add(_GlobePoint(x, y, z));
        ringIndex.add(_globePoints.length - 1);
      }
      _latRings.add(ringIndex);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10.0;

    // Draw outer technical holographic targeting rings
    final hudPaint = Paint()
      ..color = isDarkMode 
          ? CyberColors.neonCyan.withOpacity(0.1) 
          : const Color(0xFF6D28D9).withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius + 8.0, hudPaint);
    canvas.drawCircle(center, radius + 4.0, hudPaint);
    
    // Draw fine ticks on the outer boundary ring
    final tickPaint = Paint()
      ..color = isDarkMode 
          ? CyberColors.neonCyan.withOpacity(0.3) 
          : const Color(0xFF6D28D9).withOpacity(0.3)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 8; i++) {
      final double angle = (i * pi) / 4;
      final start = Offset(center.dx + cos(angle) * (radius + 2), center.dy + sin(angle) * (radius + 2));
      final end = Offset(center.dx + cos(angle) * (radius + 8), center.dy + sin(angle) * (radius + 8));
      canvas.drawLine(start, end, tickPaint);
    }

    final frontPaint = Paint()
      ..color = isDarkMode 
          ? CyberColors.neonCyan.withOpacity(0.4) 
          : const Color(0xFF6D28D9).withOpacity(0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final backPaint = Paint()
      ..color = isDarkMode 
          ? CyberColors.neonCyan.withOpacity(0.08) 
          : const Color(0xFF6D28D9).withOpacity(0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Rotate and project points
    final projected = _globePoints.map((pt) {
      final rotated = pt.rotateY(yaw).rotateX(pitch);
      final screenX = center.dx + rotated.x * radius;
      final screenY = center.dy + rotated.y * radius;
      return {'offset': Offset(screenX, screenY), 'z': rotated.z};
    }).toList();

    // 1. Draw Latitudinal rings (horizontal)
    for (final ring in _latRings) {
      for (int i = 0; i < ring.length; i++) {
        final int i1 = ring[i];
        final int i2 = ring[(i + 1) % ring.length];
        
        final pt1 = projected[i1];
        final pt2 = projected[i2];
        
        final double avgZ = ((pt1['z'] as double) + (pt2['z'] as double)) / 2;
        
        // Split front and back for high-fidelity 3D depth illusion
        if (avgZ > 0) {
          canvas.drawLine(pt1['offset'] as Offset, pt2['offset'] as Offset, frontPaint);
        } else {
          canvas.drawLine(pt1['offset'] as Offset, pt2['offset'] as Offset, backPaint);
        }
      }
    }

    // 2. Draw Longitudinal lines (vertical arches connecting poles)
    final int lonCount = 18;
    final int latRingsCount = _latRings.length;
    for (int lon = 0; lon < lonCount; lon++) {
      for (int lat = 0; lat < latRingsCount - 1; lat++) {
        final int i1 = _latRings[lat][lon];
        final int i2 = _latRings[lat + 1][lon];

        final pt1 = projected[i1];
        final pt2 = projected[i2];

        final double avgZ = ((pt1['z'] as double) + (pt2['z'] as double)) / 2;

        if (avgZ > 0) {
          canvas.drawLine(pt1['offset'] as Offset, pt2['offset'] as Offset, frontPaint);
        } else {
          canvas.drawLine(pt1['offset'] as Offset, pt2['offset'] as Offset, backPaint);
        }
      }
    }

    // 3. Draw simulated pulsing cyber connection nodes on the surface
    final nodePaint = Paint()
      ..color = isDarkMode ? CyberColors.neonGreen : const Color(0xFF8B5CF6)
      ..style = PaintingStyle.fill;
    
    // Pick 3 arbitrary surface points
    final nodeIndices = [12, 45, 82];
    for (final idx in nodeIndices) {
      if (idx < projected.length) {
        final node = projected[idx];
        final double zVal = node['z'] as double;
        if (zVal > 0) {
          final Offset pos = node['offset'] as Offset;
          // Draw pulsing outer glow circle
          canvas.drawCircle(
            pos, 
            5 + sin(yaw * 4) * 2, 
            Paint()..color = (isDarkMode ? CyberColors.neonGreen : const Color(0xFF8B5CF6)).withOpacity(0.25)
          );
          canvas.drawCircle(pos, 3, nodePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Globe3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw || oldDelegate.pitch != pitch || oldDelegate.isDarkMode != isDarkMode;
  }
}
