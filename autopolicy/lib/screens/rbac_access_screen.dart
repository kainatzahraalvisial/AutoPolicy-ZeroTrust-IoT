import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';

/// Role-Based Access Control (RBAC) – Redesigned Layout
/// Section 1: Active Operators (Primary Focus Table with Search & Filter)
/// Section 2: Secondary Content (Two Tabs: Permissions Matrix & Session/Audit Log)
class RbacAccessScreen extends ConsumerStatefulWidget {
  const RbacAccessScreen({super.key});

  @override
  ConsumerState<RbacAccessScreen> createState() => _RbacAccessScreenState();
}

class _RbacAccessScreenState extends ConsumerState<RbacAccessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All Roles';
  int _operatorPage = 1;
  static const int _operatorPageSize = 6;

  // Active Operators List
  final List<Map<String, String>> _operatorsList = [
    {
      'name': 'Kainat Alvi',
      'email': 'kainat.alvi@autopolicy.internal',
      'role': 'Admin',
      'status': 'ACTIVE',
      'lastLogin': 'Today, 09:42 UTC',
      'ip': '192.168.1.105',
    },
    {
      'name': 'Ava Chen',
      'email': 'a.chen@autopolicy.internal',
      'role': 'Security Engineer',
      'status': 'ACTIVE',
      'lastLogin': 'Today, 08:15 UTC',
      'ip': '10.128.4.155',
    },
    {
      'name': 'Marcus Vance',
      'email': 'm.vance@autopolicy.internal',
      'role': 'Manager',
      'status': 'ACTIVE',
      'lastLogin': 'Yesterday, 18:30 UTC',
      'ip': '10.128.8.21',
    },
    {
      'name': 'Elena Rostova',
      'email': 'e.rostova@autopolicy.internal',
      'role': 'Security Engineer',
      'status': 'ACTIVE',
      'lastLogin': 'Sep 10, 14:22 UTC',
      'ip': '10.128.4.190',
    },
    {
      'name': 'David Kim',
      'email': 'd.kim@autopolicy.internal',
      'role': 'Admin',
      'status': 'ACTIVE',
      'lastLogin': 'Sep 09, 11:05 UTC',
      'ip': '192.168.1.112',
    },
    {
      'name': 'Dev Audit Temp',
      'email': 'audit.temp@autopolicy.internal',
      'role': 'Manager',
      'status': 'REVOKED',
      'lastLogin': 'Aug 28, 16:00 UTC',
      'ip': '192.168.1.84',
    },
  ];

  // Permissions Matrix Definition (Rows = Permissions, Columns = Roles)
  final List<Map<String, dynamic>> _permissionsMatrix = [
    {
      'permission': 'GNN Graph & Telemetry Inspection',
      'admin': true,
      'engineer': true,
      'manager': true,
    },
    {
      'permission': 'Manual & Automated Policy Generation',
      'admin': true,
      'engineer': true,
      'manager': false,
    },
    {
      'permission': 'OPA Rego Policy Deployment to Sidecars',
      'admin': true,
      'engineer': true,
      'manager': false,
    },
    {
      'permission': 'Physical IoT Device Quarantine Operations',
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
    {'time': '2026-09-12 15:20:12', 'user': 'kainat.alvi', 'action': 'POLICY DEPLOYMENT (MODBUS-04)', 'ip': '192.168.1.105', 'status': 'SUCCESS'},
    {'time': '2026-09-12 14:10:44', 'user': 'kainat.alvi', 'action': 'OPERATOR LOGIN VIA HARDWARE MFA', 'ip': '192.168.1.105', 'status': 'SUCCESS'},
    {'time': '2026-09-12 13:52:19', 'user': 'a.chen', 'action': 'DEVICE ISOLATION TRIGGERED (#88)', 'ip': '10.128.4.155', 'status': 'SUCCESS'},
    {'time': '2026-09-12 12:45:10', 'user': 'kainat.alvi', 'action': 'REJECTED DRAFT REGO RULE (#POL-08)', 'ip': '192.168.1.105', 'status': 'SUCCESS'},
    {'time': '2026-09-12 10:45:11', 'user': 'm.vance', 'action': 'EXPORTED REGULATORY SOC2 REPORT', 'ip': '10.128.8.21', 'status': 'SUCCESS'},
    {'time': '2026-09-12 09:02:18', 'user': 'kainat.alvi', 'action': 'ADJUSTED GNN DETECTION THRESHOLD', 'ip': '192.168.1.105', 'status': 'SUCCESS'},
    {'time': '2026-09-12 08:12:00', 'user': 'audit.temp', 'action': 'ATTEMPTED UNAUTHORIZED COMPILE', 'ip': '192.168.1.84', 'status': 'DENIED'},
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
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'SOC Incident Response');
    final passCtrl = TextEditingController();
    final cnfPassCtrl = TextEditingController();
    final ipCtrl = TextEditingController(text: '10.128.0.0/16');
    final notesCtrl = TextEditingController();
    
    String selectedRole = 'Security Engineer';
    String selectedExpiry = '90 Days';
    bool sendInvite = true;
    bool forcePasswordChange = true;
    bool showAdvanced = false;
    bool obscurePass = true;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF80A416), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF80A416).withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_add_outlined, color: Color(0xFF80A416), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'PROVISION NEW OPERATOR',
                            style: CyberTextStyles.heading2.copyWith(fontSize: 15, color: const Color(0xFF80A416)),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  Text(
                    'ZERO-TRUST IDENTITY PROVISIONING · STRICT RBAC ENFORCED',
                    style: CyberTextStyles.techMuted.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF252525)),
                  const SizedBox(height: 10),

                  if (errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x33DF2531),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFDF2531)),
                      ),
                      child: Text(
                        errorText!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFFF6666)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          style: CyberTextStyles.techBody,
                          decoration: const InputDecoration(labelText: 'FULL NAME / IDENTITY'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          style: CyberTextStyles.techBody,
                          decoration: const InputDecoration(labelText: 'ORGANIZATION EMAIL'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SYSTEM ROLE', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRole,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF161616),
                                  style: CyberTextStyles.techBody,
                                  items: ['Administrator', 'Security Engineer', 'Manager'].map((r) {
                                    return DropdownMenuItem(value: r, child: Text(r));
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) setDlgState(() => selectedRole = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: deptCtrl,
                          style: CyberTextStyles.techBody,
                          decoration: const InputDecoration(labelText: 'DEPARTMENT / UNIT'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passCtrl,
                          obscureText: obscurePass,
                          style: CyberTextStyles.techBody,
                          decoration: InputDecoration(
                            labelText: 'TEMPORARY PASSWORD',
                            suffixIcon: IconButton(
                              icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: 16, color: Colors.white54),
                              onPressed: () => setDlgState(() => obscurePass = !obscurePass),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cnfPassCtrl,
                          obscureText: obscurePass,
                          style: CyberTextStyles.techBody,
                          decoration: const InputDecoration(labelText: 'CONFIRM PASSWORD'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  CheckboxListTile(
                    value: sendInvite,
                    onChanged: (v) => setDlgState(() => sendInvite = v ?? true),
                    title: Text('Send invitation email with setup instructions', style: CyberTextStyles.technical(fontSize: 11, color: Colors.white)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  CheckboxListTile(
                    value: forcePasswordChange,
                    onChanged: (v) => setDlgState(() => forcePasswordChange = v ?? true),
                    title: Text('Require password change on first login', style: CyberTextStyles.technical(fontSize: 11, color: Colors.white)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () => setDlgState(() => showAdvanced = !showAdvanced),
                    child: Row(
                      children: [
                        Icon(showAdvanced ? Icons.expand_less : Icons.expand_more, size: 18, color: const Color(0xFF80A416)),
                        const SizedBox(width: 4),
                        Text('ADVANCED SECURITY SETTINGS', style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFF80A416), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  if (showAdvanced) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: ipCtrl,
                            style: CyberTextStyles.techBody,
                            decoration: const InputDecoration(labelText: 'ALLOWED SOURCE IP RANGE (CIDR)'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: notesCtrl,
                            style: CyberTextStyles.techBody,
                            decoration: const InputDecoration(labelText: 'OPERATOR JUSTIFICATION NOTES'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('CANCEL', style: CyberTextStyles.technical(color: Colors.white54)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF80A416)),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) {
                            setDlgState(() => errorText = 'Operator Name is required');
                            return;
                          }
                          if (!emailCtrl.text.contains('@')) {
                            setDlgState(() => errorText = 'Valid corporate email is required');
                            return;
                          }
                          if (passCtrl.text.length < 8) {
                            setDlgState(() => errorText = 'Temporary password must be at least 8 characters');
                            return;
                          }
                          if (passCtrl.text != cnfPassCtrl.text) {
                            setDlgState(() => errorText = 'Passwords do not match');
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
                              backgroundColor: const Color(0xFF112211),
                              content: Text('Operator ${nameCtrl.text.trim()} provisioned successfully.', style: const TextStyle(color: Color(0xFF5DD62C))),
                            ),
                          );
                        },
                        child: Text(
                          'PROVISION OPERATOR',
                          style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }

  void _handleOperatorAction(String action, Map<String, String> operator) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text('$action requested for ${operator['name']} (${operator['email']})', style: const TextStyle(color: Color(0xFF5DD62C))),
      ),
    );
    if (action == 'Revoke') {
      setState(() {
        operator['status'] = operator['status'] == 'ACTIVE' ? 'REVOKED' : 'ACTIVE';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter active operators
    final filteredOperators = _operatorsList.where((op) {
      if (_roleFilter != 'All Roles' && op['role'] != _roleFilter) {
        if (_roleFilter == 'Admin' && op['role'] != 'Admin') return false;
        if (_roleFilter == 'Engineer' && !op['role']!.contains('Engineer')) return false;
        if (_roleFilter == 'Manager' && !op['role']!.contains('Manager')) return false;
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
            _buildPageHeader(),
            const SizedBox(height: 16),

            // SECTION 1: Active Operators (Primary Focus Table)
            _buildActiveOperatorsSection(filteredOperators),
            const SizedBox(height: 20),

            // SECTION 2: Secondary Content (Two Clean Tabs)
            _buildSecondaryTabsSection(),
          ],
        ),
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Row(
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
                color: const Color(0xFF5DD62C),
              ).copyWith(letterSpacing: 2.0),
            ),
            const SizedBox(height: 3),
            Text(
              'Manage operators, roles and access permissions',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF80A416),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            '+ PROVISION NEW OPERATOR',
            style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: _showAddUserModal,
        ),
      ],
    );
  }

  // ── SECTION 1: ACTIVE OPERATORS (PRIMARY FOCUS TABLE) ──────────────────────
  Widget _buildActiveOperatorsSection(List<Map<String, String>> operators) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF80A416).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Search/Filter Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF80A416), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE OPERATORS',
                    style: CyberTextStyles.technical(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF80A416).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${operators.length} REGISTERED',
                      style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFF80A416), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Search & Filter Row
              Row(
                children: [
                  // Role Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _roleFilter,
                        dropdownColor: const Color(0xFF161616),
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                        items: ['All Roles', 'Admin', 'Engineer', 'Manager'].map((r) {
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
                      style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search operators...',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF80A416)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.white24)),
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
              color: const Color(0xFF070707),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            child: Column(
              children: [
                // Table Header Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    border: Border(bottom: BorderSide(color: Color(0xFF252525), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('NAME', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                      Expanded(flex: 4, child: Text('EMAIL', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                      Expanded(flex: 3, child: Text('ROLE', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                      Expanded(flex: 2, child: Text('STATUS', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                      Expanded(flex: 3, child: Text('LAST LOGIN', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                      Expanded(flex: 3, child: Text('ACTIONS', textAlign: TextAlign.right, style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                    ],
                  ),
                ),

                // Operator Rows
                if (operators.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(
                      child: Text('NO OPERATORS MATCH SEARCH / FILTER', style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
                    ),
                  )
                else
                  ...operators.map((op) {
                    final bool isActive = op['status'] == 'ACTIVE';
                    final Color stColor = isActive ? const Color(0xFF5DD62C) : const Color(0xFFDF2531);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF161616), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(op['name']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                          Expanded(flex: 4, child: Text(op['email']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white70))),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                                ),
                                child: Text(
                                  op['role']!.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFA88AED)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: stColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: stColor.withOpacity(0.7)),
                                ),
                                child: Text(
                                  op['status']!,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.bold, color: stColor),
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: Text(op['lastLogin']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white54))),
                          // Actions column: Edit • Reset Password • Revoke
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () => _handleOperatorAction('Edit Profile', op),
                                  child: Text('Edit', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5DD62C), fontWeight: FontWeight.w600)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•', style: TextStyle(color: Colors.white30)),
                                ),
                                InkWell(
                                  onTap: () => _handleOperatorAction('Reset Password', op),
                                  child: Text('Reset', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFFE997), fontWeight: FontWeight.w600)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•', style: TextStyle(color: Colors.white30)),
                                ),
                                InkWell(
                                  onTap: () => _handleOperatorAction('Revoke', op),
                                  child: Text(isActive ? 'Revoke' : 'Restore', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFDF2531), fontWeight: FontWeight.w600)),
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
  Widget _buildSecondaryTabsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar Header
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF252525), width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF80A416),
              labelColor: const Color(0xFF80A416),
              unselectedLabelColor: Colors.white54,
              labelStyle: CyberTextStyles.technical(fontSize: 12, fontWeight: FontWeight.bold),
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
                _buildPermissionsMatrixTab(),
                _buildSessionAuditLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Permissions Matrix (Checkmark Table)
  Widget _buildPermissionsMatrixTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(flex: 5, child: Text('PERMISSION ENTITLEMENT', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
              Expanded(flex: 2, child: Center(child: Text('ADMIN', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)))),
              Expanded(flex: 2, child: Center(child: Text('SECURITY ENGINEER', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)))),
              Expanded(flex: 2, child: Center(child: Text('MANAGER', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)))),
            ],
          ),
          const Divider(color: Color(0xFF252525), height: 16),
          ..._permissionsMatrix.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF161616))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item['permission'] as String,
                      style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['admin'] == true
                          ? const Icon(Icons.check_circle, size: 16, color: Color(0xFF5DD62C))
                          : const Icon(Icons.remove, size: 14, color: Colors.white24),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['engineer'] == true
                          ? const Icon(Icons.check_circle, size: 16, color: Color(0xFF5DD62C))
                          : const Icon(Icons.remove, size: 14, color: Colors.white24),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['manager'] == true
                          ? const Icon(Icons.check_circle, size: 16, color: Color(0xFF5DD62C))
                          : const Icon(Icons.remove, size: 14, color: Colors.white24),
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
  Widget _buildSessionAuditLogTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF252525))),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('TIMESTAMP', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                Expanded(flex: 3, child: Text('USER', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                Expanded(flex: 5, child: Text('ACTION', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                Expanded(flex: 3, child: Text('IP ADDRESS', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
                Expanded(flex: 2, child: Text('STATUS', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF80A416)))),
              ],
            ),
          ),
          ..._sessionAudits.map((item) {
            final bool isOk = item['status'] == 'SUCCESS';
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF161616))),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item['time']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: const Color(0xFFC5C764)))),
                  Expanded(flex: 3, child: Text(item['user']!, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 5, child: Text(item['action']!, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70))),
                  Expanded(flex: 3, child: Text(item['ip']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: const Color(0xFFA88AED)))),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isOk ? const Color(0xFF5DD62C) : const Color(0xFFDF2531)).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item['status']!,
                          style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: isOk ? const Color(0xFF5DD62C) : const Color(0xFFDF2531)),
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
