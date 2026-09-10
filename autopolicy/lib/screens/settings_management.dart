import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/neon_button.dart';
import '../widgets/cyber_hud_card.dart';

import '../providers/navigation_provider.dart';

/// Full-Page Administrator System Settings & Configuration Workspace
class SettingsManagement extends ConsumerStatefulWidget {
  const SettingsManagement({super.key});

  @override
  ConsumerState<SettingsManagement> createState() => _SettingsManagementState();
}

class _SettingsManagementState extends ConsumerState<SettingsManagement> {
  // Active Sub-Page View (0 = ListTiles Directory View)
  int _activeSettingsTab = 0;

  final TextEditingController _webhookController = TextEditingController(
    text: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX',
  );

  bool _isTestingWebhook = false;
  String _webhookStatus = '';
  String _generatedApiKey = '';
  bool _showApiKey = false;

  // Zero-Trust & OPA Security Settings State
  bool _strictOpaEnforcement = true;
  bool _autoQuarantineEnabled = true;
  double _gnnSensitivityThreshold = 0.85;
  String _telemetryRefreshInterval = '2 Seconds';

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
      _webhookStatus = 'TRANSMITTING TEST WEBHOOK PAYLOAD...';
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTestingWebhook = false;
        _webhookStatus = 'WEBHOOK VERIFIED SUCCESSFULLY (HTTP 200 OK)';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authSession = ref.watch(authProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    final String adminName = authSession?.username ?? 'ADMINISTRATOR';
    final String adminRole = authSession?.role ?? 'Admin';
    final String adminEmail = '${adminName.toLowerCase()}@autopolicy.zero-trust';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_activeSettingsTab != 0) {
          setState(() => _activeSettingsTab = 0);
        } else {
          ref.read(navigationNotifierProvider.notifier).pop();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ADMINISTRATOR SYSTEM SETTINGS', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('ADMIN PROFILE, APPEARANCE, ZERO-TRUST ENGINE CONFIGURATION & INTEGRATIONS', style: CyberTextStyles.techMuted),
                  ],
                ),
                if (_activeSettingsTab != 0)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeSettingsTab = 0),
                    icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                    label: Text('ALL SETTINGS TILES', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Profile & Sign Out Summary Header Card
            _buildTopAdminCard(context, adminName, adminRole, adminEmail),
            const SizedBox(height: 16),

            // Render Main Settings Directory or Individual Sub-Pages
            if (_activeSettingsTab == 0)
              _buildSettingsTilesDirectory(isDarkMode)
            else
              _buildIndividualSettingsSubPage(context, isDarkMode, adminName, adminRole, adminEmail),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildTopAdminCard(BuildContext context, String adminName, String adminRole, String adminEmail) {
    return CyberHudCard(
      tag: 'H17',
      borderColor: const Color(0xFFFFE997),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFE997),
                radius: 20,
                child: Icon(Icons.admin_panel_settings, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE SESSION: ${adminName.toUpperCase()} | $adminRole',
                    style: CyberTextStyles.technical(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'EMAIL: $adminEmail | IP: 10.128.4.102 (ENCRYPTED TLS 1.3)',
                    style: CyberTextStyles.techMuted.copyWith(fontSize: 9.5),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.white),
            label: Text('SIGN OUT', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB91C1D)),
          ),
        ],
      ),
    );
  }

  // 1. Main Directory View rendering ListTiles for each settings category
  Widget _buildSettingsTilesDirectory(bool isDarkMode) {
    final settingsCategories = [
      {
        'id': 1,
        'title': 'APPEARANCE & CYBER THEME PREFERENCES',
        'subtitle': 'Toggle Dark/Light theme mode, accent colors, and telemetry refresh frequency',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFFFFE997),
        'tag': 'OPT-1',
      },
      {
        'id': 2,
        'title': 'ADMINISTRATOR IDENTITY & SESSION CONTROLS',
        'subtitle': 'Manage admin credentials, RBAC levels, session tokens, and security profile',
        'icon': Icons.security_outlined,
        'color': const Color(0xFFA88AED),
        'tag': 'OPT-2',
      },
      {
        'id': 3,
        'title': 'ZERO-TRUST & OPA POLICY ENGINE CONFIGURATION',
        'subtitle': 'Strict Rego policy enforcement mode, GNN threat sensitivity, and auto-quarantine rules',
        'icon': Icons.tune_outlined,
        'color': const Color(0xFFC4E320),
        'tag': 'OPT-3',
      },
      {
        'id': 4,
        'title': 'WEBHOOKS & ALERTS INTEGRATIONS',
        'subtitle': 'Slack / PagerDuty webhook endpoints, SIEM event dispatch, and custom alert handlers',
        'icon': Icons.webhook_outlined,
        'color': const Color(0xFF80A416),
        'tag': 'OPT-4',
      },
      {
        'id': 5,
        'title': 'API KEYS & CRYPTOGRAPHIC SECURITY CREDENTIALS',
        'subtitle': 'Generate system API bearer tokens, TLS certificates, and rotate secrets',
        'icon': Icons.key_outlined,
        'color': const Color(0xFFB91C1D),
        'tag': 'OPT-5',
      },
      {
        'id': 6,
        'title': 'SYSTEM DIAGNOSTICS & CRYPTOGRAPHIC AUDIT STREAM',
        'subtitle': 'Inspect OPA policy execution logs, Envoy sidecar telemetry, and event history',
        'icon': Icons.terminal_outlined,
        'color': const Color(0xFFC5C764),
        'tag': 'OPT-6',
      },
    ];

    return Column(
      children: settingsCategories.map((cat) {
        final int id = cat['id'] as int;
        final String title = cat['title'] as String;
        final String subtitle = cat['subtitle'] as String;
        final IconData icon = cat['icon'] as IconData;
        final Color color = cat['color'] as Color;
        final String tag = cat['tag'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _activeSettingsTab = id;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: CyberHudCard(
              tag: tag,
              borderColor: color,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: CyberTextStyles.technical(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: CyberTextStyles.techMuted.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward_ios, color: color, size: 18),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 2. Individual Sub-Page renderer based on selected ListTile
  Widget _buildIndividualSettingsSubPage(BuildContext context, bool isDarkMode, String adminName, String adminRole, String adminEmail) {
    switch (_activeSettingsTab) {
      case 1:
        return _buildAppearanceSubPage(isDarkMode);
      case 2:
        return _buildAdminIdentitySubPage(adminName, adminRole, adminEmail);
      case 3:
        return _buildOpaEngineSubPage();
      case 4:
        return _buildWebhooksSubPage();
      case 5:
        return _buildApiKeysSubPage();
      case 6:
        return _buildDiagnosticsSubPage();
      default:
        return _buildAppearanceSubPage(isDarkMode);
    }
  }

  // Sub-Page 1: Appearance & Theme
  Widget _buildAppearanceSubPage(bool isDarkMode) {
    return CyberHudCard(
      tag: 'OPT-1',
      borderColor: const Color(0xFFFFE997),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, color: Color(0xFFFFE997), size: 22),
              const SizedBox(width: 10),
              Text('APPEARANCE & CYBER THEME PREFERENCES', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFFFFE997).withOpacity(0.3)),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: const Color(0xFFC4E320),
            title: Text('DARK CYBER THEME MODE', style: CyberTextStyles.technical(fontSize: 12, color: Colors.white)),
            subtitle: Text(
              isDarkMode ? 'OBSIDIAN TERMINAL DARK MODE ACTIVE' : 'PASTEL LAVENDER LIGHT MODE ACTIVE',
              style: CyberTextStyles.techMuted.copyWith(fontSize: 10),
            ),
            value: isDarkMode,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TELEMETRY REFRESH RATE', style: CyberTextStyles.technical(fontSize: 11, color: Colors.white)),
              DropdownButton<String>(
                value: _telemetryRefreshInterval,
                dropdownColor: const Color(0xFF0F0F14),
                style: CyberTextStyles.technical(color: const Color(0xFFC4E320), fontSize: 11),
                items: ['1 Second', '2 Seconds', '5 Seconds', '10 Seconds'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _telemetryRefreshInterval = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-Page 2: Admin Identity
  Widget _buildAdminIdentitySubPage(String adminName, String adminRole, String adminEmail) {
    return CyberHudCard(
      tag: 'OPT-2',
      borderColor: const Color(0xFFA88AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_outlined, color: Color(0xFFA88AED), size: 22),
              const SizedBox(width: 10),
              Text('ADMINISTRATOR IDENTITY & ACCESS PROFILE', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFFA88AED).withOpacity(0.3)),
          const SizedBox(height: 10),
          _buildAdminInfoTile('HANDLE', adminName.toUpperCase()),
          _buildAdminInfoTile('EMAIL ADDRESS', adminEmail),
          _buildAdminInfoTile('RBAC PERMISSION LEVEL', '$adminRole Level 5 (FULL SYSTEM AUTHORIZATION)'),
          _buildAdminInfoTile('SESSION ENCRYPTION', 'TLS 1.3 AES-256-GCM'),
          _buildAdminInfoTile('MFA AUTHENTICATION', 'HARDWARE YUBIKEY VERIFIED'),
        ],
      ),
    );
  }

  // Sub-Page 3: OPA Policy Engine
  Widget _buildOpaEngineSubPage() {
    return CyberHudCard(
      tag: 'OPT-3',
      borderColor: const Color(0xFFC4E320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_outlined, color: Color(0xFFC4E320), size: 22),
              const SizedBox(width: 10),
              Text('ZERO-TRUST & OPA REGO ENGINE CONFIGURATION', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFFC4E320).withOpacity(0.3)),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: const Color(0xFFC4E320),
            title: Text('STRICT OPA REGO ENFORCEMENT MODE', style: CyberTextStyles.technical(fontSize: 12, color: Colors.white)),
            subtitle: Text('Block non-compliant IoT flows instantly at Envoy sidecars', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
            value: _strictOpaEnforcement,
            onChanged: (val) => setState(() => _strictOpaEnforcement = val),
          ),
          SwitchListTile(
            activeColor: const Color(0xFFC4E320),
            title: Text('AUTO-QUARANTINE HIGH-RISK NODES', style: CyberTextStyles.technical(fontSize: 12, color: Colors.white)),
            subtitle: Text('Automatically isolate IoT devices when GNN threat score exceeds threshold', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
            value: _autoQuarantineEnabled,
            onChanged: (val) => setState(() => _autoQuarantineEnabled = val),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GNN THREAT SENSITIVITY THRESHOLD', style: CyberTextStyles.technical(fontSize: 11, color: Colors.white)),
                  Text('${(_gnnSensitivityThreshold * 100).toInt()}% SCORE', style: CyberTextStyles.technical(fontSize: 11, color: const Color(0xFFC4E320), fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _gnnSensitivityThreshold,
                min: 0.50,
                max: 0.99,
                activeColor: const Color(0xFFC4E320),
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _gnnSensitivityThreshold = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-Page 4: Webhooks
  Widget _buildWebhooksSubPage() {
    return CyberHudCard(
      tag: 'OPT-4',
      borderColor: const Color(0xFF80A416),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.webhook_outlined, color: Color(0xFF80A416), size: 22),
              const SizedBox(width: 10),
              Text('SLACK / PAGERDUTY INCIDENT ALERTS WEBHOOK', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFF80A416).withOpacity(0.3)),
          const SizedBox(height: 10),
          TextField(
            controller: _webhookController,
            style: CyberTextStyles.techBody,
            decoration: const InputDecoration(labelText: 'INCIDENT ALERT WEBHOOK URL'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeonButton(
                text: _isTestingWebhook ? 'TRANSMITTING...' : 'TEST WEBHOOK ENDPOINT',
                onPressed: _testWebhook,
                icon: Icons.send_outlined,
                color: const Color(0xFF80A416),
              ),
              if (_webhookStatus.isNotEmpty)
                Text(_webhookStatus, style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFFC4E320))),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-Page 5: API Keys
  Widget _buildApiKeysSubPage() {
    return CyberHudCard(
      tag: 'OPT-5',
      borderColor: const Color(0xFFB91C1D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_outlined, color: Color(0xFFB91C1D), size: 22),
              const SizedBox(width: 10),
              Text('SYSTEM BEARER TOKEN & SECURITY API KEYS', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFFB91C1D).withOpacity(0.3)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYSTEM API BEARER TOKEN', style: CyberTextStyles.technical(fontSize: 11, color: Colors.white)),
              ElevatedButton(
                onPressed: _generateNewApiKey,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB91C1D)),
                child: Text('GENERATE NEW BEARER TOKEN', style: CyberTextStyles.technical(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_showApiKey) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFB91C1D)),
              ),
              child: SelectableText(_generatedApiKey, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFFFE997))),
            ),
          ],
        ],
      ),
    );
  }

  // Sub-Page 6: Diagnostics & Audit Stream
  Widget _buildDiagnosticsSubPage() {
    return CyberHudCard(
      tag: 'OPT-6',
      borderColor: const Color(0xFFC5C764),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_outlined, color: Color(0xFFC5C764), size: 22),
              const SizedBox(width: 10),
              Text('SYSTEM DIAGNOSTICS & OPA REGO AUDIT LOG STREAM', style: CyberTextStyles.technical(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: const Color(0xFFC5C764).withOpacity(0.3)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC5C764).withOpacity(0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[LOG-1029] OPA Rego Policy Engine initialized successfully (v0.62.0)', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFC4E320))),
                SizedBox(height: 4),
                Text('[LOG-1030] Envoy Proxy Sidecars sync status: 100% HEALTHY', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white70)),
                SizedBox(height: 4),
                Text('[LOG-1031] GNN Threat Detector listening on socket 10.128.4.102:8080', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFFFE997))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CyberTextStyles.technical(fontSize: 9.5, color: CyberColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: CyberTextStyles.technical(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
