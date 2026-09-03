import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/autopolicy_logo_painter.dart';
import '../widgets/liquid_bubble_background.dart';
import '../widgets/isomorphic_glass_panel.dart';
import '../widgets/isomorphic_glass_button.dart';
import 'main_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@autopolicy.cyber.io');
  final _passCtrl = TextEditingController(text: 'cybersecurity2026');
  final _confirmPassCtrl = TextEditingController();

  String _selectedRole = 'Admin';
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isSignUp = false;
  String _error = '';

  late final AnimationController _glowCtrl;

  // Boot text animation
  final List<String> _bootLines = [];
  final _allBoot = [
    '> NEURAL DEFENSE GRID: INITIALIZED',
    '> QUANTUM ENCRYPTION: ACTIVE',
    '> ZERO-TRUST FABRIC: SYNCED',
    '> GNN ANOMALY ENGINE: LOADED',
    '> OPA POLICY MESH: DEPLOYED',
    '> SYSTEM STATUS: OPERATIONAL',
  ];
  Timer? _bootTimer;
  int _bootIdx = 0;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bootTimer = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (_bootIdx < _allBoot.length && mounted) {
        setState(() => _bootLines.add(_allBoot[_bootIdx++]));
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _glowCtrl.dispose();
    _bootTimer?.cancel();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      if (!_isSignUp) {
        switch (role) {
          case 'Admin':
            _emailCtrl.text = 'admin@autopolicy.cyber.io';
            break;
          case 'Security Engineer':
            _emailCtrl.text = 'engineer@autopolicy.cyber.io';
            break;
          case 'Manager':
            _emailCtrl.text = 'manager@autopolicy.cyber.io';
            break;
        }
        _passCtrl.text = 'cybersecurity2026';
      }
      _error = '';
    });
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && _passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passcodes do not match');
      return;
    }

    setState(() { _isLoading = true; _error = ''; });
    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUp(
              _emailCtrl.text, _passCtrl.text, _selectedRole);
      } else {
        await ref.read(authProvider.notifier).signIn(
              _emailCtrl.text, _passCtrl.text, _selectedRole);
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (c, a, _) => const MainLayout(),
            transitionsBuilder: (c, a, _, ch) =>
                FadeTransition(opacity: a, child: ch),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LiquidBubbleBackground(
        child: SafeArea(
          child: SizedBox.expand(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double screenHeight = constraints.maxHeight;
                final bool isShort = screenHeight < 680;
                final bool isUltraShort = screenHeight < 550;

                return Stack(
                  children: [
                    // Top nav bar - only show if not ultra short
                    if (!isUltraShort)
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: _buildNavBar(isShort),
                      ),
                    // Main content — centered card
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: isShort ? 2.0 : 6.0,
                          ),
                          child: SizedBox(
                            width: 420,
                            child: _buildLoginCard(screenHeight, isShort, isUltraShort),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════ NAV BAR ══════════════════════════════════════════════
  Widget _buildNavBar(bool isShort) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 48,
            vertical: isShort ? 16 : 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF050816).withOpacity(0.40),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: CyberColors.neonCyan, size: 20),
              const SizedBox(width: 12),
              Text('AUTOPOLICY',
                  style: CyberTextStyles.displayTitle(
                    fontSize: 13, color: Colors.white,
                  ).copyWith(letterSpacing: 3.5)),
              const Spacer(),
              if (!isShort) ...[
                _navItem('Products'),
                const SizedBox(width: 28),
                _navItem('Pricing'),
                const SizedBox(width: 28),
                _navItem('Docs'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String t) => Text(t,
      style: CyberTextStyles.interface(
        fontSize: 12.5, color: Colors.white.withOpacity(0.45),
        fontWeight: FontWeight.w500,
      ));

  // ═════════════════ LOGIN CARD ═══════════════════════════════════════════
  Widget _buildLoginCard(double screenHeight, bool isShort, bool isUltraShort) {
    // Dynamic dimensions based on available viewport height
    final double cardPaddingVertical = isUltraShort ? 10.0 : (isShort ? 18.0 : 32.0);
    final double cardPaddingHorizontal = isShort ? 24.0 : 36.0;
    
    final double logoHeight = isUltraShort ? 0.0 : (isShort ? 26.0 : 34.0);
    final double logoSpacing = isShort ? 8.0 : 16.0;
    
    final double titleFontSize = isShort ? 20.0 : 24.0;
    final double titleSpacing = isShort ? 8.0 : 16.0;
    
    final double labelSpacing = isShort ? 4.0 : 6.0;
    final double fieldSpacing = isShort ? 8.0 : 12.0;
    
    final double dividerHeight = isShort ? 12.0 : 20.0;
    final double toggleSpacing = isShort ? 10.0 : 16.0;

    return Form(
      key: _formKey,
      child: IsomorphicGlassPanel(
        borderRadius: 36.0,
        margin: EdgeInsets.symmetric(vertical: isShort ? 2 : 4),
        padding: EdgeInsets.symmetric(
          horizontal: cardPaddingHorizontal,
          vertical: cardPaddingVertical,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center Logo to match mockup brand mark position
            if (logoHeight > 0) ...[
              Align(
                alignment: Alignment.center,
                child: AutopolicyLogo(height: logoHeight),
              ),
              SizedBox(height: logoSpacing),
            ],

            // Centered Title (Clean Outfit style, matching mockup "Welcome Back, Rahul")
            Text(
              _isSignUp ? 'Create New Account' : 'Welcome Back',
              style: GoogleFonts.outfit(
                fontSize: titleFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: titleSpacing),

            // Role selection — 3 pills (designed to look like option buttons in the reference image)
            _label('Access Role'),
            SizedBox(height: labelSpacing),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _rolePill('Admin', Icons.admin_panel_settings, isShort),
                _rolePill('Security Engineer', Icons.engineering, isShort),
                _rolePill('Manager', Icons.manage_accounts, isShort),
              ],
            ),

            Divider(
              color: Colors.white.withOpacity(0.08),
              height: dividerHeight,
              thickness: 1,
            ),

            // Email
            _label('Email address'),
            SizedBox(height: labelSpacing),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Invalid email address' : null,
              decoration: _deco('Enter your email', isShort),
            ),
            SizedBox(height: fieldSpacing),

            // Password
            _label('Password'),
            SizedBox(height: labelSpacing),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Passcode length violation' : null,
              decoration: _deco('Enter your password', isShort,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.55), size: 17,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),

            // Confirm Password (Signup only)
            if (_isSignUp) ...[
              SizedBox(height: fieldSpacing),
              _label('Confirm Password'),
              SizedBox(height: labelSpacing),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
                validator: (v) {
                  if (!_isSignUp) return null;
                  if (v == null || v.isEmpty) return 'Passcode confirmation required';
                  if (v != _passCtrl.text) return 'Passcode verification mismatch';
                  return null;
                },
                decoration: _deco('Confirm your password', isShort,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.55), size: 17,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
            ],

            SizedBox(height: isShort ? 6.0 : 10.0),

            // Forget Password (Login only) - Left aligned below fields
            if (!_isSignUp) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forget Password ?',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isShort ? 12.0 : 16.0),
            ],

            // Error
            if (_error.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: CyberColors.alertRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: CyberColors.alertRed.withOpacity(0.3)),
                ),
                child: Text(_error.toUpperCase(),
                    style: CyberTextStyles.techAlert.copyWith(fontSize: 9),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: isShort ? 6.0 : 10.0),
            ],

            SizedBox(height: isShort ? 2.0 : 6.0),

            // Premium Violet Isomorphic Action Button
            IsomorphicGlassButton(
              text: _isSignUp ? 'Register' : 'Login',
              isLoading: _isLoading,
              height: isShort ? 38.0 : 46.0,
              onPressed: _handleAuth,
            ),

            SizedBox(height: toggleSpacing),
            
            // Bottom toggle row matching mockup style
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUp ? 'Already a Member ? ' : 'Are You New Member ? ',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _error = '';
                      _formKey.currentState?.reset();
                      _confirmPassCtrl.clear();
                      if (_isSignUp) {
                        _emailCtrl.clear();
                        _passCtrl.clear();
                      } else {
                        _selectRole(_selectedRole);
                      }
                    });
                  },
                  child: Text(
                    _isSignUp ? 'Sign IN' : 'Sign UP',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═════════ HELPERS ═════════════════════════════════════════════════════
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          t,
          style: CyberTextStyles.interface(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _rolePill(String role, IconData icon, bool isShort) {
    final sel = _selectedRole == role;
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isShort ? 5 : 8,
          horizontal: isShort ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF00F5FF).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sel ? const Color(0xFF00F5FF) : Colors.white.withOpacity(0.12),
            width: sel ? 1.5 : 1.0,
          ),
          boxShadow: sel
              ? [BoxShadow(color: const Color(0xFF00F5FF).withOpacity(0.18), blurRadius: 8)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: sel ? const Color(0xFF00F5FF) : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(width: 6),
            Text(role,
              style: CyberTextStyles.interface(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : Colors.white.withOpacity(0.45),
              )),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, bool isShort, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF756F8C),
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.black.withOpacity(0.20),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isShort ? 10 : 14,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withOpacity(0.18), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.8), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberColors.alertRed, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberColors.alertRed, width: 1.5),
        ),
      );
}
