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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  
  String? _selectedRole;
  bool _obscure = true;
  bool _terms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _roles = [
    'Admin Clearance',
    'Security Engineer',
    'Network Operator',
    'Auditor / Compliance',
  ];

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
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
        _selectedRole ?? 'Admin Clearance',
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
          // Center Form Box
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: VrFrame(
                  maxWidth: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text('CLEARANCE REQUEST',
                        style: TextStyle(
                          fontSize: 8, letterSpacing: 3.2, color: AP.lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Create Account',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w900, fontSize: 22,
                          letterSpacing: 0.5, color: AP.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text('Register for the zero-trust console',
                        style: TextStyle(fontSize: 11, color: AP.muted),
                      ),
                      const SizedBox(height: 16),

                      // Name row
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
                                    style: const TextStyle(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Ava'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Last Name'),
                                FieldShell(
                                  child: TextFormField(
                                    controller: _lname,
                                    style: const TextStyle(color: AP.white, fontSize: 13),
                                    decoration: _inputDeco('Chen'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),

                      // Email / Identity
                      _label('Email / Identity'),
                      FieldShell(
                        child: TextFormField(
                          controller: _email,
                          style: const TextStyle(color: AP.white, fontSize: 13),
                          decoration: _inputDeco('operator@network.io'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Valid email required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 11),

                      // Role Dropdown
                      _label('Role'),
                      FieldShell(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          dropdownColor: const Color(0xFF08120C),
                          icon: const Icon(Icons.arrow_drop_down, color: AP.lime),
                          style: const TextStyle(color: AP.white, fontSize: 13),
                          decoration: _inputDeco('Select clearance tier'),
                          items: _roles.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedRole = val);
                          },
                          validator: (v) => v == null ? 'Clearance tier required' : null,
                        ),
                      ),
                      const SizedBox(height: 11),

                      // Access Key
                      _label('Access Key'),
                      FieldShell(
                        child: TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          style: const TextStyle(color: AP.white, fontSize: 13),
                          decoration: _inputDeco('Min. 12 characters').copyWith(
                            suffixIcon: TextButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              child: Text(_obscure ? 'SHOW' : 'HIDE',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9, letterSpacing: 1.2, color: AP.muted,
                                ),
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Access key required';
                            if (v.length < 12) return 'Must be at least 12 characters';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 11),

                      // Confirm Key
                      _label('Confirm Key'),
                      FieldShell(
                        child: TextFormField(
                          controller: _password2,
                          obscureText: true,
                          style: const TextStyle(color: AP.white, fontSize: 13),
                          decoration: _inputDeco('Repeat access key'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirmation required';
                            if (v != _password.text) return 'Keys do not match';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 16, height: 16,
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
                                style: TextStyle(fontSize: 10.5, color: AP.muted, height: 1.4),
                                children: const [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(text: 'Terms', style: TextStyle(color: AP.lime)),
                                  TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AP.lime)),
                                  TextSpan(text: '. Sessions may be audited.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_errorMessage.isNotEmpty) ...[
                        Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Submit Button
                      CyberButton(
                        label: _isLoading ? 'Processing...' : 'Request Access',
                        onTap: _isLoading ? null : _handleSignup,
                      ),
                      const SizedBox(height: 12),
                      _orDivider(),
                      const SizedBox(height: 10),
                      CyberButton(
                        label: 'Sign up with Google',
                        primary: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainLayout()),
                          );
                        },
                        leading: const Icon(Icons.g_mobiledata, size: 20, color: AP.lime),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already cleared? ',
                            style: TextStyle(fontSize: 11, color: AP.muted)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text('SIGN IN →',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9, letterSpacing: 1.4, color: AP.lime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: AP.olive.withOpacity(0.18), height: 1),
                      const SizedBox(height: 8),
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
                              fontSize: 7, letterSpacing: 1.5, color: AP.bright,
                            ),
                          ),
                          const Spacer(),
                          Text('TLS 1.3 · BUILD 1.0',
                            style: GoogleFonts.orbitron(
                              fontSize: 7, letterSpacing: 1.3, color: AP.muted,
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
    padding: const EdgeInsets.only(bottom: 5),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 8, fontWeight: FontWeight.w700,
          letterSpacing: 2.0, color: AP.lime,
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AP.muted.withOpacity(0.65), fontSize: 13),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
