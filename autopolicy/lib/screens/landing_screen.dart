import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/three_particle_canvas.dart';
import '../widgets/pipeline_stage_widget.dart';
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
    if (index < 0 || index > 2 || index == _currentPage || _isTransitioning) return;

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
      _goToPage((_currentPage + 1).clamp(0, 2));
    } else {
      _goToPage((_currentPage - 1).clamp(0, 2));
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      _wheelLock = false;
    });
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
    final bool isOnPipeline = _currentPage == 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
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
            // 1. Full-Screen Interactive WebGL/3D Particle Background (Hidden on Pipeline page)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isOnPipeline ? 0.0 : 1.0,
              child: Positioned.fill(
                child: ThreeParticleCanvas(mousePos: _globalMousePos),
              ),
            ),

            // 2. Left Vertical Margin Pill & Accent Bar (Hidden on Pipeline page)
            if (isDesktop) ...[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isOnPipeline ? 0.0 : 1.0,
                child: Positioned(
                  left: 24,
                  top: 24,
                  bottom: 24,
                  width: 54,
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
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isOnPipeline ? 0.0 : 1.0,
                child: Positioned(
                  left: 86,
                  bottom: 24,
                  width: 18,
                  height: 120,
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
              left: isDesktop ? 120 : 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 24,
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
                            color: const Color(0xFFF5EDF8),
                          ),
                        ),
                      ],
                    ),

                    // Nav Links
                    if (isDesktop)
                      Row(
                        children: [
                          _buildNavLink('EXPLORE', 0),
                          const SizedBox(width: 40),
                          _buildNavLink('PIPELINE', 1),
                          const SizedBox(width: 40),
                          _buildNavLink('SYSTEM', 2),
                        ],
                      ),

                    // Login Action Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF80A416),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF80A416).withOpacity(0.45),
                                blurRadius: 18,
                                spreadRadius: 1,
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
                    ),
                  ],
                ),
              ),
            ),

            // 4. Fixed Scenes (Hero, Pipeline Stage, System Specs)
            Positioned(
              top: 0,
              bottom: 0,
              left: isDesktop ? 120 : 0,
              right: 0,
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildHeroPage(context, isDesktop),
                  PipelineStageWidget(isActive: _currentPage == 1),
                  _buildSystemSpecsPage(context, isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, int index) {
    final bool isActive = _currentPage == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _goToPage(index),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: GoogleFonts.orbitron(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 2.2,
            color: isActive ? const Color(0xFFBBF438) : const Color(0xFFC5C764),
          ),
          child: Text(title),
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
                  color: const Color(0xFFF5EDF8),
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
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _goToPage(1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Learn more ',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: const Color(0xFFF5EDF8),
                            ),
                          ),
                          Text(
                            '›',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFBBF438),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section 2: System Specs
  Widget _buildSystemSpecsPage(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tag
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
              const SizedBox(height: 24),

              // H2 Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.orbitron(
                    fontSize: isDesktop ? 40 : 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: const Color(0xFFF5EDF8),
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
              const SizedBox(height: 36),

              // Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return Row(
                      children: [
                        Expanded(child: _buildCard('1K+', 'DEVICES SIMULATED', 'Continuous real-time anomaly discovery across large heterogeneous clusters.')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCard('33', 'ATTACK CATEGORIES', 'Pre-trained models covering Mirai botnets, DDoS, lateral scanning, and port sweeps.')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCard('RT', 'ENFORCEMENT ENGINE', 'Instant policy propagation without microcode flashing or device firmware reboots.')),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCard('1K+', 'DEVICES SIMULATED', 'Continuous real-time anomaly discovery across large heterogeneous clusters.'),
                        const SizedBox(height: 16),
                        _buildCard('33', 'ATTACK CATEGORIES', 'Pre-trained models covering Mirai botnets, DDoS, lateral scanning, and port sweeps.'),
                        const SizedBox(height: 16),
                        _buildCard('RT', 'ENFORCEMENT ENGINE', 'Instant policy propagation without microcode flashing or device firmware reboots.'),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String num, String title, String desc) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xC70C0618),
            border: Border.all(
              color: const Color(0xFF80A416).withOpacity(0.22),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                num,
                style: GoogleFonts.orbitron(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFC5C764),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFFC5C764),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 11.8,
                  fontWeight: FontWeight.w300,
                  height: 1.65,
                  color: const Color(0xFF829A80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
