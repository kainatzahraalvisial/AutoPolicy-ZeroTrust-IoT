import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/three_particle_canvas.dart';
import '../widgets/pipeline_stage_widget.dart';
import '../widgets/cyber_hud_card.dart';
import '../widgets/end_cta_widget.dart';
import '../widgets/chamfered_cyber_button.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _currentPage = 0;
  bool _isTransitioning = false;
  bool _wheelLock = false;
  Offset _globalMousePos = const Offset(-9999, -9999);

  void _goToPage(int index) {
    if (index < 0 || index > 3 || index == _currentPage || _isTransitioning) return;

    setState(() {
      _isTransitioning = true;
      _currentPage = index;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  void _handleWheel(PointerScrollEvent event) {
    if (_wheelLock || _isTransitioning) return;
    if (event.scrollDelta.dy.abs() < 20) return;

    _wheelLock = true;
    if (event.scrollDelta.dy > 0) {
      _goToPage((_currentPage + 1).clamp(0, 3));
    } else {
      _goToPage((_currentPage - 1).clamp(0, 3));
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      _wheelLock = false;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
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
    final bool isFullDarkPage = _currentPage >= 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _globalMousePos = event.localPosition;
          });
        },
        onExit: (event) {
          setState(() {
            _globalMousePos = const Offset(-9999, -9999);
          });
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (event) {
            setState(() {
              _globalMousePos = event.localPosition;
            });
          },
          onPointerMove: (event) {
            setState(() {
              _globalMousePos = event.localPosition;
            });
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleWheel(event);
            }
          },
          child: Stack(
          children: [
            // 1. Full-Screen Interactive WebGL/3D Particle Background (Fades out on full dark pages)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isFullDarkPage ? 0.0 : 1.0,
                child: ThreeParticleCanvas(mousePos: _globalMousePos),
              ),
            ),

            // 2. Left Vertical Margin Pill & Accent Bar (Fades out on full dark pages)
            if (isDesktop) ...[
              Positioned(
                left: 24,
                top: 24,
                bottom: 24,
                width: 54,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFullDarkPage ? 0.0 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF80A416),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF80A416).withOpacity(0.45),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 38),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'AUTOPOLICY',
                            style: GoogleFonts.orbitron(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 90,
                          color: Colors.black.withOpacity(0.85),
                        ),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'AUTOPOLICY',
                            style: GoogleFonts.orbitron(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 86,
                bottom: 24,
                width: 18,
                height: 120,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFullDarkPage ? 0.0 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF80A416),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF80A416).withOpacity(0.35),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 2,
                      height: 72,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],

            // 3. Top Navigation Bar
            Positioned(
              top: 0,
              left: (isDesktop && !isFullDarkPage) ? 120 : 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: EdgeInsets.fromLTRB(
                  (isDesktop && !isFullDarkPage) ? 20 : 36,
                  26,
                  isDesktop ? 60 : 24,
                  24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFBBF438),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFBBF438).withOpacity(0.9),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AutoPolicy',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.8,
                            color: const Color(0xFFEDF5EB),
                          ),
                        ),
                      ],
                    ),

                    // Nav Links
                    if (isDesktop)
                      Row(
                        children: [
                          _HoverNavLink(
                            title: 'EXPLORE',
                            isActive: _currentPage == 0,
                            onTap: () => _goToPage(0),
                          ),
                          const SizedBox(width: 40),
                          _HoverNavLink(
                            title: 'PIPELINE',
                            isActive: _currentPage == 1,
                            onTap: () => _goToPage(1),
                          ),
                          const SizedBox(width: 40),
                          _HoverNavLink(
                            title: 'SYSTEM',
                            isActive: _currentPage == 2,
                            onTap: () => _goToPage(2),
                          ),
                        ],
                      ),

                    // Login Action Button
                    _NavLoginButton(onTap: _navigateToLogin),
                  ],
                ),
              ),
            ),

            // 4. Fixed Scenes (Hero, Pipeline Stage, System Specs, End CTA)
            Positioned(
              top: 0,
              bottom: 0,
              left: (isDesktop && !isFullDarkPage) ? 120 : 0,
              right: 0,
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildHeroPage(context, isDesktop),
                  PipelinePage(isActive: _currentPage == 1),
                  _buildSystemSpecsPage(context, isDesktop),
                  EndCtaWidget(isActive: _currentPage == 3),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Section 0: Hero
  Widget _buildHeroPage(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 2,
                    color: const Color(0xFF80A416),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'ANOMALY DETECTION · ZERO TRUST · POLICY AUTOMATION',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.5,
                      color: const Color(0xFFC5C764),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // H1 Title
              Text(
                'Every device.',
                style: GoogleFonts.orbitron(
                  fontSize: isDesktop ? 72 : 44,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1.0,
                  color: const Color(0xFFEDF5EB),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Zero trust.',
                style: GoogleFonts.orbitron(
                  fontSize: isDesktop ? 72 : 44,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  height: 1.05,
                  letterSpacing: -1.0,
                  color: const Color(0xFFC5C764),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Subtitle
              Text(
                'AutoPolicy detects anomalies in IoT networks and automatically generates enforceable zero-trust security policies — in real time.',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 15.5 : 14,
                  fontWeight: FontWeight.w300,
                  height: 1.85,
                  color: const Color(0xFF829A80),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 42),

              // Buttons
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ChamferedCyberButton(
                    text: 'EXPLORE NOW',
                    onTap: _navigateToLogin,
                  ),
                  _LearnMoreHoverButton(onTap: () => _goToPage(1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section 2: System Specs (HUD Frame Cards)
  Widget _buildSystemSpecsPage(BuildContext context, bool isDesktop) {
    final bool isActive = _currentPage == 2;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Background Tile Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _SystemGridPainter(),
            ),
          ),

          // Central System Stage
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 24,
                vertical: 60,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tag
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 850),
                      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                      opacity: isActive ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 850),
                        curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                        transform: isActive
                            ? Matrix4.identity()
                            : (Matrix4.identity()..translate(0.0, -36.0, 0.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 34,
                              height: 2,
                              color: const Color(0xFF80A416),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'BY THE NUMBERS',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3.5,
                                color: const Color(0xFFC5C764),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // H2 Title
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 900),
                      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                      opacity: isActive ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 900),
                        curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                        transform: isActive
                            ? Matrix4.identity()
                            : (Matrix4.identity()..translate(0.0, -48.0, 0.0)),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.orbitron(
                              fontSize: isDesktop ? 40 : 28,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: const Color(0xFFEDF5EB),
                            ),
                            children: [
                              const TextSpan(text: 'Built to scale. '),
                              TextSpan(
                                text: 'Built to enforce.',
                                style: GoogleFonts.orbitron(
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFC5C764),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // 3 Cyber HUD Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 780) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CyberHudCard(
                                  num: '1K+',
                                  title: 'DEVICES SIMULATED',
                                  desc:
                                      'Continuous real-time anomaly discovery across large heterogeneous clusters.',
                                  delayMs: 200,
                                  isActive: isActive,
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: CyberHudCard(
                                  num: '33',
                                  title: 'ATTACK CATEGORIES',
                                  desc:
                                      'Pre-trained models covering Mirai botnets, DDoS, lateral scanning, and port sweeps.',
                                  delayMs: 400,
                                  isActive: isActive,
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: CyberHudCard(
                                  num: 'RT',
                                  title: 'ENFORCEMENT ENGINE',
                                  desc:
                                      'Instant policy propagation without microcode flashing or device firmware reboots.',
                                  delayMs: 600,
                                  isActive: isActive,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              CyberHudCard(
                                num: '1K+',
                                title: 'DEVICES SIMULATED',
                                desc:
                                    'Continuous real-time anomaly discovery across large heterogeneous clusters.',
                                delayMs: 200,
                                isActive: isActive,
                              ),
                              const SizedBox(height: 24),
                              CyberHudCard(
                                num: '33',
                                title: 'ATTACK CATEGORIES',
                                desc:
                                    'Pre-trained models covering Mirai botnets, DDoS, lateral scanning, and port sweeps.',
                                delayMs: 400,
                                isActive: isActive,
                              ),
                              const SizedBox(height: 24),
                              CyberHudCard(
                                num: 'RT',
                                title: 'ENFORCEMENT ENGINE',
                                desc:
                                    'Instant policy propagation without microcode flashing or device firmware reboots.',
                                delayMs: 600,
                                isActive: isActive,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemGridPainter extends CustomPainter {
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

class _HoverNavLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverNavLink({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_HoverNavLink> createState() => _HoverNavLinkState();
}

class _HoverNavLinkState extends State<_HoverNavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = (_isHovered || widget.isActive)
        ? const Color(0xFFBBF438)
        : const Color(0xFFC5C764);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.orbitron(
            fontSize: 11.5,
            fontWeight: (_isHovered || widget.isActive) ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 2.2,
            color: textColor,
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFBBF438).withOpacity(0.6),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Text(widget.title),
        ),
      ),
    );
  }
}

class _NavLoginButton extends StatefulWidget {
  final VoidCallback onTap;
  const _NavLoginButton({required this.onTap});

  @override
  State<_NavLoginButton> createState() => _NavLoginButtonState();
}

class _NavLoginButtonState extends State<_NavLoginButton> {
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
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFBBF438) : const Color(0xFF80A416),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (_isHovered ? const Color(0xFFBBF438) : const Color(0xFF80A416)).withOpacity(_isHovered ? 0.75 : 0.45),
                blurRadius: _isHovered ? 24 : 18,
                spreadRadius: _isHovered ? 2 : 1,
              ),
            ],
          ),
          child: Text(
            'LOG IN',
            style: GoogleFonts.orbitron(
              fontSize: 10.2,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearnMoreHoverButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LearnMoreHoverButton({required this.onTap});

  @override
  State<_LearnMoreHoverButton> createState() => _LearnMoreHoverButtonState();
}

class _LearnMoreHoverButtonState extends State<_LearnMoreHoverButton> {
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
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: _isHovered ? const Color(0xFFBBF438) : const Color(0xFFEDF5EB),
                  shadows: _isHovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFFBBF438).withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: const Text('Learn more '),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFBBF438),
                  shadows: _isHovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFFBBF438).withOpacity(0.9),
                            blurRadius: 14,
                          ),
                        ]
                      : [],
                ),
                child: const Text('›'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

