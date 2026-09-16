import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/cyber_button.dart';
import '../providers/theme_provider.dart';

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
          // Background Grid Squares
          Positioned.fill(child: CustomPaint(painter: GridPainter(isDarkMode: isDarkMode))),
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
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC4E320), shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0xFFC4E320), blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text('AutoPolicy',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.w900, fontSize: 14,
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
          // Center Form Box (Non-scrollable, perfectly fitted)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: VrFrame(
                  maxWidth: 470,
                  isDarkMode: isDarkMode,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text('ROOT ENCLAVE INITIALIZATION',
                        style: TextStyle(
                          fontSize: 7.5, letterSpacing: 2.8, color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text('First-Time Admin Setup',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w900, fontSize: 18,
                          letterSpacing: 0.5, color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Initialize primary administrator credentials for this deployment',
                        style: GoogleFonts.spaceGrotesk(fontSize: 12.0, color: subtextColor),
                      ),
                      const SizedBox(height: 12),

                      // Row 1: First Name & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('First Name', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _fname,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('Ava', isDarkMode),
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
                                _label('Last Name', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _lname,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('Chen', isDarkMode),
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
                                _label('Organization', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _org,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('CyberSOC Labs', isDarkMode),
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
                                _label('Work Email', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _email,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('operator@network.io', isDarkMode),
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
                                _label('Access Key', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _password,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    obscureText: _obscure,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('Min. 12 chars', isDarkMode).copyWith(
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          _obscure ? Icons.visibility_off : Icons.visibility,
                                          size: 14,
                                          color: isDarkMode ? AP.muted : const Color(0xFF64748B),
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
                                _label('Confirm Key', isDarkMode),
                                FieldShell(
                                  isDarkMode: isDarkMode,
                                  child: TextFormField(
                                    controller: _password2,
                                    cursorColor: isDarkMode ? AP.lime : Colors.black,
                                    obscureText: true,
                                    style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 13),
                                    decoration: _inputDeco('Repeat key', isDarkMode),
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
                              activeColor: isDarkMode ? const Color(0xFF80A416) : const Color(0xFFB8A9C1),
                              side: BorderSide(
                                color: isDarkMode ? AP.olive.withOpacity(0.45) : const Color(0xFFCDD4B2),
                                width: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11.5, 
                                  color: isDarkMode ? AP.muted : const Color(0xFF475569), 
                                  height: 1.3,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms & Security Policy', 
                                    style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: '. Sessions may be audited.'),
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
                        label: _isLoading ? 'INITIALIZING ENCLAVE...' : 'INITIALIZE ROOT ENCLAVE',
                        isDarkMode: isDarkMode,
                        onTap: _isLoading ? null : _handleSignup,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Existing operator credentials? ',
                            style: TextStyle(fontSize: 10, color: subtextColor)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text('SIGN IN →',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8.5, letterSpacing: 1.3, color: labelColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Divider(color: isDarkMode ? AP.olive.withOpacity(0.18) : const Color(0xFF80A416).withOpacity(0.20), height: 1),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 4, height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC4E320), shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Color(0xFFC4E320), blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('CHANNEL SECURE',
                            style: GoogleFonts.orbitron(
                              fontSize: 6.5, letterSpacing: 1.2, color: isDarkMode ? AP.bright : const Color(0xFF80A416),
                            ),
                          ),
                          const Spacer(),
                          Text('TLS 1.3 · BUILD 1.0',
                            style: GoogleFonts.orbitron(
                              fontSize: 6.5, letterSpacing: 1.1, color: subtextColor,
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
    padding: const EdgeInsets.only(bottom: 3),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 7.5, fontWeight: FontWeight.w700,
          letterSpacing: 1.8, color: isDarkMode ? AP.lime : const Color(0xFF0F172A),
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint, bool isDarkMode) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDarkMode ? AP.muted.withOpacity(0.65) : const Color(0xFF64748B), 
      fontSize: 11.5,
    ),
    filled: true,
    fillColor: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6), // Feather White fill
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    isDense: true,
  );
}

class GridPainter extends CustomPainter {
  final bool isDarkMode;
  GridPainter({this.isDarkMode = true});

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
