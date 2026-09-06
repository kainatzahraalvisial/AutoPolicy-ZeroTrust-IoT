import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'main_layout.dart';
import 'landing_screen.dart';
import 'signup_screen.dart';

// Alias for backward compatibility
typedef LoginScreen = LoginPage;

// ── AP Palette (Dark Cyber Base) ──────────────────────────────
class AP {
  static const olive = Color(0xFF80A416);
  static const lime = Color(0xFFC5C764);
  static const bright = Color(0xFFBBF438);
  static const white = Color(0xFFEDF5EB);
  static const muted = Color(0xFF829A80);
  static const frame = Color(0xFFC5C764);
  static const bg = Color(0xFF050A07); // Pure dark cyber black
}

// ── Shared VR frame clipper ──────────────────────────────────
class VrFrameClipper extends CustomClipper<Path> {
  final double cut;
  VrFrameClipper({this.cut = 18});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class FieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const c = 8.0;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BtnClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const c = 10.0;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── VR Frame container (side tabs + protruding lines) ─────────
class VrFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  const VrFrame({super.key, required this.child, this.maxWidth = 400, this.padding});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth + 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main border box
            Container(
              decoration: BoxDecoration(
                color: AP.bg,
                border: Border.all(color: AP.lime, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AP.lime.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: AP.olive.withOpacity(0.08),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: VrFrameClipper(cut: 16),
                child: Container(
                  color: AP.bg,
                  padding: padding ?? const EdgeInsets.fromLTRB(26, 28, 26, 20),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(32, 7),
                          painter: _StripePainter(),
                        ),
                      ),
                      child,
                    ],
                  ),
                ),
              ),
            ),

            // Top notch + horizontal lines
            Positioned(
              top: -1,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 18, height: 1.5, color: AP.lime.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ClipPath(
                      clipper: _NotchClipper(),
                      child: Container(width: 56, height: 8, color: AP.olive),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 18, height: 1.5, color: AP.lime.withOpacity(0.6)),
                  ],
                ),
              ),
            ),

            // LEFT side square tab + protruding lines
            Positioned(
              left: -11,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 11,
                  height: 36,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 11,
                        height: 36,
                        color: AP.olive,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(width: 1.5, height: 36, color: AP.lime),
                        ),
                      ),
                      Positioned(
                        left: -10,
                        top: 6,
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: EdgeInsets.only(bottom: i < 2 ? 6 : 0),
                              width: 10,
                              height: 2,
                              color: AP.lime.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // RIGHT side square tab + protruding lines
            Positioned(
              right: -11,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 11,
                  height: 36,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 11,
                        height: 36,
                        color: AP.olive,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 1.5, height: 36, color: AP.lime),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: 6,
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: EdgeInsets.only(bottom: i < 2 ? 6 : 0),
                              width: 10,
                              height: 2,
                              color: AP.lime.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(6, 0)
      ..lineTo(size.width - 6, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AP.olive.withOpacity(0.55)
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width + size.height; x += 5) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Field shell ──────────────────────────────────────────────
class FieldShell extends StatelessWidget {
  final Widget child;
  const FieldShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FieldClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xE608120C), // Dark blackish shell background
          border: Border.all(color: AP.olive.withOpacity(0.35)),
        ),
        child: child,
      ),
    );
  }
}

// ── Cyber button ─────────────────────────────────────────────
class CyberButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Widget? leading;

  const CyberButton({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.leading,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, hover ? -1 : 0, 0),
          child: ClipPath(
            clipper: BtnClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
              decoration: BoxDecoration(
                color: widget.primary
                    ? (hover ? AP.bright : AP.olive)
                    : (hover
                        ? AP.olive.withOpacity(0.12)
                        : const Color(0xE608120C)),
                border: widget.primary
                    ? null
                    : Border.all(
                        color: hover ? AP.lime : AP.olive.withOpacity(0.35),
                      ),
                boxShadow: widget.primary
                    ? [
                        BoxShadow(
                          color: (hover ? AP.bright : AP.olive)
                              .withOpacity(hover ? 0.65 : 0.4),
                          blurRadius: hover ? 28 : 18,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 9),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: widget.primary ? 11 : 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: widget.primary
                          ? Colors.black
                          : (hover ? AP.bright : AP.lime),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// LOGIN PAGE
// ═════════════════════════════════════════════════════════════
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'operator@network.io');
  final _password = TextEditingController(text: 'cybersecurity2026');
  bool _obscure = true;
  bool _remember = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ref.read(authProvider.notifier).signIn(
        _email.text.trim(),
        _password.text,
        'Admin',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Grid
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Nav
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AP.bright,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AP.bright, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text('AutoPolicy',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.w900, fontSize: 14.5,
                            letterSpacing: 3.2, color: AP.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _BackToExploreButton(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LandingScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: VrFrame(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text('SECURE ACCESS',
                        style: TextStyle(
                          fontSize: 8.5, letterSpacing: 3.5, color: AP.lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Sign In',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w900, fontSize: 24,
                          letterSpacing: 0.6, color: AP.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Authenticate to the zero-trust console',
                        style: GoogleFonts.spaceGrotesk(fontSize: 13.5, color: const Color(0xFFD5E5D3)),
                      ),
                      const SizedBox(height: 22),

                      // Email
                      _label('Email / Identity'),
                      FieldShell(
                        child: TextFormField(
                          controller: _email,
                          style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 14),
                          decoration: _inputDeco('operator@network.io'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Identity / email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _label('Access Key'),
                      FieldShell(
                        child: TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 14),
                          decoration: _inputDeco('••••••••••••').copyWith(
                            suffixIcon: TextButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              child: Text(_obscure ? 'SHOW' : 'HIDE',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9, letterSpacing: 1.2, color: AP.muted,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Access key is required';
                            }
                            if (value.length < 6) {
                              return 'Key must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Options
                      Row(
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v ?? false),
                              activeColor: AP.olive,
                              side: BorderSide(color: AP.olive.withOpacity(0.45)),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text('Stay authenticated',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: AP.muted)),
                          const Spacer(),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text('RESET KEY',
                              style: GoogleFonts.orbitron(
                                fontSize: 9, letterSpacing: 1.4, color: AP.lime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_errorMessage.isNotEmpty) ...[
                        Text(
                          _errorMessage,
                          style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],

                      CyberButton(
                        label: _isLoading ? 'Authenticating...' : 'Authenticate',
                        onTap: _isLoading ? null : _handleAuth,
                      ),
                      const SizedBox(height: 14),
                      _orDivider(),
                      const SizedBox(height: 12),
                      CyberButton(
                        label: 'Sign in with Google',
                        primary: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainLayout()),
                          );
                        },
                        leading: const Icon(Icons.g_mobiledata, size: 20, color: AP.lime),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No clearance yet? ',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13.0, color: AP.muted)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupPage()),
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text('REQUEST ACCESS →',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9.5, letterSpacing: 1.4, color: AP.lime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: AP.olive.withOpacity(0.18), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: AP.bright, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AP.bright, blurRadius: 6)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('CHANNEL SECURE',
                            style: GoogleFonts.orbitron(
                              fontSize: 7.5, letterSpacing: 1.6, color: AP.bright,
                            ),
                          ),
                          const Spacer(),
                          Text('TLS 1.3 · BUILD 1.0',
                            style: GoogleFonts.orbitron(
                              fontSize: 7.5, letterSpacing: 1.4, color: AP.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 8.5, fontWeight: FontWeight.w700,
          letterSpacing: 2.2, color: AP.lime,
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AP.muted.withOpacity(0.65), fontSize: 13.5),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    isDense: true,
  );

  Widget _orDivider() => Row(
    children: [
      Expanded(child: Divider(color: AP.olive.withOpacity(0.3))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text('OR',
          style: GoogleFonts.orbitron(
            fontSize: 7.5, letterSpacing: 2.2, color: AP.muted,
          ),
        ),
      ),
      Expanded(child: Divider(color: AP.olive.withOpacity(0.3))),
    ],
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AP.lime.withOpacity(0.14) // Distinct, visible grid squares
      ..strokeWidth = 1.0;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackToExploreButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackToExploreButton({required this.onTap});

  @override
  State<_BackToExploreButton> createState() => _BackToExploreButtonState();
}

class _BackToExploreButtonState extends State<_BackToExploreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.orbitron(
            fontSize: 9.5,
            letterSpacing: 1.8,
            fontWeight: _isHovered ? FontWeight.w800 : FontWeight.w500,
            color: _isHovered ? AP.bright : AP.lime,
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: AP.bright.withOpacity(0.7),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: const Text('‹  BACK TO EXPLORE'),
        ),
      ),
    );
  }
}
