import '../widgets/console_row.dart';
import '../landing/cinematic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/text_styles.dart';
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

  int? _hoveredTileId;

  // 1. Zeek Settings State
  String _zeekInterface = 'eth0 (All IoT Ingress)';
  final TextEditingController _bpfFilterCtrl =
      TextEditingController(text: 'tcp or udp or icmp and not port 22');
  String _zeekBufferSize = '512 MB';
  bool _zeekPromiscuous = true;

  // 2. Detection Thresholds State
  double _gnnSensitivityThreshold = 0.85;
  bool _autoQuarantineEnabled = true;

  // 3. Model & Retraining State
  bool _autoRetrainOnFlows = true;
  int _retrainFlowBatchSize = 1000;
  bool _isRetrainingModel = false;
  String _retrainStatus = '';

  // 4. OPA Connection State
  final TextEditingController _opaEndpointCtrl =
      TextEditingController(text: 'http://localhost:8181/v1/data/autopolicy');
  final TextEditingController _bundlePathCtrl =
      TextEditingController(text: '/etc/opa/bundles/iot_microsegments.tar.gz');
  bool _strictOpaEnforcement = true;
  bool _isTestingOpa = false;
  String _opaTestStatus = '';

  // 5. Webhooks & Notifications State
  final TextEditingController _webhookController = TextEditingController(
    text:
        'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX',
  );
  final TextEditingController _smtpHostCtrl =
      TextEditingController(text: 'smtp.enclave-internal.net:587');
  bool _isTestingWebhook = false;
  String _webhookStatus = '';

  // 6. Theme & Appearance
  String _telemetryRefreshInterval = '2 Seconds';

  @override
  void dispose() {
    _bpfFilterCtrl.dispose();
    _opaEndpointCtrl.dispose();
    _bundlePathCtrl.dispose();
    _webhookController.dispose();
    _smtpHostCtrl.dispose();
    super.dispose();
  }

  void _triggerModelRetrain() {
    if (_isRetrainingModel) return;
    setState(() {
      _isRetrainingModel = true;
      _retrainStatus = 'COMPILING GNN TOPOLOGY GRAPH & WEIGHTS...';
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isRetrainingModel = false;
        _retrainStatus =
            'GNN RETRAINING COMPLETE: 1.07M PARAMS OPTIMIZED (98.9% ACCURACY)';
      });
    });
  }

  void _testOpaConnection() {
    if (_isTestingOpa) return;
    setState(() {
      _isTestingOpa = true;
      _opaTestStatus = 'CONNECTING TO OPA REGO SIDECAR...';
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTestingOpa = false;
        _opaTestStatus =
            'OPA SIDECAR HEALTHY (298 ACTIVE RULES · LATENCY 0.8ms)';
      });
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
    final String adminEmail =
        '${adminName.toLowerCase().replaceAll(' ', '')}@autopolicy.zero-trust';

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_activeSettingsTab != 0) ...[
                    IconButton(
                      tooltip: 'All Configuration Tiles',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: isDarkMode
                            ? const Color(0xFF5DD62C)
                            : const Color(0xFF0F172A),
                      ),
                      onPressed: () => setState(() => _activeSettingsTab = 0),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM SETTINGS & CONFIGURATION',
                          style: CyberTextStyles.heading2.copyWith(
                              color: isDarkMode
                                  ? const Color(0xFF5DD62C)
                                  : const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ZEEK IDS, DETECTION THRESHOLDS, GNN MODEL, OPA SIDECAR & NOTIFICATIONS',
                          style: CyberTextStyles.techMuted.copyWith(
                              color: isDarkMode
                                  ? const Color(0xFF9EBA9C)
                                  : const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top Admin Banner
              _buildTopAdminCard(
                  context, isDarkMode, adminName, adminRole, adminEmail),
              const SizedBox(height: 16),

              // Render Main Directory or Individual Sub-Pages
              if (_activeSettingsTab == 0)
                _buildSettingsTilesDirectory(isDarkMode)
              else
                _buildIndividualSettingsSubPage(
                    context, isDarkMode, adminName, adminRole, adminEmail),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAdminCard(BuildContext context, bool isDarkMode,
      String adminName, String adminRole, String adminEmail) {
    return CyberHudCard(
      tag: 'SYS-CFG',
      borderColor:
          isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFCDD4B2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isDarkMode
                      ? const Color(0xFFFFE997)
                      : const Color(0xFFEBECCC),
                  radius: 20,
                  child: Icon(Icons.settings,
                      color: isDarkMode ? Colors.black : const Color(0xFF0F172A),
                      size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZERO-TRUST SYSTEM CONFIGURATION HUB',
                        style: CyberTextStyles.technical(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ENCLAVE: INDUSTRIAL IOT MESH · ACTIVE OPERATOR: ${adminName.toUpperCase()} ($adminRole)',
                        style: CyberTextStyles.technical(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white70
                                : const Color(0xFF475569)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CinematicButton(
            landingLight: true,
            label: 'ALL SERVICES SYNCHRONIZED',
            filled: false,
            compact: true,
            navbar: true,
            angular: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 1. Directory View rendering 6 ListTiles per Admin Specification
  Widget _buildSettingsTilesDirectory(bool isDarkMode) {
    final settingsCategories = [
      {
        'id': 1,
        'title': '1. ZEEK SENSOR CONFIGURATION',
        'subtitle':
            'Network capture interfaces, BPF packet filters, capture intervals, and ring buffers',
        'icon': Icons.radar_outlined,
        'darkColor': const Color(0xFFFFE997),
        'lightColor': const Color(0xFFFFF9E1),
        'tag': 'CFG-1',
      },
      {
        'id': 2,
        'title': '2. DETECTION THRESHOLDS & GNN SENSITIVITY',
        'subtitle':
            'GNN confidence score triggers, severity classification mapping, and auto-quarantine toggles',
        'icon': Icons.tune_outlined,
        'darkColor': const Color(0xFFA88AED),
        'lightColor': const Color(0xFFEBECCC),
        'tag': 'CFG-2',
      },
      {
        'id': 3,
        'title': '3. MODEL & RETRAINING SETTINGS',
        'subtitle':
            'PyTorch transformer weights, automated retraining flow limits, and manual training triggers',
        'icon': Icons.psychology_outlined,
        'darkColor': const Color(0xFFC4E320),
        'lightColor': const Color(0xFFCDD4B2),
        'tag': 'CFG-3',
      },
      {
        'id': 4,
        'title': '4. OPA CONNECTION & SIDECAR SETTINGS',
        'subtitle':
            'Open Policy Agent REST endpoint, compiled Rego bundle paths, and sidecar health check',
        'icon': Icons.shield_outlined,
        'darkColor': const Color(0xFF80A416),
        'lightColor': const Color(0xFFD4C9D8),
        'tag': 'CFG-4',
      },
      {
        'id': 5,
        'title': '5. NOTIFICATION & WEBHOOK SETTINGS',
        'subtitle':
            'Slack / Teams webhooks, SIEM event dispatch, SMTP alert host, and emergency SMS',
        'icon': Icons.notifications_active_outlined,
        'darkColor': const Color(0xFFB91C1D),
        'lightColor': const Color(0xFFB8A9C1),
        'tag': 'CFG-5',
      },
      {
        'id': 6,
        'title': '6. APPEARANCE & CYBER THEME PREFERENCES',
        'subtitle':
            'Toggle Dark/Light mode, high-contrast cyber palette, and telemetry refresh frequency',
        'icon': Icons.palette_outlined,
        'darkColor': const Color(0xFFC5C764),
        'lightColor': const Color(0xFFDCA278),
        'tag': 'CFG-6',
      },
    ];

    return Column(
      children: settingsCategories.map((cat) {
        final int id = cat['id'] as int;
        final String title = cat['title'] as String;
        final String subtitle = cat['subtitle'] as String;
        final IconData icon = cat['icon'] as IconData;
        final Color darkColor = cat['darkColor'] as Color;
        final Color lightColor = cat['lightColor'] as Color;
        final Color cardColor = isDarkMode ? darkColor : lightColor;
        final String tag = cat['tag'] as String;
        final bool isHovered = _hoveredTileId == id;

        final Color titleColor =
            isDarkMode ? Colors.white : const Color(0xFF0A0A0E);
        final Color subtitleColor =
            isDarkMode ? Colors.white70 : const Color(0xFF1E293B);
        final Color iconColor =
            isDarkMode ? cardColor : const Color(0xFF0A0A0E);
        final Color iconBg = isDarkMode
            ? cardColor.withOpacity(isHovered ? 0.28 : 0.15)
            : Colors.black.withOpacity(isHovered ? 0.12 : 0.06);

        final Color cardBorderColor = isDarkMode
            ? (isHovered ? cardColor : cardColor.withOpacity(0.7))
            : (isHovered
                ? const Color(0xFF0A0A0E)
                : const Color(0xFF0A0A0E).withOpacity(0.22));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredTileId = id),
            onExit: (_) => setState(() => _hoveredTileId = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: isHovered
                  ? Matrix4.translationValues(0, -4, 0)
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color:
                              (isDarkMode ? cardColor : const Color(0xFF0A0A0E))
                                  .withOpacity(isDarkMode ? 0.45 : 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activeSettingsTab = id;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: CyberHudCard(
                  tag: tag,
                  backgroundColor:
                      isDarkMode ? const Color(0xFF0F0F0F) : cardColor,
                  borderColor: cardBorderColor,
                  borderWidth: isHovered ? 2.0 : 1.2,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? cardColor.withOpacity(isHovered ? 0.9 : 0.5)
                                : const Color(0xFF0A0A0E).withOpacity(0.2),
                          ),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: CyberTextStyles.technical(
                                color: titleColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: CyberTextStyles.technical(
                                color: subtitleColor,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_forward_ios, color: iconColor, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 2. Individual Sub-Page renderer based on selected ListTile
  Widget _buildIndividualSettingsSubPage(BuildContext context, bool isDarkMode,
      String adminName, String adminRole, String adminEmail) {
    switch (_activeSettingsTab) {
      case 1:
        return _buildZeekSubPage(isDarkMode);
      case 2:
        return _buildDetectionThresholdsSubPage(isDarkMode);
      case 3:
        return _buildModelRetrainingSubPage(isDarkMode);
      case 4:
        return _buildOpaSubPage(isDarkMode);
      case 5:
        return _buildWebhooksSubPage(isDarkMode);
      case 6:
        return _buildAppearanceSubPage(isDarkMode);
      default:
        return _buildZeekSubPage(isDarkMode);
    }
  }

  // Sub-Page 1: Zeek Configuration
  Widget _buildZeekSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-1',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_outlined,
                  color: Color(0xFFFFE997), size: 22),
              const SizedBox(width: 10),
              Text(
                'ZEEK NETWORK SENSOR CONFIGURATION',
                style: CyberTextStyles.technical(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CAPTURE NETWORK INTERFACE',
                  style: CyberTextStyles.technical(
                      fontSize: 11, color: titleColor)),
              DropdownButton<String>(
                value: _zeekInterface,
                dropdownColor: isDarkMode
                    ? const Color(0xFF0F0F14)
                    : const Color(0xFFFAF9F6),
                style: CyberTextStyles.technical(
                    color: isDarkMode
                        ? const Color(0xFFFFE997)
                        : const Color(0xFF80A416),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                items: [
                  'eth0 (All IoT Ingress)',
                  'eth1 (Industrial ICS)',
                  'wlan0 (Mesh Gateways)'
                ].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _zeekInterface = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bpfFilterCtrl,
            style: TextStyle(
                color: titleColor, fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFFAF9F6),
              labelText: 'BERKELEY PACKET FILTER (BPF) STRING',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFFFE997)
                      : const Color(0xFF475569),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFFA88AED)
                        : const Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RING BUFFER SIZE',
                  style: CyberTextStyles.technical(
                      fontSize: 11, color: titleColor)),
              DropdownButton<String>(
                value: _zeekBufferSize,
                dropdownColor: isDarkMode
                    ? const Color(0xFF0F0F14)
                    : const Color(0xFFFAF9F6),
                style: CyberTextStyles.technical(
                    color: isDarkMode
                        ? const Color(0xFFFFE997)
                        : const Color(0xFF80A416),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                items: ['256 MB', '512 MB', '1024 MB', '2048 MB'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _zeekBufferSize = val);
                },
              ),
            ],
          ),
          SwitchListTile(
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFFD4C9D8),
            inactiveThumbColor: const Color(0xFFFFF9E1),
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            title: Text('PROMISCUOUS PACKET CAPTURE',
                style:
                    CyberTextStyles.technical(fontSize: 12, color: titleColor)),
            subtitle: Text('Inspect all lateral traffic across VLAN switches',
                style: CyberTextStyles.techMuted.copyWith(
                    fontSize: 10,
                    color:
                        isDarkMode ? Colors.white60 : const Color(0xFF64748B))),
            value: _zeekPromiscuous,
            onChanged: (val) => setState(() => _zeekPromiscuous = val),
          ),
        ],
      ),
    );
  }

  // Sub-Page 2: Detection Thresholds
  Widget _buildDetectionThresholdsSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFFA88AED) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-2',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_outlined,
                  color: Color(0xFFA88AED), size: 22),
              const SizedBox(width: 10),
              Text('DETECTION THRESHOLDS & GNN SENSITIVITY',
                  style: CyberTextStyles.technical(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GNN THREAT SENSITIVITY CUTOFF',
                  style: CyberTextStyles.technical(
                      fontSize: 11, color: titleColor)),
              Text('${(_gnnSensitivityThreshold * 100).toInt()}% CONFIDENCE',
                  style: CyberTextStyles.technical(
                      fontSize: 11,
                      color: const Color(0xFFA88AED),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _gnnSensitivityThreshold,
            min: 0.50,
            max: 0.99,
            activeColor: const Color(0xFF8B5CF6),
            inactiveColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            thumbColor: const Color(0xFF8B5CF6),
            onChanged: (val) => setState(() => _gnnSensitivityThreshold = val),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFFD4C9D8),
            inactiveThumbColor: const Color(0xFFFFF9E1),
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            title: Text('AUTO-QUARANTINE HIGH-RISK DEVICES',
                style:
                    CyberTextStyles.technical(fontSize: 12, color: titleColor)),
            subtitle: Text(
                'Instantly isolate target node when anomaly score crosses threshold',
                style: CyberTextStyles.techMuted.copyWith(
                    fontSize: 10,
                    color:
                        isDarkMode ? Colors.white60 : const Color(0xFF64748B))),
            value: _autoQuarantineEnabled,
            onChanged: (val) => setState(() => _autoQuarantineEnabled = val),
          ),
        ],
      ),
    );
  }

  // Sub-Page 3: Model & Retraining
  Widget _buildModelRetrainingSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFFC4E320) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-3',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  color: Color(0xFFC4E320), size: 22),
              const SizedBox(width: 10),
              Text('PYTORCH GNN MODEL & CONTINUOUS RETRAINING',
                  style: CyberTextStyles.technical(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFFD4C9D8),
            inactiveThumbColor: const Color(0xFFFFF9E1),
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            title: Text('AUTO-RETRAIN ON FLOW BATCH',
                style:
                    CyberTextStyles.technical(fontSize: 12, color: titleColor)),
            subtitle: Text(
                'Retrain GNN graph weights automatically every $_retrainFlowBatchSize incoming network flows',
                style: CyberTextStyles.techMuted.copyWith(
                    fontSize: 10,
                    color:
                        isDarkMode ? Colors.white60 : const Color(0xFF64748B))),
            value: _autoRetrainOnFlows,
            onChanged: (val) => setState(() => _autoRetrainOnFlows = val),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MANUAL ON-DEMAND RETRAIN',
                  style: CyberTextStyles.technical(
                      fontSize: 11, color: titleColor)),
              CinematicButton(
                landingLight: true,
                label: _isRetrainingModel ? 'TRAINING...' : 'RETRAIN MODEL NOW',
                compact: true,
                navbar: true,
                angular: true,
                filled: false,
                onPressed: _isRetrainingModel ? null : _triggerModelRetrain,
              ),
            ],
          ),
          if (_retrainStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_retrainStatus,
                style: CyberTextStyles.technical(
                    fontSize: 10,
                    color: isDarkMode
                        ? const Color(0xFFC4E320)
                        : const Color(0xFF80A416))),
          ],
        ],
      ),
    );
  }

  // Sub-Page 4: OPA Connection
  Widget _buildOpaSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFF80A416) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-4',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: Color(0xFF80A416), size: 22),
              const SizedBox(width: 10),
              Text('OPEN POLICY AGENT (OPA) & REGO ENFORCEMENT',
                  style: CyberTextStyles.technical(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          TextField(
            controller: _opaEndpointCtrl,
            style: TextStyle(
                color: titleColor, fontFamily: 'monospace', fontSize: 12.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFFAF9F6),
              labelText: 'OPA ENGINE REST ENDPOINT',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFF80A416)
                      : const Color(0xFF475569),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFFA88AED)
                        : const Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bundlePathCtrl,
            style: TextStyle(
                color: titleColor, fontFamily: 'monospace', fontSize: 12.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFFAF9F6),
              labelText: 'REGO POLICY BUNDLE PATH',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFF80A416)
                      : const Color(0xFF475569),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFFA88AED)
                        : const Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFFD4C9D8),
            inactiveThumbColor: const Color(0xFFFFF9E1),
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            title: Text('STRICT REGO DENY-BY-DEFAULT',
                style:
                    CyberTextStyles.technical(fontSize: 12, color: titleColor)),
            subtitle: Text(
                'Zero-Trust principle: drop all unspecified microsegments',
                style: CyberTextStyles.techMuted.copyWith(
                    fontSize: 10,
                    color:
                        isDarkMode ? Colors.white60 : const Color(0xFF64748B))),
            value: _strictOpaEnforcement,
            onChanged: (val) => setState(() => _strictOpaEnforcement = val),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CinematicButton(
                landingLight: true,
                label: _isTestingOpa ? 'TESTING...' : 'PING OPA SIDECAR',
                compact: true,
                navbar: true,
                angular: true,
                filled: false,
                onPressed: _isTestingOpa ? null : _testOpaConnection,
              ),
              if (_opaTestStatus.isNotEmpty)
                Text(_opaTestStatus,
                    style: CyberTextStyles.technical(
                        fontSize: 10,
                        color: isDarkMode
                            ? const Color(0xFFC4E320)
                            : const Color(0xFF80A416))),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-Page 5: Webhooks & Notifications
  Widget _buildWebhooksSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFFB91C1D) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-5',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: Color(0xFFB91C1D), size: 22),
              const SizedBox(width: 10),
              Text('NOTIFICATION & DISPATCH WEBHOOK CONFIGURATION',
                  style: CyberTextStyles.technical(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          TextField(
            controller: _webhookController,
            style: TextStyle(
                color: titleColor, fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFFAF9F6),
              labelText: 'INCIDENT ALERT WEBHOOK URL (SLACK / TEAMS)',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFB91C1D)
                      : const Color(0xFF475569),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _smtpHostCtrl,
            style: TextStyle(
                color: titleColor, fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFFAF9F6),
              labelText: 'ENCLAVE SMTP DISPATCH HOST',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFB91C1D)
                      : const Color(0xFF475569),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color:
                        isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CinematicButton(
                landingLight: true,
                label: _isTestingWebhook
                    ? 'TESTING...'
                    : 'TRANSMIT TEST PAYLOAD',
                compact: true,
                navbar: true,
                angular: true,
                filled: false,
                onPressed: _isTestingWebhook ? null : _testWebhook,
              ),
              if (_webhookStatus.isNotEmpty)
                Text(_webhookStatus,
                    style: CyberTextStyles.technical(
                        fontSize: 10,
                        color: isDarkMode
                            ? const Color(0xFFC4E320)
                            : const Color(0xFF80A416))),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-Page 6: Appearance & Theme
  Widget _buildAppearanceSubPage(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? const Color(0xFFC5C764) : const Color(0xFFCDD4B2);

    return CyberHudCard(
      tag: 'CFG-6',
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined,
                  color: Color(0xFFC5C764), size: 22),
              const SizedBox(width: 10),
              Text('APPEARANCE & CYBER THEME PREFERENCES',
                  style: CyberTextStyles.technical(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.35)),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFFD4C9D8),
            inactiveThumbColor: const Color(0xFFFFF9E1),
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF333333) : const Color(0xFFEBECCC),
            title: Text('DARK CYBER THEME MODE',
                style:
                    CyberTextStyles.technical(fontSize: 12, color: titleColor)),
            subtitle: Text(
              isDarkMode
                  ? 'OBSIDIAN TERMINAL DARK MODE ACTIVE'
                  : 'PASTEL LAVENDER LIGHT MODE ACTIVE',
              style: CyberTextStyles.techMuted.copyWith(
                  fontSize: 10,
                  color: isDarkMode ? Colors.white60 : const Color(0xFF64748B)),
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
              Text('TELEMETRY REFRESH RATE',
                  style: CyberTextStyles.technical(
                      fontSize: 11, color: titleColor)),
              DropdownButton<String>(
                value: _telemetryRefreshInterval,
                dropdownColor: isDarkMode
                    ? const Color(0xFF0F0F14)
                    : const Color(0xFFFAF9F6),
                style: CyberTextStyles.technical(
                    color: isDarkMode
                        ? const Color(0xFFC4E320)
                        : const Color(0xFF80A416),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                items: ['1 Second', '2 Seconds', '5 Seconds', '10 Seconds']
                    .map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null)
                    setState(() => _telemetryRefreshInterval = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
