import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'main_layout.dart';
import 'landing_screen.dart';
import 'login_screen.dart';

// ═════════════════════════════════════════════════════════════
// SIGNUP PAGE
// ═════════════════════════════════════════════════════════════
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _org = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  
  bool _obscure = true;
  bool _terms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _org.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_terms) {
      setState(() {
        _errorMessage = 'You must accept the terms and security policy';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ref.read(authProvider.notifier).signUp(
        _email.text.trim(),
        _password.text,
        _org.text.trim().isNotEmpty ? _org.text.trim() : 'Organization Member',
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
          // Background Grid Squares
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          // Nav bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AP.bright, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AP.bright, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text('AutoPolicy',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.w900, fontSize: 14,
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
          // Center Form Box (Non-scrollable, perfectly fitted)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: VrFrame(
                  maxWidth: 470,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text('CLEARANCE REQUEST',
                        style: TextStyle(
                          fontSize: 7.5, letterSpacing: 2.8, color: AP.lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text('Create Account',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w900, fontSize: 19,
                          letterSpacing: 0.5, color: AP.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Register for zero-trust console clearance',
                        style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: const Color(0xFFD5E5D3)),
                      ),
                      const SizedBox(height: 12),

                      // Row 1: First Name & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('First Name'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _fname,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Ava'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Last Name'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _lname,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Chen'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Organization Name & Work Email
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Organization'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _org,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('CyberSOC Labs'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Work Email'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _email,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('operator@network.io'),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'Required';
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                        return 'Invalid email';
                                      }
                                      return null;
                                      },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 3: Access Key & Confirm Key
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Access Key'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _password,
                                    obscureText: _obscure,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Min. 12 chars').copyWith(
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          _obscure ? Icons.visibility_off : Icons.visibility,
                                          size: 14,
                                          color: AP.muted,
                                        ),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 12) return 'Min 12 chars';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Confirm Key'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _password2,
                                    obscureText: true,
                                    style: GoogleFonts.spaceGrotesk(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Repeat key'),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v != _password.text) return 'Mismatch';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 15, height: 15,
                            child: Checkbox(
                              value: _terms,
                              onChanged: (v) => setState(() {
                                _terms = v ?? false;
                                if (_terms) _errorMessage = '';
                              }),
                              activeColor: AP.olive,
                              side: BorderSide(color: AP.olive.withOpacity(0.45)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: GoogleFonts.spaceGrotesk(fontSize: 11.5, color: AP.muted, height: 1.3),
                                children: const [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(text: 'Terms & Security Policy', style: TextStyle(color: AP.lime)),
                                  TextSpan(text: '. Sessions may be audited.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),

                      if (_errorMessage.isNotEmpty) ...[
                        Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 10.5, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Submit Button
                      CyberButton(
                        label: _isLoading ? 'Processing...' : 'Request Access',
                        onTap: _isLoading ? null : _handleSignup,
                      ),
                      const SizedBox(height: 6),
                      _orDivider(),
                      const SizedBox(height: 6),
                      CyberButton(
                        label: 'Sign up with Google',
                        primary: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainLayout()),
                          );
                        },
                        leading: const Icon(Icons.g_mobiledata, size: 18, color: AP.lime),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already cleared? ',
                            style: TextStyle(fontSize: 10, color: AP.muted)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text('SIGN IN →',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8.5, letterSpacing: 1.3, color: AP.lime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Divider(color: AP.olive.withOpacity(0.18), height: 1),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 4, height: 4,
                            decoration: const BoxDecoration(
                              color: AP.bright, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AP.bright, blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('CHANNEL SECURE',
                            style: GoogleFonts.orbitron(
                              fontSize: 6.5, letterSpacing: 1.2, color: AP.bright,
                            ),
                          ),
                          const Spacer(),
                          Text('TLS 1.3 · BUILD 1.0',
                            style: GoogleFonts.orbitron(
                              fontSize: 6.5, letterSpacing: 1.1, color: AP.muted,
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
    padding: const EdgeInsets.only(bottom: 3),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 7.5, fontWeight: FontWeight.w700,
          letterSpacing: 1.8, color: AP.lime,
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AP.muted.withOpacity(0.65), fontSize: 11.5),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

class GridPainter extends CustomPainter {
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
