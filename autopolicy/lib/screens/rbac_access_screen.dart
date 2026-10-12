import '../widgets/console_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../theme/text_styles.dart';

/// Role-Based Access Control (RBAC) – Redesigned Layout
/// Section 1: Active Operators (Primary Focus Table with Search & Filter)
/// Section 2: Secondary Content (Two Tabs: Permissions Matrix & Session/Audit Log)
class RbacAccessScreen extends ConsumerStatefulWidget {
  const RbacAccessScreen({super.key});

  @override
  ConsumerState<RbacAccessScreen> createState() => _RbacAccessScreenState();
}

class _RbacAccessScreenState extends ConsumerState<RbacAccessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All Roles';

  // Active Operators List
  final List<Map<String, String>> _operatorsList = [
    {
      'name': 'Kainat Alvi',
      'email': 'kainat.alvi@zerotrust.internal',
      'role': 'Admin',
      'status': 'ACTIVE',
      'lastLogin': '10 mins ago',
      'ip': '192.168.1.105',
    },
    {
      'name': 'Alex Chen',
      'email': 'a.chen@zerotrust.internal',
      'role': 'Security Engineer',
      'status': 'ACTIVE',
      'lastLogin': '1 hour ago',
      'ip': '10.128.4.155',
    },
    {
      'name': 'Marcus Vance',
      'email': 'm.vance@zerotrust.internal',
      'role': 'Compliance Manager',
      'status': 'ACTIVE',
      'lastLogin': '3 hours ago',
      'ip': '10.128.8.21',
    },
    {
      'name': 'Siti Nurhaliza',
      'email': 's.nurhaliza@zerotrust.internal',
      'role': 'Security Engineer',
      'status': 'ACTIVE',
      'lastLogin': 'Yesterday',
      'ip': '192.168.2.14',
    },
    {
      'name': 'David Kim',
      'email': 'd.kim@zerotrust.internal',
      'role': 'Incident Response Lead',
      'status': 'ACTIVE',
      'lastLogin': '2 days ago',
      'ip': '10.128.1.99',
    },
    {
      'name': 'Elena Rostova',
      'email': 'e.rostova@zerotrust.internal',
      'role': 'Auditor',
      'status': 'REVOKED',
      'lastLogin': '14 days ago',
      'ip': '172.16.0.4',
    },
  ];

  // Permissions Matrix Definition (Rows = Permissions, Columns = Roles)
  final List<Map<String, dynamic>> _permissionsMatrix = [
    {
      'permission': 'View Real-Time Telemetry & Threat Dashboard',
      'admin': true,
      'engineer': true,
      'manager': true,
    },
    {
      'permission': 'Approve & Deploy OPA Microsegmentation Rego',
      'admin': true,
      'engineer': true,
      'manager': false,
    },
    {
      'permission': 'Manually Quarantine / Sever Compromised IoT Asset',
      'admin': true,
      'engineer': true,
      'manager': false,
    },
    {
      'permission': 'Execute Sandbox Simulation & PCAP Replays',
      'admin': true,
      'engineer': true,
      'manager': false,
    },
    {
      'permission': 'Provision & Revoke Operators (RBAC Management)',
      'admin': true,
      'engineer': false,
      'manager': false,
    },
    {
      'permission': 'Export SOC2 / ISO 27001 Cryptographic Audits',
      'admin': true,
      'engineer': false,
      'manager': true,
    },
    {
      'permission': 'Configure Zeek Sensors & GNN Thresholds',
      'admin': true,
      'engineer': false,
      'manager': false,
    },
  ];

  // Session & Audit Log entries
  final List<Map<String, String>> _sessionAudits = [
    {
      'time': '2026-09-12 15:20:12',
      'user': 'kainat.alvi',
      'action': 'POLICY DEPLOYMENT (MODBUS-04)',
      'ip': '192.168.1.105',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 14:10:44',
      'user': 'kainat.alvi',
      'action': 'OPERATOR LOGIN VIA HARDWARE MFA',
      'ip': '192.168.1.105',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 13:52:19',
      'user': 'a.chen',
      'action': 'DEVICE ISOLATION TRIGGERED (#88)',
      'ip': '10.128.4.155',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 12:45:10',
      'user': 'kainat.alvi',
      'action': 'REJECTED DRAFT REGO RULE (#POL-08)',
      'ip': '192.168.1.105',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 10:45:11',
      'user': 'm.vance',
      'action': 'EXPORTED REGULATORY SOC2 REPORT',
      'ip': '10.128.8.21',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 09:02:18',
      'user': 'kainat.alvi',
      'action': 'ADJUSTED GNN DETECTION THRESHOLD',
      'ip': '192.168.1.105',
      'status': 'SUCCESS'
    },
    {
      'time': '2026-09-12 08:12:00',
      'user': 'audit.temp',
      'action': 'ATTEMPTED UNAUTHORIZED COMPILE',
      'ip': '192.168.1.84',
      'status': 'DENIED'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddUserModal() {
    final isDarkMode = ref.read(themeModeProvider);
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'SOC Incident Response');
    final passCtrl = TextEditingController();
    final cnfPassCtrl = TextEditingController();
    final ipCtrl = TextEditingController(text: '10.128.0.0/16');
    final notesCtrl = TextEditingController();

    String selectedRole = 'Security Engineer';
    bool sendInvite = true;
    bool forcePasswordChange = true;
    bool showAdvanced = false;
    bool obscurePass = true;
    String? errorText;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _ModalVrFrame(
            maxWidth: 680,
            isDarkMode: isDarkMode,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZERO-TRUST IDENTITY PROVISIONING · STRICT RBAC ENFORCED',
                            style: GoogleFonts.orbitron(
                              fontSize: 8.5,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? const Color(0xFFC5C764)
                                  : const Color(0xFF80A416),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PROVISION NEW OPERATOR',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: isDarkMode
                                ? Colors.white54
                                : const Color(0xFF64748B),
                            size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                      color: isDarkMode
                          ? const Color(0xFF80A416).withOpacity(0.25)
                          : const Color(0xFFCDD4B2),
                      height: 1),
                  const SizedBox(height: 16),

                  if (errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x22DF2531),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFDF2531)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 16, color: Color(0xFFDF2531)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorText!,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: const Color(0xFFDF2531),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Row 1: Name & Email
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('Full Name / Identity', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: TextField(
                                controller: nameCtrl,
                                style: _modalInputTextStyle(isDarkMode),
                                cursorColor: isDarkMode
                                    ? const Color(0xFFC4E320)
                                    : const Color(0xFF0F172A),
                                decoration: _modalInputDeco(
                                    'e.g. Sarah Jenkins', isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('Organization Email', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: TextField(
                                controller: emailCtrl,
                                style: _modalInputTextStyle(isDarkMode),
                                cursorColor: isDarkMode
                                    ? const Color(0xFFC4E320)
                                    : const Color(0xFF0F172A),
                                decoration: _modalInputDeco(
                                    'operator@zerotrust.internal', isDarkMode),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Role & Department (Cleanly Aligned)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('System Role', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRole,
                                  isExpanded: true,
                                  dropdownColor: isDarkMode
                                      ? const Color(0xFF0F0F14)
                                      : Colors.white,
                                  style: _modalInputTextStyle(isDarkMode),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDarkMode
                                        ? const Color(0xFFC5C764)
                                        : const Color(0xFF0F172A),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  items: [
                                    'Administrator',
                                    'Security Engineer',
                                    'Manager'
                                  ].map((r) {
                                    return DropdownMenuItem(
                                        value: r, child: Text(r));
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null)
                                      setDlgState(() => selectedRole = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('Department / Unit', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: TextField(
                                controller: deptCtrl,
                                style: _modalInputTextStyle(isDarkMode),
                                cursorColor: isDarkMode
                                    ? const Color(0xFFC4E320)
                                    : const Color(0xFF0F172A),
                                decoration: _modalInputDeco(
                                    'e.g. SOC Incident Response', isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Temporary Password & Confirm Password (Cleanly Aligned, No Truncation)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('Temporary Password', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: TextField(
                                controller: passCtrl,
                                obscureText: obscurePass,
                                style: _modalInputTextStyle(isDarkMode),
                                cursorColor: isDarkMode
                                    ? const Color(0xFFC4E320)
                                    : const Color(0xFF0F172A),
                                decoration:
                                    _modalInputDeco('••••••••••••', isDarkMode)
                                        .copyWith(
                                  suffixIcon: TextButton(
                                    onPressed: () => setDlgState(
                                        () => obscurePass = !obscurePass),
                                    child: Text(
                                      obscurePass ? 'SHOW' : 'HIDE',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9,
                                        letterSpacing: 1.2,
                                        color: isDarkMode
                                            ? const Color(0xFF829A80)
                                            : const Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalLabel('Confirm Password', isDarkMode),
                            _ModalFieldShell(
                              isDarkMode: isDarkMode,
                              child: TextField(
                                controller: cnfPassCtrl,
                                obscureText: obscurePass,
                                style: _modalInputTextStyle(isDarkMode),
                                cursorColor: isDarkMode
                                    ? const Color(0xFFC4E320)
                                    : const Color(0xFF0F172A),
                                decoration:
                                    _modalInputDeco('••••••••••••', isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkbox Options (Login Theme Aligned)
                  Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: sendInvite,
                          onChanged: (v) =>
                              setDlgState(() => sendInvite = v ?? true),
                          activeColor: const Color(0xFF80A416),
                          side: BorderSide(
                            color: isDarkMode
                                ? const Color(0xFF80A416).withOpacity(0.5)
                                : const Color(0xFFCDD4B2),
                            width: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Send invitation email with setup instructions',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12.5,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: forcePasswordChange,
                          onChanged: (v) => setDlgState(
                              () => forcePasswordChange = v ?? true),
                          activeColor: const Color(0xFF80A416),
                          side: BorderSide(
                            color: isDarkMode
                                ? const Color(0xFF80A416).withOpacity(0.5)
                                : const Color(0xFFCDD4B2),
                            width: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Require password change on first login',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12.5,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Expandable Advanced Security Settings
                  InkWell(
                    onTap: () =>
                        setDlgState(() => showAdvanced = !showAdvanced),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            showAdvanced
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 18,
                            color: isDarkMode
                                ? const Color(0xFFC5C764)
                                : const Color(0xFF80A416),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ADVANCED SECURITY SETTINGS',
                            style: GoogleFonts.orbitron(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: isDarkMode
                                  ? const Color(0xFFC5C764)
                                  : const Color(0xFF80A416),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (showAdvanced) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF0A0F0D)
                            : const Color(0xFFFAF9F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF80A416).withOpacity(0.3)
                              : const Color(0xFFCDD4B2),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _modalLabel(
                              'Allowed Source IP Range (CIDR)', isDarkMode),
                          _ModalFieldShell(
                            isDarkMode: isDarkMode,
                            child: TextField(
                              controller: ipCtrl,
                              style: _modalInputTextStyle(isDarkMode),
                              cursorColor: isDarkMode
                                  ? const Color(0xFFC4E320)
                                  : const Color(0xFF0F172A),
                              decoration: _modalInputDeco(
                                  'e.g. 10.128.0.0/16', isDarkMode),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _modalLabel(
                              'Operator Justification Notes', isDarkMode),
                          _ModalFieldShell(
                            isDarkMode: isDarkMode,
                            height: 72,
                            child: TextField(
                              controller: notesCtrl,
                              maxLines: 2,
                              style: _modalInputTextStyle(isDarkMode),
                              cursorColor: isDarkMode
                                  ? const Color(0xFFC4E320)
                                  : const Color(0xFF0F172A),
                              decoration: _modalInputDeco(
                                  'Operational role scope and authorization notes...',
                                  isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),
                  Divider(
                      color: isDarkMode
                          ? const Color(0xFF80A416).withOpacity(0.25)
                          : const Color(0xFFCDD4B2),
                      height: 1),
                  const SizedBox(height: 16),

                  // Actions Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white60
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? const Color(0xFFC4E320)
                              : const Color(0xFFB8A9C1),
                          foregroundColor: isDarkMode
                              ? Colors.black
                              : const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.person_add,
                            size: 16,
                            color: isDarkMode
                                ? Colors.black
                                : const Color(0xFF0F172A)),
                        label: Text(
                          'PROVISION OPERATOR',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.black
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) {
                            setDlgState(
                                () => errorText = 'Operator Name is required');
                            return;
                          }
                          if (!emailCtrl.text.contains('@')) {
                            setDlgState(() => errorText =
                                'Valid corporate email is required');
                            return;
                          }
                          if (passCtrl.text.length < 8) {
                            setDlgState(() => errorText =
                                'Temporary password must be at least 8 characters');
                            return;
                          }
                          if (passCtrl.text != cnfPassCtrl.text) {
                            setDlgState(
                                () => errorText = 'Passwords do not match');
                            return;
                          }

                          setState(() {
                            _operatorsList.insert(0, {
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'role': selectedRole,
                              'status': 'ACTIVE',
                              'lastLogin': 'Pending First Login',
                              'ip': ipCtrl.text.trim(),
                            });
                          });

                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: isDarkMode
                                  ? const Color(0xFF112211)
                                  : const Color(0xFFFAF9F6),
                              content: Text(
                                'Operator ${nameCtrl.text.trim()} provisioned successfully.',
                                style: TextStyle(
                                    color: isDarkMode
                                        ? const Color(0xFF5DD62C)
                                        : const Color(0xFF0F172A)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── MODAL HELPER WIDGETS (MATCHING LOGIN SCREEN) ───────────────────────────
  Widget _modalLabel(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color:
                isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  TextStyle _modalInputTextStyle(bool isDarkMode) {
    return GoogleFonts.spaceGrotesk(
      color: isDarkMode ? const Color(0xFFEDF5EB) : const Color(0xFF0F172A),
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
    );
  }

  InputDecoration _modalInputDeco(String hint, bool isDarkMode) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.spaceGrotesk(
        color: isDarkMode
            ? const Color(0xFF829A80).withOpacity(0.65)
            : const Color(0xFF94A3B8),
        fontSize: 13.0,
      ),
      filled: true,
      fillColor: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }

  void _handleOperatorAction(String action, Map<String, String> operator) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text(
            '$action requested for ${operator['name']} (${operator['email']})',
            style: const TextStyle(color: Color(0xFF5DD62C))),
      ),
    );
    if (action == 'Revoke') {
      setState(() {
        operator['status'] =
            operator['status'] == 'ACTIVE' ? 'REVOKED' : 'ACTIVE';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);

    // Filter active operators
    final filteredOperators = _operatorsList.where((op) {
      if (_roleFilter != 'All Roles' && op['role'] != _roleFilter) {
        if (_roleFilter == 'Admin' && op['role'] != 'Admin') return false;
        if (_roleFilter == 'Engineer' && !op['role']!.contains('Engineer'))
          return false;
        if (_roleFilter == 'Manager' && !op['role']!.contains('Manager'))
          return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = op['name']!.toLowerCase().contains(q) ||
            op['email']!.toLowerCase().contains(q) ||
            op['role']!.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            _buildPageHeader(isDarkMode),
            const SizedBox(height: 16),

            // SECTION 1: Active Operators (Primary Focus Table)
            _buildActiveOperatorsSection(filteredOperators, isDarkMode),
            const SizedBox(height: 20),

            // SECTION 2: Secondary Content (Two Clean Tabs)
            _buildSecondaryTabsSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(bool isDarkMode) {
    return ConsoleRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROLE-BASED ACCESS CONTROL (RBAC)',
              style: CyberTextStyles.displayTitle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDarkMode
                    ? const Color(0xFF5DD62C)
                    : const Color(0xFF80A416),
              ).copyWith(letterSpacing: 2.0),
            ),
            const SizedBox(height: 3),
            Text(
              'Manage operators, roles and access permissions',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? const Color(0xFF80A416) : const Color(0xFFB8A9C1),
            foregroundColor:
                isDarkMode ? Colors.white : const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          icon: Icon(Icons.add,
              size: 18,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
          label: Text(
            '+ PROVISION NEW OPERATOR',
            style: CyberTextStyles.technical(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          onPressed: _showAddUserModal,
        ),
      ],
    );
  }

  // ── SECTION 1: ACTIVE OPERATORS (PRIMARY FOCUS TABLE) ──────────────────────
  Widget _buildActiveOperatorsSection(
      List<Map<String, String>> operators, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: isDarkMode
                ? const Color(0xFF80A416).withOpacity(0.4)
                : const Color(0xFFCDD4B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Search/Filter Toolbar
          ConsoleRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConsoleRow(compact: true,
                children: [
                  Icon(Icons.people_alt_outlined,
                      color: isDarkMode
                          ? const Color(0xFF80A416)
                          : const Color(0xFF0F172A),
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE OPERATORS',
                    style: CyberTextStyles.technical(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF80A416).withOpacity(0.2)
                          : const Color(0xFFEBECCC),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${operators.length} REGISTERED',
                      style: CyberTextStyles.technical(
                        fontSize: 10,
                        color: isDarkMode
                            ? const Color(0xFF80A416)
                            : const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Search & Filter Row
              ConsoleRow(compact: true,
                children: [
                  // Role Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF161616)
                          : const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isDarkMode
                              ? Colors.white24
                              : const Color(0xFFCDD4B2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _roleFilter,
                        dropdownColor:
                            isDarkMode ? const Color(0xFF161616) : Colors.white,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF0F172A)),
                        items: ['All Roles', 'Admin', 'Engineer', 'Manager']
                            .map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _roleFilter = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Search Box
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A)),
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search operators...',
                        hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white38
                                : const Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search,
                            size: 16,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF161616)
                            : const Color(0xFFFAF9F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFCDD4B2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFCDD4B2)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Operators Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF070707) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF222222)
                      : const Color(0xFFCDD4B2)),
            ),
            child: Column(
              children: [
                // Table Header Row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF121212)
                        : const Color(0xFFFAF9F6),
                    border: Border(
                        bottom: BorderSide(
                            color: isDarkMode
                                ? const Color(0xFF252525)
                                : const Color(0xFFCDD4B2),
                            width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('NAME',
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                      Expanded(
                          flex: 4,
                          child: Text('EMAIL',
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                      Expanded(
                          flex: 3,
                          child: Text('ROLE',
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                      Expanded(
                          flex: 2,
                          child: Text('STATUS',
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                      Expanded(
                          flex: 3,
                          child: Text('LAST LOGIN',
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                      Expanded(
                          flex: 3,
                          child: Text('ACTIONS',
                              textAlign: TextAlign.right,
                              style: CyberTextStyles.technical(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF80A416)
                                      : const Color(0xFF0F172A)))),
                    ],
                  ),
                ),

                // Operator Rows
                if (operators.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(
                      child: Text('NO OPERATORS MATCH SEARCH / FILTER',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8))),
                    ),
                  )
                else
                  ...operators.map((op) {
                    final bool isActive = op['status'] == 'ACTIVE';
                    final Color stColor = isActive
                        ? const Color(0xFF5DD62C)
                        : const Color(0xFFDF2531);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF161616)
                                    : const Color(0xFFCDD4B2),
                                width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(op['name']!,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF0F172A)))),
                          Expanded(
                              flex: 4,
                              child: Text(op['email']!,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF334155)))),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8B5CF6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color: const Color(0xFF8B5CF6)
                                          .withOpacity(0.5)),
                                ),
                                child: Text(
                                  op['role']!.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFA88AED)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: stColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color: stColor.withOpacity(0.7)),
                                ),
                                child: Text(
                                  op['status']!,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: stColor),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Text(op['lastLogin']!,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.white54
                                          : const Color(0xFF64748B)))),
                          // Actions column: Edit • Reset Password • Revoke
                          Expanded(
                            flex: 3,
                            child: ConsoleRow(
                              compact: true,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      _handleOperatorAction('Edit Profile', op),
                                  child: Text('Edit',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? const Color(0xFF5DD62C)
                                              : const Color(0xFF80A416),
                                          fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•',
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white30
                                              : const Color(0xFFCBD5E1))),
                                ),
                                InkWell(
                                  onTap: () => _handleOperatorAction(
                                      'Reset Password', op),
                                  child: Text('Reset',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? const Color(0xFFFFE997)
                                              : const Color(0xFFD97706),
                                          fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•',
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white30
                                              : const Color(0xFFCBD5E1))),
                                ),
                                InkWell(
                                  onTap: () =>
                                      _handleOperatorAction('Revoke', op),
                                  child: Text(isActive ? 'Revoke' : 'Restore',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFFDF2531),
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION 2: SECONDARY CONTENT (TWO CLEAN TABS) ─────────────────────────
  Widget _buildSecondaryTabsSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color:
                isDarkMode ? const Color(0xFF252525) : const Color(0xFFCDD4B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar Header
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF252525)
                          : const Color(0xFFCDD4B2),
                      width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: isDarkMode
                  ? const Color(0xFF80A416)
                  : const Color(0xFFB8A9C1),
              labelColor: isDarkMode
                  ? const Color(0xFF80A416)
                  : const Color(0xFF0F172A),
              unselectedLabelColor:
                  isDarkMode ? Colors.white54 : const Color(0xFF64748B),
              labelStyle: CyberTextStyles.technical(
                  fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'TAB 1 – PERMISSIONS MATRIX'),
                Tab(text: 'TAB 2 – SESSION & AUDIT LOG'),
              ],
            ),
          ),

          // Tab Views
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPermissionsMatrixTab(isDarkMode),
                _buildSessionAuditLogTab(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Permissions Matrix (Checkmark Table)
  Widget _buildPermissionsMatrixTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  flex: 5,
                  child: Text('PERMISSION ENTITLEMENT',
                      style: CyberTextStyles.technical(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? const Color(0xFF80A416)
                              : const Color(0xFF0F172A)))),
              Expanded(
                  flex: 2,
                  child: Center(
                      child: Text('ADMIN',
                          style: CyberTextStyles.technical(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A))))),
              Expanded(
                  flex: 2,
                  child: Center(
                      child: Text('SECURITY ENGINEER',
                          style: CyberTextStyles.technical(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A))))),
              Expanded(
                  flex: 2,
                  child: Center(
                      child: Text('MANAGER',
                          style: CyberTextStyles.technical(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A))))),
            ],
          ),
          Divider(
              color: isDarkMode
                  ? const Color(0xFF252525)
                  : const Color(0xFFCDD4B2),
              height: 16),
          ..._permissionsMatrix.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: isDarkMode
                            ? const Color(0xFF161616)
                            : const Color(0xFFCDD4B2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item['permission'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['admin'] == true
                          ? const Icon(Icons.check_circle,
                              size: 16, color: Color(0xFF5DD62C))
                          : Icon(Icons.remove,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['engineer'] == true
                          ? const Icon(Icons.check_circle,
                              size: 16, color: Color(0xFF5DD62C))
                          : Icon(Icons.remove,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['manager'] == true
                          ? const Icon(Icons.check_circle,
                              size: 16, color: Color(0xFF5DD62C))
                          : Icon(Icons.remove,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Tab 2: Session & Audit Log (Full-Width Table)
  Widget _buildSessionAuditLogTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF252525)
                          : const Color(0xFFCDD4B2))),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('TIMESTAMP',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)))),
                Expanded(
                    flex: 3,
                    child: Text('USER',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)))),
                Expanded(
                    flex: 5,
                    child: Text('ACTION',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)))),
                Expanded(
                    flex: 3,
                    child: Text('IP ADDRESS',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)))),
                Expanded(
                    flex: 2,
                    child: Text('STATUS',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF80A416)
                                : const Color(0xFF0F172A)))),
              ],
            ),
          ),
          ..._sessionAudits.map((item) {
            final bool isOk = item['status'] == 'SUCCESS';
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: isDarkMode
                            ? const Color(0xFF161616)
                            : const Color(0xFFCDD4B2))),
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(item['time']!,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDarkMode
                                  ? const Color(0xFFC5C764)
                                  : const Color(0xFF80A416)))),
                  Expanded(
                      flex: 3,
                      child: Text(item['user']!,
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A)))),
                  Expanded(
                      flex: 5,
                      child: Text(item['action']!,
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF334155)))),
                  Expanded(
                      flex: 3,
                      child: Text(item['ip']!,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12, color: const Color(0xFFA88AED)))),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isOk
                                  ? const Color(0xFF5DD62C)
                                  : const Color(0xFFDF2531))
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item['status']!,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOk
                                  ? const Color(0xFF5DD62C)
                                  : const Color(0xFFDF2531)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// MODAL VR FRAME & FIELD SHELLS (MATCHING LOGIN FORM STYLE)
// ═════════════════════════════════════════════════════════════

class _ModalVrFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool isDarkMode;

  const _ModalVrFrame({
    super.key,
    required this.child,
    this.maxWidth = 680,
    this.padding,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final frameBg = isDarkMode ? const Color(0xFF050A07) : Colors.white;
    final frameBorder =
        isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF80A416);
    final tabColor =
        isDarkMode ? const Color(0xFF80A416) : const Color(0xFFC4E320);

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
                    color: isDarkMode
                        ? const Color(0xFFC5C764).withOpacity(0.2)
                        : const Color(0xFF80A416).withOpacity(0.18),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: isDarkMode
                        ? const Color(0xFF80A416).withOpacity(0.08)
                        : const Color(0xFF80A416).withOpacity(0.06),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: _ModalVrFrameClipper(cut: 16),
                child: Container(
                  color: frameBg,
                  padding: padding ?? const EdgeInsets.fromLTRB(28, 26, 28, 24),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(32, 7),
                          painter: _ModalStripePainter(isDarkMode: isDarkMode),
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
                    Container(
                        width: 18,
                        height: 1.5,
                        color: frameBorder.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ClipPath(
                      clipper: _ModalNotchClipper(),
                      child: Container(width: 56, height: 8, color: tabColor),
                    ),
                    const SizedBox(width: 4),
                    Container(
                        width: 18,
                        height: 1.5,
                        color: frameBorder.withOpacity(0.6)),
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
                          child: Container(
                              width: 1.5, height: 36, color: frameBorder),
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
                          child: Container(
                              width: 1.5, height: 36, color: frameBorder),
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

class _ModalVrFrameClipper extends CustomClipper<Path> {
  final double cut;
  _ModalVrFrameClipper({this.cut = 18});

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

class _ModalNotchClipper extends CustomClipper<Path> {
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

class _ModalStripePainter extends CustomPainter {
  final bool isDarkMode;
  _ModalStripePainter({this.isDarkMode = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? const Color(0xFF80A416) : const Color(0xFF80A416))
          .withOpacity(0.55)
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

class _ModalFieldShell extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  final double? height;

  const _ModalFieldShell({
    super.key,
    required this.child,
    this.isDarkMode = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ModalFieldClipper(),
      child: Container(
        height: height ?? 48,
        alignment: height != null ? Alignment.topLeft : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF80A416).withOpacity(0.35)
                : const Color(0xFFCDD4B2),
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ModalFieldClipper extends CustomClipper<Path> {
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
