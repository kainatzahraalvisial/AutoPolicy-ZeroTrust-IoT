import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/cyber_button.dart';

import '../providers/theme_provider.dart';

// Alias for backward compatibility
typedef LoginScreen = LoginPage;

// ── VR Frame container (side tabs + protruding lines) ─────────
class VrFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool isDarkMode;

  const VrFrame({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.padding,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final frameBg = isDarkMode ? AP.bg : Colors.white;
    final frameBorder = isDarkMode ? AP.lime : const Color(0xFF80A416);
    final tabColor = isDarkMode ? AP.olive : const Color(0xFFC4E320);

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
                color: frameBg,
                border: Border.all(color: frameBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? AP.lime.withOpacity(0.2) : const Color(0xFF80A416).withOpacity(0.18),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: isDarkMode ? AP.olive.withOpacity(0.08) : const Color(0xFF80A416).withOpacity(0.06),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: VrFrameClipper(cut: 16),
                child: Container(
                  color: frameBg,
                  padding: padding ?? const EdgeInsets.fromLTRB(26, 28, 26, 20),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(32, 7),
                          painter: _StripePainter(isDarkMode: isDarkMode),
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
                    Container(width: 18, height: 1.5, color: frameBorder.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ClipPath(
                      clipper: _NotchClipper(),
                      child: Container(width: 56, height: 8, color: tabColor),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 18, height: 1.5, color: frameBorder.withOpacity(0.6)),
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
                        color: tabColor,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(width: 1.5, height: 36, color: frameBorder),
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
                              color: frameBorder.withOpacity(0.75),
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
                        color: tabColor,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 1.5, height: 36, color: frameBorder),
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
                              color: frameBorder.withOpacity(0.75),
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
  final bool isDarkMode;
  _StripePainter({this.isDarkMode = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? AP.olive : const Color(0xFF80A416)).withOpacity(0.55)
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
  final bool isDarkMode;
  const FieldShell({super.key, required this.child, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FieldClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6),
          border: Border.all(
            color: isDarkMode ? AP.olive.withOpacity(0.35) : const Color(0xFFCDD4B2),
            width: 1.2,
          ),
        ),
        child: child,
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
        Navigator.pushReplacementNamed(context, '/dashboard');
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
    final isDarkMode = ref.watch(themeModeProvider);
    final brandTitleColor = isDarkMode ? AP.white : const Color(0xFF0F172A);
    final textColor = isDarkMode ? AP.white : const Color(0xFF0F172A);
    final subtextColor = isDarkMode ? const Color(0xFFD5E5D3) : const Color(0xFF64748B);
    final labelColor = isDarkMode ? AP.lime : const Color(0xFF80A416);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // Grid
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(isDarkMode: isDarkMode)),
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
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC4E320),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0xFFC4E320), blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text('AutoPolicy',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.w900, fontSize: 14.5,
                            letterSpacing: 3.2, color: brandTitleColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Theme Switcher Live Pill
                    InkWell(
                      onTap: () => ref.read(themeModeProvider.notifier).state = !isDarkMode,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF141414) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416)).withOpacity(0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                              size: 14,
                              color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isDarkMode ? 'DARK' : 'LIGHT',
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _BackToExploreButton(
                      isDarkMode: isDarkMode,
                      onTap: () => Navigator.pushReplacementNamed(context, '/landing'),
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
                  isDarkMode: isDarkMode,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text('SECURE ACCESS',
                        style: TextStyle(
                          fontSize: 8.5, letterSpacing: 3.5, color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Sign In',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w900, fontSize: 24,
                          letterSpacing: 0.6, color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Authenticate to the zero-trust console',
                        style: GoogleFonts.spaceGrotesk(fontSize: 13.5, color: subtextColor),
                      ),
                      const SizedBox(height: 22),

                      // Email
                      _label('Email / Identity', isDarkMode),
                      FieldShell(
                        isDarkMode: isDarkMode,
                        child: TextFormField(
                          controller: _email,
                          style: GoogleFonts.spaceGrotesk(
                            color: isDarkMode ? AP.white : Colors.black, 
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: isDarkMode ? const Color(0xFFC4E320) : Colors.black,
                          decoration: _inputDeco('operator@network.io', isDarkMode),
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
                      _label('Access Key', isDarkMode),
                      FieldShell(
                        isDarkMode: isDarkMode,
                        child: TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          style: GoogleFonts.spaceGrotesk(
                            color: isDarkMode ? AP.white : Colors.black, 
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: isDarkMode ? const Color(0xFFC4E320) : Colors.black,
                          decoration: _inputDeco('••••••••••••', isDarkMode).copyWith(
                            suffixIcon: TextButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              child: Text(_obscure ? 'SHOW' : 'HIDE',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9, letterSpacing: 1.2, 
                                  color: isDarkMode ? AP.muted : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
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
                              activeColor: const Color(0xFF80A416),
                              side: BorderSide(
                                color: isDarkMode ? AP.olive.withOpacity(0.45) : const Color(0xFFCDD4B2),
                                width: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text('Stay authenticated',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: isDarkMode ? AP.muted : const Color(0xFF1E293B))),
                          const Spacer(),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text('RESET KEY',
                              style: GoogleFonts.orbitron(
                                fontSize: 9, letterSpacing: 1.4, color: isDarkMode ? labelColor : const Color(0xFF475569),
                                fontWeight: FontWeight.bold,
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
                        isDarkMode: isDarkMode,
                        onTap: _isLoading ? null : _handleAuth,
                      ),
                      const SizedBox(height: 14),
                      _orDivider(isDarkMode),
                      const SizedBox(height: 12),
                      CyberButton(
                        label: 'Sign in with Google',
                        primary: false,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                        leading: Icon(Icons.g_mobiledata, size: 20, color: labelColor),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AP.olive.withOpacity(0.12) : const Color(0xFFC4E320).withOpacity(0.15),
                          border: Border.all(color: isDarkMode ? AP.olive.withOpacity(0.35) : const Color(0xFF80A416).withOpacity(0.35)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: labelColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'ZERO-TRUST: OPERATORS PROVISIONED BY ADMIN ONLY',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8.5,
                                  letterSpacing: 0.8,
                                  color: isDarkMode ? const Color(0xFFD5E5D3) : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(color: isDarkMode ? AP.olive.withOpacity(0.18) : const Color(0xFF80A416).withOpacity(0.20), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC4E320), shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Color(0xFFC4E320), blurRadius: 6)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('CHANNEL SECURE',
                            style: GoogleFonts.orbitron(
                              fontSize: 7.5, letterSpacing: 1.6, color: isDarkMode ? AP.bright : const Color(0xFF80A416),
                            ),
                          ),
                          const Spacer(),
                          Text('TLS 1.3 · BUILD 1.0',
                            style: GoogleFonts.orbitron(
                              fontSize: 7.5, letterSpacing: 1.4, color: isDarkMode ? AP.muted : const Color(0xFF64748B),
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

  Widget _label(String t, bool isDarkMode) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 8.5, fontWeight: FontWeight.w700,
          letterSpacing: 2.2, color: isDarkMode ? AP.lime : const Color(0xFF0F172A),
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint, bool isDarkMode) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDarkMode ? AP.muted.withOpacity(0.65) : const Color(0xFF64748B), 
      fontSize: 13.5,
    ),
    filled: true,
    fillColor: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6), // Feather White fill
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    isDense: true,
  );

  Widget _orDivider(bool isDarkMode) => Row(
    children: [
      Expanded(child: Divider(color: isDarkMode ? AP.olive.withOpacity(0.3) : const Color(0xFF80A416).withOpacity(0.25))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text('OR',
          style: GoogleFonts.orbitron(
            fontSize: 7.5, letterSpacing: 2.2, color: isDarkMode ? AP.muted : const Color(0xFF64748B),
          ),
        ),
      ),
      Expanded(child: Divider(color: isDarkMode ? AP.olive.withOpacity(0.3) : const Color(0xFF80A416).withOpacity(0.25))),
    ],
  );
}

class _GridPainter extends CustomPainter {
  final bool isDarkMode;
  _GridPainter({this.isDarkMode = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? AP.lime.withOpacity(0.14) : const Color(0xFF80A416).withOpacity(0.08))
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
  final bool isDarkMode;
  const _BackToExploreButton({required this.onTap, this.isDarkMode = true});

  @override
  State<_BackToExploreButton> createState() => _BackToExploreButtonState();
}

class _BackToExploreButtonState extends State<_BackToExploreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final normalColor = widget.isDarkMode ? AP.lime : const Color(0xFF80A416);
    final hoverColor = widget.isDarkMode ? AP.bright : const Color(0xFFC4E320);

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
            color: _isHovered ? hoverColor : normalColor,
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: hoverColor.withOpacity(0.7),
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
