import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';

class SettingsManagement extends ConsumerStatefulWidget {
  const SettingsManagement({super.key});

  @override
  ConsumerState<SettingsManagement> createState() => _SettingsManagementState();
}

class _SettingsManagementState extends ConsumerState<SettingsManagement> {
  final TextEditingController _webhookController = TextEditingController(text: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX');
  bool _isTestingWebhook = false;
  String _webhookStatus = '';
  
  // API key state
  String _generatedApiKey = '';
  bool _showApiKey = false;

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
    'Forced cyber attack injections': false, // requires admin override
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

  void _generateNewApiKey() {
    final Random random = Random();
    final bytes = List.generate(24, (_) => random.nextInt(256));
    final String key = 'ap_sec_token_' + bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').substring(0, 32);
    setState(() {
      _generatedApiKey = key;
      _showApiKey = true;
    });
  }

  void _testWebhook() {
    if (_isTestingWebhook) return;
    setState(() {
      _isTestingWebhook = true;
      _webhookStatus = 'TRANSMITTING SIMULATED OPA EXPLOIT SCHEME...';
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTestingWebhook = false;
        _webhookStatus = 'WEBHOOK TEST VERIFIED (HTTP 200 OK)';
      });
      ref.read(securityProvider.notifier).toggleSimulation(ref.read(securityProvider).isSimulating);
    });
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
            // Headings
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USER ACCESS & RBAC CONTROLS', style: CyberTextStyles.heading2),
                const SizedBox(height: 4),
                Text('ROLE-BASED PERMISSIONS, CRITICAL INTEGRATIONS, AND AUDITING', style: CyberTextStyles.techMuted),
              ],
            ),
            const SizedBox(height: 20),

            // Two pane or single column based on responsiveness
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildUsersTable(),
                  const SizedBox(height: 16),
                  _buildPermissionsGrid(),
                  const SizedBox(height: 16),
                  _buildIntegrationsCard(),
                  const SizedBox(height: 16),
                  _buildAuditConsole(),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left col: Users and permissions
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildUsersTable(),
                        const SizedBox(height: 16),
                        _buildPermissionsGrid(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right col: Webhooks, API keys, Session Logs
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildIntegrationsCard(),
                        const SizedBox(height: 16),
                        _buildAuditConsole(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE SOC ACCOUNTS REGISTER',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _usersList.length,
            itemBuilder: (context, idx) {
              final user = _usersList[idx];
              final isActive = user['status'] == 'ACTIVE';
              final Color statusColor = isActive ? CyberColors.neonGreen : CyberColors.alertRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                                    color: CyberColors.panelBg,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    user['role']!.toUpperCase(),
                                    style: CyberTextStyles.technical(fontSize: 8.0, color: CyberColors.neonCyan),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email']!,
                              style: CyberTextStyles.interface(fontSize: 9.0, color: CyberColors.textMuted),
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
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROLE-BASED ACCESS SEGREGATION MAP',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rbacSettings.length,
            itemBuilder: (context, idx) {
              final String key = _rbacSettings.keys.elementAt(idx);
              final bool val = _rbacSettings[key]!;

              return CheckboxListTile(
                title: Text(
                  key.toUpperCase(),
                  style: CyberTextStyles.technical(fontSize: 10.0, color: Colors.white),
                ),
                subtitle: Text(
                  val ? 'AUTHORIZED FOR SEC-ENGINEERS & ADMINS' : 'RESTRICTED SYSTEM SCOPE',
                  style: CyberTextStyles.interface(fontSize: 9.0, color: CyberColors.textMuted),
                ),
                value: val,
                activeColor: CyberColors.neonGreen,
                checkColor: Colors.black,
                side: const BorderSide(color: CyberColors.borderNeonCyan),
                onChanged: (newVal) {
                  setState(() {
                    _rbacSettings[key] = newVal ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsCard() {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REST INTEGRATION & DEPLOYMENT API KEYS',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 12),
          // API Key Generator panel
          Text(
            'JWT AUDITOR SYNC KEY',
            style: CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  showHUDCorners: false,
                  borderRadius: 4.0,
                  borderColor: CyberColors.neonCyan,
                  child: Text(
                    _generatedApiKey.isEmpty
                        ? 'NO KEY GENERATED'
                        : (_showApiKey ? _generatedApiKey : '••••••••••••••••••••••••••••••••'),
                    style: CyberTextStyles.technical(
                      fontSize: 10.0,
                      color: _generatedApiKey.isEmpty ? CyberColors.textMuted : CyberColors.neonGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_generatedApiKey.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _showApiKey ? Icons.visibility_off : Icons.visibility,
                    color: CyberColors.neonCyan,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          NeonButton(
            text: _generatedApiKey.isEmpty ? 'GENERATE INTEGRATION TOKEN' : 'RE-KEY TOKEN',
            onPressed: _generateNewApiKey,
            icon: Icons.key_outlined,
          ),
          const SizedBox(height: 16),

          // Webhook trigger configuration
          Text(
            'OPA ALERT EXPLOIT SLACK WEBHOOK FORWARDER',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _webhookController,
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 10.0),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: CyberColors.borderNeonCyan),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: CyberColors.neonCyan),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeonButton(
                text: 'TEST WEBHOOK FORWARDER',
                onPressed: _testWebhook,
                icon: Icons.cell_tower_outlined,
                color: CyberColors.neonCyan,
              ),
              if (_isTestingWebhook)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(CyberColors.neonCyan)),
                ),
            ],
          ),
          if (_webhookStatus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _webhookStatus.toUpperCase(),
              style: CyberTextStyles.technical(
                fontSize: 9.0,
                color: _webhookStatus.contains('VERIFIED') ? CyberColors.neonGreen : CyberColors.warningOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditConsole() {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'USER SESSION AUDIT LOGS',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sessionAudits.length,
            itemBuilder: (context, idx) {
              final audit = _sessionAudits[idx];
              final isSuccess = audit['status'] == 'SUCCESS';
              final Color stateColor = isSuccess ? CyberColors.neonGreen : CyberColors.alertRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(8),
                  showHUDCorners: false,
                  borderRadius: 4.0,
                  borderColor: stateColor,
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
                                '[${audit['time']}]',
                                style: CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.neonCyan),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                audit['user']!,
                                style: CyberTextStyles.technical(fontSize: 9.0, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            audit['action']!,
                            style: CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      audit['status']!,
                      style: CyberTextStyles.technical(fontSize: 8.0, color: stateColor, fontWeight: FontWeight.bold),
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
}
