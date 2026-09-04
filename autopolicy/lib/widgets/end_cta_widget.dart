import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chamfered_cyber_button.dart';
import '../screens/login_screen.dart';

class EndCtaWidget extends StatefulWidget {
  final bool isActive;
  const EndCtaWidget({super.key, required this.isActive});

  @override
  State<EndCtaWidget> createState() => _EndCtaWidgetState();
}

class _EndCtaWidgetState extends State<EndCtaWidget> {
  static const String fullText =
      'Open-source, AI-driven zero-trust framework for resource-constrained IoT networks.';
  String _typedText = '';
  Timer? _typeTimer;
  bool _isTypingDone = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(covariant EndCtaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startTyping();
    } else if (!widget.isActive) {
      _resetTyping();
    }
  }

  void _resetTyping() {
    _typeTimer?.cancel();
    _typeTimer = null;
    setState(() {
      _typedText = '';
      _isTypingDone = false;
      _showButtons = false;
    });
  }

  void _startTyping() {
    _resetTyping();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted || !widget.isActive) return;
      int charIdx = 0;
      _typeTimer = Timer.periodic(const Duration(milliseconds: 28), (timer) {
        if (!mounted || !widget.isActive) {
          timer.cancel();
          return;
        }
        charIdx++;
        if (charIdx <= fullText.length) {
          setState(() {
            _typedText = fullText.substring(0, charIdx);
          });
        } else {
          timer.cancel();
          setState(() {
            _isTypingDone = true;
            _showButtons = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 960;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // 1. Bottom-Up Linear Green Gradient (matching .bg-gradient-bottom to top)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x8C08652C), // 0.55 forest green at bottom
                    Color(0x59032820), // 0.35 dark emerald at 28%
                    Colors.black,      // transparent/black at top 65%
                  ],
                  stops: [0.0, 0.28, 0.65],
                ),
              ),
            ),
          ),

          // Bottom Radial Glow Overlay (matching radial-gradient at 40% 110% and 70% 100%)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.2, 1.2),
                  radius: 0.9,
                  colors: [
                    Color(0x6680A416),
                    Color(0x59BBF438),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 0.85],
                ),
              ),
            ),
          ),

          // 2. Cyber Tile Grid Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),

          // 3. Central Content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 720),
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // H1 Slide Titles (Line 1 from left, Line 2 from right)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 900),
                    curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                    opacity: widget.isActive ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 900),
                      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                      transform: widget.isActive
                          ? Matrix4.identity()
                          : (Matrix4.identity()..translate(-48.0, 0.0, 0.0)),
                      child: Text(
                        'Automated security.',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 52 : 32,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                          color: const Color(0xFFEDF5EB),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 900),
                    curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                    opacity: widget.isActive ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 900),
                      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                      transform: widget.isActive
                          ? Matrix4.identity()
                          : (Matrix4.identity()..translate(48.0, 0.0, 0.0)),
                      child: Text(
                        'From the ground up.',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 52 : 32,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                          color: const Color(0xFFC5C764),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Typewriter Subtitle
                  Container(
                    constraints: const BoxConstraints(minHeight: 56, maxWidth: 520),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w300,
                          height: 1.75,
                          color: const Color(0xFF829A80),
                        ),
                        children: [
                          TextSpan(text: _typedText),
                          if (!_isTypingDone)
                            TextSpan(
                              text: ' |',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFC5C764),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Action Buttons (CREATE ACCOUNT & SIGN IN)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOut,
                    opacity: _showButtons ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 750),
                      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                      transform: _showButtons
                          ? Matrix4.identity()
                          : (Matrix4.identity()..translate(0.0, 24.0, 0.0)),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          ChamferedCyberButton(
                            text: 'CREATE ACCOUNT',
                            onTap: _navigateToLogin,
                          ),
                          _GhostCyberButton(
                            text: 'SIGN IN',
                            onTap: _navigateToLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. End Footer
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: widget.isActive ? 1.0 : 0.0,
              child: Column(
                children: [
                  Text(
                    'AUTOPOLICY',
                    style: GoogleFonts.orbitron(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.5,
                      color: const Color(0xFFEDF5EB),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ZERO TRUST · IOT SECURITY · AUTOMATED ENFORCEMENT\n© 2025 AUTOPOLICY',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.2,
                      height: 1.7,
                      color: const Color(0xFF829A80),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostCyberButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _GhostCyberButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_GhostCyberButton> createState() => _GhostCyberButtonState();
}

class _GhostCyberButtonState extends State<_GhostCyberButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          child: ClipPath(
            clipper: ChamferedClipper(chamfer: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFF80A416).withOpacity(0.18)
                    : const Color(0xFF08140C).withOpacity(0.85),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFC5C764)
                      : const Color(0xFF80A416).withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Text(
                widget.text,
                style: GoogleFonts.orbitron(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: const Color(0xFFC5C764),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF80A416).withOpacity(0.12)
      ..strokeWidth = 1.0;

    const double spacing = 52.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
