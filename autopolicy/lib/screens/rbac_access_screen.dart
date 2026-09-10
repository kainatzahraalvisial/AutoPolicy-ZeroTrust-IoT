import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/cyber_hud_card.dart';

/// Role-Based Access Control (RBAC) Dedicated Full-Page View
class RbacAccessScreen extends ConsumerStatefulWidget {
  const RbacAccessScreen({super.key});

  @override
  ConsumerState<RbacAccessScreen> createState() => _RbacAccessScreenState();
}

class _RbacAccessScreenState extends ConsumerState<RbacAccessScreen> {
  // Mock list of active administrator/engineer profiles
  final List<Map<String, String>> _usersList = [
    {'name': 'ADMINISTRATOR', 'email': 'admin@autopolicy.gov', 'role': 'Admin', 'status': 'ACTIVE', 'ip': '10.128.4.102'},
    {'name': 'SEC-ENGINEER-1', 'email': 'engineer@autopolicy.gov', 'role': 'Security Engineer', 'status': 'ACTIVE', 'ip': '10.128.4.155'},
    {'name': 'COMPLIANCE-MGR', 'email': 'manager@autopolicy.gov', 'role': 'Manager', 'status': 'ACTIVE', 'ip': '10.128.8.21'},
    {'name': 'SEC-AUDITOR-TEMP', 'email': 'auditor@autopolicy.gov', 'role': 'Manager', 'status': 'REVOKED', 'ip': '192.168.1.84'},
  ];

  // RBAC permissions state checkboxes
  final Map<String, bool> _rbacSettings = {
    'GNN network telemetry mapping': true,
    'Policy generation via sec-ML transformers': true,
    'Physical device quarantine operations': true,
    'Forced cyber attack injections': false,
    'OPA Sidecar Rego manual compilation': true,
    'API gateway system overrides': false,
  };

  // Mock session audit ledger entries
  final List<Map<String, String>> _sessionAudits = [
    {'time': '11:54:21', 'user': 'ADMIN', 'action': 'INITIATED MANUAL INJECTION', 'status': 'SUCCESS'},
    {'time': '11:15:02', 'user': 'SEC-ENGINEER-1', 'action': 'COMPILED OPA POL-4821', 'status': 'SUCCESS'},
    {'time': '10:45:11', 'user': 'COMPLIANCE-MGR', 'action': 'EXPORTED SOC2 LEDGER', 'status': 'SUCCESS'},
    {'time': '09:02:18', 'user': 'ADMIN', 'action': 'CHANGED SECURITY THRESHOLD', 'status': 'SUCCESS'},
    {'time': '08:12:00', 'user': 'AUDITOR', 'action': 'ATTEMPTED COMPACT COMPILE', 'status': 'DENIED'},
  ];

  void _showAddUserModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'Security Engineer';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF80A416), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.person_add, color: Color(0xFF80A416)),
            const SizedBox(width: 10),
            Text('REGISTER NEW SOC OPERATOR', style: CyberTextStyles.heading3),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: CyberTextStyles.techBody,
                decoration: const InputDecoration(labelText: 'OPERATOR NAME / ID'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                style: CyberTextStyles.techBody,
                decoration: const InputDecoration(labelText: 'GOV / CORP EMAIL'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF0F0F14),
                style: CyberTextStyles.techBody,
                decoration: const InputDecoration(labelText: 'ASSIGNED RBAC ROLE'),
                items: ['Admin', 'Security Engineer', 'Manager'].map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: CyberTextStyles.technical(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _usersList.add({
                    'name': nameCtrl.text.toUpperCase(),
                    'email': emailCtrl.text,
                    'role': selectedRole,
                    'status': 'ACTIVE',
                    'ip': '10.128.5.${100 + _usersList.length}',
                  });
                });
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF80A416)),
            child: Text('PROVISION ACCESS', style: CyberTextStyles.technical(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header with Provision Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROLE-BASED ACCESS CONTROL (RBAC)', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('ZERO-TRUST IDENTITY DIRECTORY, PERMISSIONS MATRIX & AUDIT LOGS', style: CyberTextStyles.techMuted),
                  ],
                ),
                NeonButton(
                  text: 'PROVISION NEW OPERATOR',
                  onPressed: _showAddUserModal,
                  icon: Icons.person_add_outlined,
                  color: const Color(0xFF80A416),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main 2-Column Split: Operator Directory & Permissions Grid
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildUsersTable(),
                  const SizedBox(height: 16),
                  _buildPermissionsGrid(),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildUsersTable()),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _buildPermissionsGrid()),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-Time Session Audit Ledger
            Text('REAL-TIME SESSION AUDIT LOGGING', style: CyberTextStyles.technical(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFC4E320))),
            const SizedBox(height: 10),
            _buildAuditConsole(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    return CyberHudCard(
      tag: 'H17',
      borderColor: const Color(0xFFFFE997),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE SOC OPERATOR DIRECTORY',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Divider(color: const Color(0xFFFFE997).withOpacity(0.3)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _usersList.length,
            itemBuilder: (context, idx) {
              final user = _usersList[idx];
              final isActive = user['status'] == 'ACTIVE';
              final Color statusColor = isActive ? const Color(0xFFC4E320) : CyberColors.alertRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  showHUDCorners: false,
                  borderRadius: 4.0,
                  borderColor: CyberColors.neonCyan,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user['name']!,
                                  style: CyberTextStyles.technical(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA88AED).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(color: const Color(0xFFA88AED)),
                                  ),
                                  child: Text(
                                    user['role']!.toUpperCase(),
                                    style: CyberTextStyles.technical(fontSize: 8.5, color: const Color(0xFFA88AED), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email']!,
                              style: CyberTextStyles.interface(fontSize: 9.5, color: CyberColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user['ip']!,
                            style: CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user['status']!,
                                style: CyberTextStyles.technical(fontSize: 9.0, color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsGrid() {
    return CyberHudCard(
      tag: 'H18',
      borderColor: const Color(0xFFA88AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROLE PERMISSIONS POLICY MATRIX',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Divider(color: const Color(0xFFA88AED).withOpacity(0.3)),
          const SizedBox(height: 8),
          ..._rbacSettings.keys.map((permKey) {
            final isEnabled = _rbacSettings[permKey]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFC4E320),
                checkColor: Colors.black,
                title: Text(
                  permKey.toUpperCase(),
                  style: CyberTextStyles.technical(fontSize: 10.5, color: isEnabled ? Colors.white : CyberColors.textMuted),
                ),
                value: isEnabled,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _rbacSettings[permKey] = val;
                    });
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAuditConsole() {
    return CyberHudCard(
      tag: 'H19',
      borderColor: const Color(0xFFC4E320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE RBAC SECURITY AUDIT STREAM',
                style: CyberTextStyles.technical(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'VERIFIED BY CRYPTOGRAPHIC LOG HASH',
                style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0),
              ),
            ],
          ),
          Divider(color: const Color(0xFFC4E320).withOpacity(0.3)),
          const SizedBox(height: 8),
          ..._sessionAudits.map((audit) {
            final isDenied = audit['status'] == 'DENIED';
            final statusColor = isDenied ? CyberColors.alertRed : const Color(0xFFC4E320);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('[${audit['time']}]', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
                      const SizedBox(width: 8),
                      Text(audit['user']!, style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFFA88AED), fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('-> ${audit['action']}', style: CyberTextStyles.technical(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(audit['status']!, style: CyberTextStyles.technical(fontSize: 8.5, color: statusColor, fontWeight: FontWeight.bold)),
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
