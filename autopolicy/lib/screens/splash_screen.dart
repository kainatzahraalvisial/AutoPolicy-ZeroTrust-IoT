import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'login_screen.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  // High-precision timeline intervals
  late final Animation<double> _mazeBuildAnimation;
  late final Animation<double> _mazeScatterAnimation;
  late final Animation<double> _mazeOpacityAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // 1. Circuit maze grows from 0.0 to 1.0
    _mazeBuildAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
    );

    // 2. Scatter progress goes from 0.0 to 1.0
    _mazeScatterAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 1.0, curve: Curves.fastOutSlowIn),
    );

    // 3. Motherboard opacity fades out during scatter
    _mazeOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    // 4. Logo scale goes from 0.2 to 1.0 with a nice elastic zoom bounce (Timeline: 0.50 -> 0.78 = 1.96s)
    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.78, curve: Curves.easeOutBack),
      ),
    );

    // 5. Logo opacity goes from 0.0 to 1.0 (Timeline: 0.50 -> 0.70 = 1.40s)
    _logoOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.70, curve: Curves.easeIn),
    );

    // Rebuild the UI on every tick of the animation controller
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Auto navigate on completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToLogin();
      }
    });

    _controller.forward();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _controller.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Render custom animated motherboard circuitry grid
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SplashCircuitPainter(
                  progress: _mazeBuildAnimation.value,
                  isScattered: progress > 0.50,
                  scatterProgress: _mazeScatterAnimation.value,
                  opacity: _mazeOpacityAnimation.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data models for procedural stable generation of motherboard circuits
class _CircuitTrace {
  final double x1, y1, x2, y2;
  final bool isVertical;
  final double speed;
  final double offset;
  final bool isMajor;
  final bool hasNodeCircle;
  final bool isDiagonal;

  _CircuitTrace({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.isVertical,
    required this.speed,
    required this.offset,
    required this.isMajor,
    this.hasNodeCircle = false,
    this.isDiagonal = false,
  });
}

class _CircuitComponent {
  final double x, y;
  final double width, height;
  final bool isGlowing;
  final int type;

  _CircuitComponent({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isGlowing,
    required this.type,
  });
}

class _CircuitGrid {
  final double x, y;
  final int rows, cols;

  _CircuitGrid({
    required this.x,
    required this.y,
    required this.rows,
    required this.cols,
  });
}

// Custom Painter: Renders an ultra-high tech blue motherboard schematic (vertical trace channels, pulsing components, core CPU)
class _SplashCircuitPainter extends CustomPainter {
  final double progress;
  final bool isScattered;
  final double scatterProgress;
  final double opacity;
  
  final List<_CircuitTrace> traces = [];
  final List<_CircuitComponent> components = [];
  final List<_CircuitGrid> grids = [];
  
  final Color neonBlue = const Color(0xFF80A416); // Olive green trace
  final Color neonLime = const Color(0xFFC5C764); // Lime gold trace
  final Color brightLime = const Color(0xFFBBF438); // Bright neon lime trace
  
  _SplashCircuitPainter({
    required this.progress,
    required this.isScattered,
    required this.scatterProgress,
    required this.opacity,
  }) {
    _generateMotherboard();
  }

  void _generateMotherboard() {
    final rand = Random(77); // Seeded for a balanced, reproducible schematic layout
    
    // 1. Generate motherboard trace channels (mostly vertical traces like a mobile motherboard)
    // Vertical traces
    for (int i = 0; i < 35; i++) {
      final double rx = rand.nextDouble() * 2.0 - 1.0;
      final double ry1 = rand.nextDouble() * 2.0 - 1.0;
      final double ry2 = ry1 + (rand.nextDouble() * 0.6 + 0.3);
      final bool hasCircle = rand.nextDouble() > 0.55;
      traces.add(_CircuitTrace(
        x1: rx, y1: ry1,
        x2: rx, y2: ry2.clamp(-1.0, 1.0),
        isVertical: true,
        speed: rand.nextDouble() * 1.6 + 0.8,
        offset: rand.nextDouble(),
        isMajor: rand.nextDouble() > 0.75,
        hasNodeCircle: hasCircle,
      ));
    }
    
    // High-speed parallel memory lines (RAM slots representation - 3 parallel vertical lines close together)
    for (int group = 0; group < 3; group++) {
      final double startX = -0.75 + (group * 0.7) + rand.nextDouble() * 0.05;
      final double startY = -0.85 + rand.nextDouble() * 0.2;
      final double length = 0.55 + rand.nextDouble() * 0.25;
      final double speed = 1.3 + rand.nextDouble() * 0.4;
      for (int line = 0; line < 3; line++) {
        final double x = startX + (line * 0.022);
        traces.add(_CircuitTrace(
          x1: x, y1: startY,
          x2: x, y2: startY + length,
          isVertical: true,
          speed: speed,
          offset: group * 0.2 + line * 0.05,
          isMajor: false,
          hasNodeCircle: line == 1,
        ));
      }
    }
    
    // Diagonal traces representing 45-degree bends
    for (int i = 0; i < 15; i++) {
      final double rx = rand.nextDouble() * 1.6 - 0.8;
      final double ry = rand.nextDouble() * 1.6 - 0.8;
      final double length = rand.nextDouble() * 0.14 + 0.07;
      final double direction = rand.nextBool() ? 1.0 : -1.0; // Left-up/right-down
      traces.add(_CircuitTrace(
        x1: rx, y1: ry,
        x2: rx + length * direction, y2: ry + length,
        isVertical: false,
        speed: rand.nextDouble() * 1.4 + 0.8,
        offset: rand.nextDouble(),
        isMajor: rand.nextDouble() > 0.7,
        isDiagonal: true,
        hasNodeCircle: rand.nextDouble() > 0.5,
      ));
    }
    
    // Horizontal connecting buses
    for (int i = 0; i < 20; i++) {
      final double ry = rand.nextDouble() * 2.0 - 1.0;
      final double rx1 = rand.nextDouble() * 2.0 - 1.0;
      final double rx2 = rx1 + (rand.nextDouble() * 0.45 + 0.15);
      traces.add(_CircuitTrace(
        x1: rx1, y1: ry,
        x2: rx2.clamp(-1.0, 1.0), y2: ry,
        isVertical: false,
        speed: rand.nextDouble() * 1.6 + 0.8,
        offset: rand.nextDouble(),
        isMajor: false,
      ));
    }
    
    // 2. Generate detailed electronic components (Capacitors, microchips, RAM blocks)
    for (int i = 0; i < 22; i++) {
      components.add(_CircuitComponent(
        x: rand.nextDouble() * 1.8 - 0.9,
        y: rand.nextDouble() * 1.8 - 0.9,
        width: rand.nextDouble() * 36.0 + 14.0,
        height: rand.nextDouble() * 28.0 + 10.0,
        isGlowing: rand.nextDouble() > 0.5,
        type: rand.nextInt(3), // 0: outlined, 1: filled capacitor, 2: technical slot
      ));
    }
    
    // 3. Generate small chip pin arrays (dotted registers)
    for (int i = 0; i < 6; i++) {
      grids.add(_CircuitGrid(
        x: rand.nextDouble() * 1.6 - 0.8,
        y: rand.nextDouble() * 1.6 - 0.8,
        rows: rand.nextInt(3) + 2,
        cols: rand.nextInt(3) + 2,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = min(size.width, size.height) * 0.55;

    final double activeProgress = min(1.0, max(0.0, progress));
    final double activeScatter = isScattered ? min(1.0, max(0.0, scatterProgress)) : 0.0;

    // 1. Paint all circuit traces (double layer glowing lines + moving white packet dots)
    for (final trace in traces) {
      final double sx = center.dx + (trace.x1 * maxRadius);
      final double sy = center.dy + (trace.y1 * maxRadius);
      final double ex = center.dx + (trace.x2 * maxRadius);
      final double ey = center.dy + (trace.y2 * maxRadius);
      
      double scatterX1 = 0.0, scatterY1 = 0.0;
      double scatterX2 = 0.0, scatterY2 = 0.0;
      if (isScattered) {
        // Radial blast force
        final double a1 = atan2(trace.y1, trace.x1);
        final double a2 = atan2(trace.y2, trace.x2);
        final double force = 350.0 * activeScatter;
        scatterX1 = cos(a1) * force;
        scatterY1 = sin(a1) * force;
        scatterX2 = cos(a2) * force;
        scatterY2 = sin(a2) * force;
      }
      
      final Offset p1 = Offset(sx + scatterX1, sy + scatterY1);
      final Offset p2 = Offset(ex + scatterX2, ey + scatterY2);
      
      final double startDistance = sqrt(trace.x1 * trace.x1 + trace.y1 * trace.y1) / sqrt(2.0);
      if (activeProgress >= startDistance * 0.7) {
        final double lineProgress = ((activeProgress - startDistance * 0.7) / 0.3).clamp(0.0, 1.0);
        final Offset currentEnd = Offset(
          p1.dx + (p2.dx - p1.dx) * lineProgress,
          p1.dy + (p2.dy - p1.dy) * lineProgress,
        );
        
        final double lineAlpha = (1.0 - activeScatter) * opacity;
        final Color themeColor = trace.isMajor ? brightLime : neonBlue;
        
        // Double paint technique for glowing neon vector trace
        final widePaint = Paint()
          ..color = themeColor.withOpacity(0.09 * lineAlpha)
          ..strokeWidth = trace.isMajor ? 4.5 : (trace.isDiagonal ? 1.5 : 2.5)
          ..style = PaintingStyle.stroke;
          
        final sharpPaint = Paint()
          ..color = themeColor.withOpacity(0.4 * lineAlpha)
          ..strokeWidth = trace.isMajor ? 1.2 : (trace.isDiagonal ? 0.5 : 0.7)
          ..style = PaintingStyle.stroke;
          
        canvas.drawLine(p1, currentEnd, widePaint);
        canvas.drawLine(p1, currentEnd, sharpPaint);
        
        // Render hollow terminal circles at endpoints (holographic node points)
        if (trace.hasNodeCircle && lineProgress >= 0.95 && !isScattered) {
          final circlePaint = Paint()
            ..color = themeColor.withOpacity(0.7 * lineAlpha)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;
          final circleGlow = Paint()
            ..color = themeColor.withOpacity(0.2 * lineAlpha)
            ..style = PaintingStyle.fill;
          
          canvas.drawCircle(p2, 3.2, circleGlow);
          canvas.drawCircle(p2, 2.5, circlePaint);
        }
        
        // Render flow signals (glowing dots traveling down the buses)
        if (lineProgress > 0.2 && !isScattered) {
          final double dotProgress = (progress * trace.speed + trace.offset) % 1.0;
          final Offset dotPos = Offset(
            p1.dx + (p2.dx - p1.dx) * dotProgress * lineProgress,
            p1.dy + (p2.dy - p1.dy) * dotProgress * lineProgress,
          );
          
          final dotPaint = Paint()
            ..color = Colors.white.withOpacity(0.9 * opacity)
            ..style = PaintingStyle.fill;
            
          final dotGlow = Paint()
            ..color = neonLime.withOpacity(0.4 * opacity)
            ..style = PaintingStyle.fill;
            
          canvas.drawCircle(dotPos, 4.0, dotGlow);
          canvas.drawCircle(dotPos, 1.5, dotPaint);
        }
      }
    }

    // 2. Paint electronic capacitors & detailed component outlines
    for (final comp in components) {
      final double sx = center.dx + (comp.x * maxRadius);
      final double sy = center.dy + (comp.y * maxRadius);
      
      double scatterX = 0.0, scatterY = 0.0;
      if (isScattered) {
        final double angle = atan2(comp.y, comp.x);
        scatterX = cos(angle) * 350.0 * activeScatter;
        scatterY = sin(angle) * 350.0 * activeScatter;
      }
      
      final Offset pos = Offset(sx + scatterX, sy + scatterY);
      final Rect rect = Rect.fromCenter(center: pos, width: comp.width, height: comp.height);
      
      final double startDistance = sqrt(comp.x * comp.x + comp.y * comp.y) / sqrt(2.0);
      if (activeProgress >= startDistance * 0.7) {
        final double fadeAlpha = ((activeProgress - startDistance * 0.7) / 0.2).clamp(0.0, 1.0) * (1.0 - activeScatter) * opacity;
        
        // Outlined silicon chips
        if (comp.type == 0) {
          final outlinePaint = Paint()
            ..color = CyberColors.neonCyan.withOpacity(0.3 * fadeAlpha)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;
          canvas.drawRect(rect, outlinePaint);
        }
        // Filled capacitors (light transparent glow inside)
        else if (comp.type == 1) {
          final fillPaint = Paint()
            ..color = neonBlue.withOpacity(0.05 * fadeAlpha)
            ..style = PaintingStyle.fill;
          final borderPaint = Paint()
            ..color = neonBlue.withOpacity(0.25 * fadeAlpha)
            ..strokeWidth = 0.6
            ..style = PaintingStyle.stroke;
            
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, borderPaint);
        }
        // Technical slots with detailed diagonals
        else if (comp.type == 2) {
          final borderPaint = Paint()
            ..color = CyberColors.neonCyan.withOpacity(0.2 * fadeAlpha)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;
          canvas.drawRect(rect, borderPaint);
          canvas.drawLine(rect.topLeft, rect.bottomRight, borderPaint);
        }
        
        // Breathing electrical pulse indicator
        if (comp.isGlowing && !isScattered) {
          final double pulse = 0.5 + 0.5 * sin(progress * pi * 5 + comp.x * 10.0);
          final pulsePaint = Paint()
            ..color = CyberColors.neonCyan.withOpacity(0.14 * pulse * fadeAlpha)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect.deflate(1.5), pulsePaint);
        }
      }
    }

    // 3. Paint dotted pins grids
    for (final grid in grids) {
      final double sx = center.dx + (grid.x * maxRadius);
      final double sy = center.dy + (grid.y * maxRadius);
      
      double scatterX = 0.0, scatterY = 0.0;
      if (isScattered) {
        final double angle = atan2(grid.y, grid.x);
        scatterX = cos(angle) * 350.0 * activeScatter;
        scatterY = sin(angle) * 350.0 * activeScatter;
      }
      
      final double startDistance = sqrt(grid.x * grid.x + grid.y * grid.y) / sqrt(2.0);
      if (activeProgress >= startDistance * 0.7) {
        final double fadeAlpha = ((activeProgress - startDistance * 0.7) / 0.2).clamp(0.0, 1.0) * (1.0 - activeScatter) * opacity;
        final dotPaint = Paint()
          ..color = CyberColors.neonCyan.withOpacity(0.4 * fadeAlpha)
          ..style = PaintingStyle.fill;
          
        const double dotSpacing = 6.0;
        for (int r = 0; r < grid.rows; r++) {
          for (int c = 0; c < grid.cols; c++) {
            final Offset dotPos = Offset(
              sx + scatterX + (c - grid.cols / 2) * dotSpacing,
              sy + scatterY + (r - grid.rows / 2) * dotSpacing,
            );
            canvas.drawCircle(dotPos, 1.0, dotPaint);
          }
        }
      }
    }

    // Bottom-right custom hardware branding module (emulating the emblem in the user's reference image)
    final double brandX = center.dx + (0.45 * maxRadius);
    final double brandY = center.dy + (0.55 * maxRadius);
    double brandScatterX = 0.0, brandScatterY = 0.0;
    if (isScattered) {
      final double angle = atan2(0.55, 0.45);
      brandScatterX = cos(angle) * 350.0 * activeScatter;
      brandScatterY = sin(angle) * 350.0 * activeScatter;
    }
    final Offset brandPos = Offset(brandX + brandScatterX, brandY + brandScatterY);
    if (activeProgress >= 0.4) {
      final double brandAlpha = ((activeProgress - 0.4) / 0.3).clamp(0.0, 1.0) * (1.0 - activeScatter) * opacity;
      
      final brandPaint = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.08 * brandAlpha)
        ..style = PaintingStyle.fill;
      final brandBorder = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.6 * brandAlpha)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
        
      final Rect brandRect = Rect.fromCenter(center: brandPos, width: 34, height: 34);
      canvas.drawRRect(RRect.fromRectAndRadius(brandRect, const Radius.circular(4)), brandPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(brandRect, const Radius.circular(4)), brandBorder);
      
      // Draw a tiny grid of 2x2 dots inside
      final dotPaint = Paint()
        ..color = Colors.white.withOpacity(0.8 * brandAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(brandPos.dx - 6, brandPos.dy - 6), 1.2, dotPaint);
      canvas.drawCircle(Offset(brandPos.dx + 6, brandPos.dy - 6), 1.2, dotPaint);
      canvas.drawCircle(Offset(brandPos.dx - 6, brandPos.dy + 6), 1.2, dotPaint);
      canvas.drawCircle(Offset(brandPos.dx + 6, brandPos.dy + 6), 1.2, dotPaint);
      
      // Draw a micro label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: "AP-88",
          style: TextStyle(
            color: CyberColors.neonCyan.withOpacity(0.7 * brandAlpha),
            fontSize: 5.5,
            fontWeight: FontWeight.w900,
            fontFamily: 'Courier',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(brandPos.dx - 8.5, brandPos.dy - 2.5));
    }

    // 4. Paint the gorgeous central microchip CPU & concentric rotating lock arcs
    final double cpuSize = 80.0;
    double cpuScatterX = 0.0, cpuScatterY = 0.0;
    if (isScattered) {
      cpuScatterY = 150.0 * activeScatter; // Core CPU flies downward dynamically
    }
    
    final Offset cpuPos = Offset(center.dx + cpuScatterX, center.dy + cpuScatterY);
    final Rect cpuRect = Rect.fromCenter(center: cpuPos, width: cpuSize, height: cpuSize);
    
    if (activeProgress >= 0.1) {
      final double cpuAlpha = ((activeProgress - 0.1) / 0.3).clamp(0.0, 1.0) * (1.0 - activeScatter) * opacity;
      
      // Layered concentric radar rings surrounding the core silicon processor
      final double hudRadius1 = 58.0;
      final double hudRadius2 = 68.0;
      final double hudRadius3 = 76.0;
      
      final hudPaint1 = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.2 * cpuAlpha)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      final hudPaint2 = Paint()
        ..color = neonBlue.withOpacity(0.15 * cpuAlpha)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
        
      // Outer HUD ring (Dashed - clockwise)
      final double rot = progress * pi * 0.8;
      for (int i = 0; i < 4; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: cpuPos, radius: hudRadius1),
          (i * pi / 2) + rot + 0.1,
          (pi / 2) - 0.2,
          false,
          hudPaint1,
        );
      }
      
      // Middle HUD ring (Dashed - counter-clockwise)
      for (int i = 0; i < 8; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: cpuPos, radius: hudRadius2),
          (i * pi / 4) - (rot * 0.6) + 0.05,
          (pi / 4) - 0.1,
          false,
          hudPaint2,
        );
      }
      
      // Inner thin circular trace ring
      canvas.drawCircle(cpuPos, hudRadius3, Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.08 * cpuAlpha)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke);

      // Outer outer dashed target lock ring (hudRadius4 - 12 short ticks)
      final double hudRadius4 = 86.0;
      final hudPaint4 = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.12 * cpuAlpha)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 12; i++) {
        final double angle = (i * pi / 6) + (rot * 0.3);
        final double startX = cpuPos.dx + cos(angle) * (hudRadius4 - 3);
        final double startY = cpuPos.dy + sin(angle) * (hudRadius4 - 3);
        final double endX = cpuPos.dx + cos(angle) * (hudRadius4 + 3);
        final double endY = cpuPos.dy + sin(angle) * (hudRadius4 + 3);
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), hudPaint4);
      }

      // CPU silicon body drawing
      final cpuFill = Paint()
        ..color = Colors.black.withOpacity(cpuAlpha)
        ..style = PaintingStyle.fill;
      final cpuGlow = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.12 * cpuAlpha)
        ..style = PaintingStyle.fill;
      final cpuBorder = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.55 * cpuAlpha)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
        
      canvas.drawRect(cpuRect, cpuFill);
      canvas.drawRect(cpuRect.inflate(2.0), cpuGlow);
      canvas.drawRect(cpuRect, cpuBorder);
      
      // Inner CPU circuits
      final innerRect = cpuRect.deflate(10.0);
      canvas.drawRect(innerRect, Paint()
        ..color = neonBlue.withOpacity(0.2 * cpuAlpha)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke);
        
      // Central silicon core square
      canvas.drawRect(Rect.fromCenter(center: cpuPos, width: 22, height: 22), Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.3 * cpuAlpha)
        ..style = PaintingStyle.fill);
        
      // Draw standard CPU pin routes (legs) extending outward
      final pinPaint = Paint()
        ..color = CyberColors.neonCyan.withOpacity(0.55 * cpuAlpha)
        ..strokeWidth = 1.0;
        
      const int pinsPerSide = 6;
      const double pinSpacing = 10.0;
      final double pinLength = 8.0;
      
      for (int i = 0; i < pinsPerSide; i++) {
        final double offset = (i - (pinsPerSide - 1) / 2) * pinSpacing;
        
        // Left side pins
        canvas.drawLine(Offset(cpuRect.left, cpuPos.dy + offset), Offset(cpuRect.left - pinLength, cpuPos.dy + offset), pinPaint);
        // Right side pins
        canvas.drawLine(Offset(cpuRect.right, cpuPos.dy + offset), Offset(cpuRect.right + pinLength, cpuPos.dy + offset), pinPaint);
        // Top side pins
        canvas.drawLine(Offset(cpuPos.dx + offset, cpuRect.top), Offset(cpuPos.dx + offset, cpuRect.top - pinLength), pinPaint);
        // Bottom side pins
        canvas.drawLine(Offset(cpuPos.dx + offset, cpuRect.bottom), Offset(cpuPos.dx + offset, cpuRect.bottom + pinLength), pinPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashCircuitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isScattered != isScattered ||
        oldDelegate.scatterProgress != scatterProgress ||
        oldDelegate.opacity != opacity;
  }
}
