import '../widgets/console_row.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../landing/cinematic_button.dart';
import '../models/device.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_hud_card.dart';

/// Simulation Testing Workstation – Redesigned Layout
/// - Header with "Sandbox Isolated – Zero Prod Leakage" badge
/// - Section 1: Scenario Selection (Horizontal 5 Selectable Cards)
/// - Section 2: Two-Column Layout (Left 40%: Config & Execution; Right 60%: Results & Metrics)
class SimulationTesting extends ConsumerStatefulWidget {
  const SimulationTesting({super.key});

  @override
  ConsumerState<SimulationTesting> createState() => _SimulationTestingState();
}

class _SimulationTestingState extends ConsumerState<SimulationTesting> {
  int? _selectedScenarioIdx = 0; // Selected scenario (0..4)
  int? _hoveredScenarioIdx;
  String? _selectedTargetDeviceId;
  bool _isExecuting = false;
  double _execProgress = 0.0;

  final List<Map<String, dynamic>> _scenarios = [
    {
      'title': 'DDoS Flood Simulation',
      'subtitle': 'Syn-flood & UDP packet amplification against edge gateways',
      'icon': Icons.bolt_outlined,
      'darkColor': const Color(0xFFFFE997),
      'lightColor': const Color(0xFFFFF9E1),
      'color': const Color(0xFFFFE997),
      'tag': 'SCN-1',
      'packetsPerSec': '12,500 pkts/s',
      'vector': 'TCP SYN + UDP Flood',
      'blockedRate': 99.2,
      'leakedRate': 0.8,
      'falsePositive': 0.8,
      'regoRule':
          'deny[msg] {\n  input.packet_rate > 5000\n  msg := "Rate limit exceeded (DDoS SYN Mitigation)"\n}',
    },
    {
      'title': 'Port Scanner & Lateral Movement',
      'subtitle':
          'Aggressive Nmap SYN-scan across subnets looking for open ports',
      'icon': Icons.radar_outlined,
      'darkColor': const Color(0xFFA88AED),
      'lightColor': const Color(0xFFEBECCC),
      'color': const Color(0xFFA88AED),
      'tag': 'SCN-2',
      'packetsPerSec': '3,400 pkts/s',
      'vector': 'Stealth SYN Scan',
      'blockedRate': 98.6,
      'leakedRate': 1.4,
      'falsePositive': 1.4,
      'regoRule':
          'deny[msg] {\n  input.port_sweep_count > 15\n  not input.admin_authorized\n  msg := "Lateral scan detected"\n}',
    },
    {
      'title': 'Modbus MitM Injection',
      'subtitle': 'Unauthorized Function Code 0x05 write to PLC coil registers',
      'icon': Icons.precision_manufacturing_outlined,
      'darkColor': const Color(0xFFC4E320),
      'lightColor': const Color(0xFFCDD4B2),
      'color': const Color(0xFFC4E320),
      'tag': 'SCN-3',
      'packetsPerSec': '450 pkts/s',
      'vector': 'Modbus TCP Register Override',
      'blockedRate': 100.0,
      'leakedRate': 0.0,
      'falsePositive': 0.0,
      'regoRule':
          'deny[msg] {\n  input.protocol == "modbus"\n  input.function_code == 5\n  input.role != "scada_admin"\n  msg := "Modbus write denied"\n}',
    },
    {
      'title': 'Data Exfiltration Stress Test',
      'subtitle': 'Simulated payload exfiltration via DNS tunneling and HTTPS',
      'icon': Icons.cloud_upload_outlined,
      'darkColor': const Color(0xFF80A416),
      'lightColor': const Color(0xFFD4C9D8),
      'color': const Color(0xFF80A416),
      'tag': 'SCN-4',
      'packetsPerSec': '1,200 pkts/s',
      'vector': 'DNS Tunneling Chunking',
      'blockedRate': 97.8,
      'leakedRate': 2.2,
      'falsePositive': 2.1,
      'regoRule':
          'deny[msg] {\n  input.dns_query_len > 180\n  not input.fqdn_whitelisted\n  msg := "DNS Tunneling signature blocked"\n}',
    },
    {
      'title': 'Custom PCAP Replay',
      'subtitle':
          'Replay recorded attack capture against current OPA Rego policies',
      'icon': Icons.upload_file_outlined,
      'darkColor': const Color(0xFFDF2531),
      'lightColor': const Color(0xFFB8A9C1),
      'color': const Color(0xFFDF2531),
      'tag': 'SCN-5',
      'packetsPerSec': '5,000 pkts/s',
      'vector': 'Recorded PCAP Tracefile',
      'blockedRate': 99.5,
      'leakedRate': 0.5,
      'falsePositive': 0.5,
      'regoRule':
          'deny[msg] {\n  input.signature_matched\n  msg := "Known threat payload signature quarantined"\n}',
    },
  ];

  final List<String> _simLogs = [];

  void _runSimulation() {
    if (_selectedScenarioIdx == null) return;
    final scn = _scenarios[_selectedScenarioIdx!];

    setState(() {
      _isExecuting = true;
      _execProgress = 0.0;
      _simLogs.clear();
      _simLogs
          .add('[INIT] Isolating veth sandbox container network namespace...');
    });

    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _execProgress += 0.15;
        if (_execProgress >= 0.3 && _simLogs.length == 1) {
          _simLogs.add(
              '[OPA] Synchronizing sidecar policy rules from /etc/opa/policies...');
        } else if (_execProgress >= 0.6 && _simLogs.length == 2) {
          _simLogs.add(
              '[SURGE] Injected ${scn['packetsPerSec']} threat packets (${scn['vector']})...');
        } else if (_execProgress >= 0.85 && _simLogs.length == 3) {
          _simLogs.add(
              '[VERDICT] Enforced OPA Zero-Trust microsegmentation barrier.');
        }

        if (_execProgress >= 1.0) {
          _execProgress = 1.0;
          _isExecuting = false;
          _simLogs.add(
              '[SUCCESS] Simulation complete: ${scn['blockedRate']}% blocked, ${scn['leakedRate']}% leak rate.');
          timer.cancel();

          // If a target device was selected, record the simulated vector
          if (_selectedTargetDeviceId != null) {
            ref.read(securityProvider.notifier).recordDeviceSimulationTest(
                  _selectedTargetDeviceId!,
                  scn['vector'] as String,
                );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    final securityState = ref.watch(securityProvider);
    final eligibleDevices = securityState.devices
        .where((d) => d.status == DeviceStatus.safe)
        .toList();
    final bool isMobile = Responsive.isMobile(context);

    // Bulletproof device ID resolution to prevent dropdown assertion crashes
    String? effectiveDeviceId = _selectedTargetDeviceId;
    if (eligibleDevices.isNotEmpty &&
        (effectiveDeviceId == null ||
            !eligibleDevices.any((d) => d.id == effectiveDeviceId))) {
      effectiveDeviceId = eligibleDevices.first.id;
      _selectedTargetDeviceId = effectiveDeviceId;
    }

    final activeScenario =
        _selectedScenarioIdx != null ? _scenarios[_selectedScenarioIdx!] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header with Badge
            _buildPageHeader(isDarkMode),
            const SizedBox(height: 16),

            // SECTION 1: Scenario Selection (Horizontal 5 Selectable Cards)
            _buildScenarioSelectionRow(isDarkMode),
            const SizedBox(height: 16),

            // SECTION 2: Two-Column Workstation (Left 40% Config, Right 60% Results)
            if (activeScenario == null)
              _buildEmptyState(isDarkMode)
            else if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (~40%): Scenario Configuration
                  Expanded(
                    flex: 4,
                    child: _buildScenarioConfigCard(activeScenario,
                        eligibleDevices, effectiveDeviceId, isDarkMode),
                  ),
                  const SizedBox(width: 16),
                  // Right Column (~60%): Results & Metrics
                  Expanded(
                    flex: 6,
                    child:
                        _buildResultsAndMetricsCard(activeScenario, isDarkMode),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildScenarioConfigCard(activeScenario, eligibleDevices,
                      effectiveDeviceId, isDarkMode),
                  const SizedBox(height: 16),
                  _buildResultsAndMetricsCard(activeScenario, isDarkMode),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1150;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIMULATION TESTING WORKSTATION',
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
              'Stress-test Zero-Trust policies in a safe sandbox',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

        final badge = CinematicButton(
          landingLight: true,
          label: 'Sandbox Isolated – Zero Prod Leakage',
          filled: false,
          compact: true,
          angular: true,
          onPressed: () {},
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              badge,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            badge,
          ],
        );
      },
    );
  }

  // ── SECTION 1: SCENARIO SELECTION (HORIZONTAL 5 CARDS) ─────────────────────
  Widget _buildScenarioSelectionRow(bool isDarkMode) {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return SizedBox(
        height: 126,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _scenarios.length,
          itemBuilder: (context, idx) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildScenarioTile(idx, 260, isDarkMode),
          ),
        ),
      );
    }

    return SizedBox(
      height: 126,
      child: Row(
        children: List.generate(_scenarios.length, (idx) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: idx < _scenarios.length - 1 ? 10.0 : 0.0),
              child: _buildScenarioTile(idx, null, isDarkMode),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScenarioTile(int idx, double? width, bool isDarkMode) {
    final scn = _scenarios[idx];
    final bool isSelected = _selectedScenarioIdx == idx;
    final bool isHovered = _hoveredScenarioIdx == idx;
    final Color color =
        isDarkMode ? (scn['darkColor'] as Color) : (scn['lightColor'] as Color);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredScenarioIdx = idx),
      onExit: (_) => setState(() => _hoveredScenarioIdx = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: (isDarkMode ? color : const Color(0xFF0A0A0E))
                        .withOpacity(isDarkMode ? 0.35 : 0.16),
                    blurRadius: 16,
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
              _selectedScenarioIdx = isSelected ? null : idx;
            });
          },
          child: CustomPaint(
            painter: _SimulationHudCardPainter(
              accentColor: color,
              isSelected: isSelected,
              isHovered: isHovered,
              isDarkMode: isDarkMode,
            ),
            child: Container(
              width: width,
              height: 126,
              padding: const EdgeInsets.only(
                  top: 10, left: 14, right: 26, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        scn['icon'] as IconData,
                        size: 20,
                        color: isDarkMode ? color : const Color(0xFF0A0A0E),
                      ),
                      Text(
                        scn['tag'] as String,
                        style: CyberTextStyles.technical(
                          fontSize: 11.5,
                          color: isDarkMode ? color : const Color(0xFF0A0A0E),
                          fontWeight: FontWeight.w900,
                        ).copyWith(letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scn['title'] as String,
                        style: CyberTextStyles.technical(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0A0A0E),
                        ).copyWith(letterSpacing: 0.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scn['subtitle'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? (isSelected ? Colors.white : Colors.white70)
                              : const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // ── EMPTY STATE ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color:
                isDarkMode ? const Color(0xFF252525) : const Color(0xFFCDD4B2)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.touch_app_outlined,
                size: 36,
                color: isDarkMode ? Colors.white30 : const Color(0xFF64748B)),
            const SizedBox(height: 12),
            Text(
              'Select a simulation scenario above to begin',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LEFT COLUMN: SCENARIO CONFIGURATION (≈40%) ─────────────────────────────
  Widget _buildScenarioConfigCard(
      Map<String, dynamic> scenario,
      List<IoTDevice> eligibleDevices,
      String? effectiveDeviceId,
      bool isDarkMode) {
    final Color color = isDarkMode
        ? (scenario['darkColor'] as Color)
        : (scenario['lightColor'] as Color);

    return CyberHudCard(
      tag: scenario['tag'] as String,
      borderColor: isDarkMode ? color : const Color(0xFFCDD4B2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            ConsoleRow(
              children: [
                Icon(Icons.tune_outlined,
                    color: isDarkMode ? color : const Color(0xFF5E7343),
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  'SCENARIO CONFIGURATION',
                  style: CyberTextStyles.technical(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
                color: isDarkMode
                    ? const Color(0xFF252525)
                    : const Color(0xFFCDD4B2),
                height: 1),
            const SizedBox(height: 14),

            // Target System Asset (SAFE DROPDOWN)
            Text(
              'TARGET SYSTEM ASSET',
              style: CyberTextStyles.technical(
                fontSize: 10.5,
                color: isDarkMode
                    ? const Color(0xFF5DD62C)
                    : const Color(0xFF80A416),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (eligibleDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF161616)
                      : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: isDarkMode
                          ? Colors.transparent
                          : const Color(0xFFCDD4B2)),
                ),
                child: Text(
                  'NO SAFE DEVICES DETECTED (ALL QUARANTINED)',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDarkMode
                          ? Colors.white54
                          : const Color(0xFF64748B)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    value: effectiveDeviceId,
                    isExpanded: true,
                    dropdownColor: isDarkMode
                        ? const Color(0xFF161616)
                        : const Color(0xFFFAF9F6),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                    items: eligibleDevices.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text('${d.name.toUpperCase()} (${d.ipAddress})'),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      if (val != null)
                        setState(() => _selectedTargetDeviceId = val);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // Throughput & Attack Vector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THROUGHPUT VOLUME',
                          style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white54
                                  : const Color(0xFF64748B))),
                      const SizedBox(height: 3),
                      Text(scenario['packetsPerSec'] as String,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? color
                                  : const Color(0xFF5E7343))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTACK VECTOR SIGNATURE',
                          style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white54
                                  : const Color(0xFF64748B))),
                      const SizedBox(height: 3),
                      Text(
                        scenario['vector'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Extra Parameters Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF121212)
                    : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color:
                        isDarkMode ? Colors.white10 : const Color(0xFFCDD4B2)),
              ),
              child: Column(
                children: [
                  _buildConfigParamRow('VIRTUAL SANDBOX INTERFACE',
                      'veth_isolated_0', isDarkMode),
                  const SizedBox(height: 6),
                  _buildConfigParamRow('OPA SIDECAR ENFORCEMENT',
                      'ACTIVE (Localhost:8181)', isDarkMode),
                  const SizedBox(height: 6),
                  _buildConfigParamRow('CONCURRENT THREAT WORKERS',
                      '16 Workers (Multi-threaded)', isDarkMode),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Execution Progress Bar
            if (_isExecuting) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _execProgress,
                  minHeight: 6,
                  backgroundColor: isDarkMode
                      ? const Color(0xFF222222)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? color : const Color(0xFF5E7343)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Execution Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? color : const Color(0xFFCDD4B2),
                  foregroundColor:
                      isDarkMode ? Colors.black : const Color(0xFF0A0A0E),
                  side: isDarkMode
                      ? null
                      : const BorderSide(color: Color(0xFFB8A9C1), width: 1.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                icon: Icon(
                    _isExecuting ? Icons.hourglass_top : Icons.play_arrow,
                    size: 18,
                    color: isDarkMode ? Colors.black : const Color(0xFF0A0A0E)),
                label: Text(
                  _isExecuting
                      ? 'SIMULATING THREAT SURGE...'
                      : 'EXECUTE ISOLATED SIMULATION',
                  style: CyberTextStyles.technical(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.black : const Color(0xFF0A0A0E)),
                ),
                onPressed: _isExecuting ? null : _runSimulation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigParamRow(String label, String val, bool isDarkMode) {
    return ConsoleRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: CyberTextStyles.technical(
                fontSize: 9.5,
                color: isDarkMode ? Colors.white54 : const Color(0xFF64748B))),
        Text(val,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                color: isDarkMode
                    ? const Color(0xFFC5C764)
                    : const Color(0xFF80A416),
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── RIGHT COLUMN: RESULTS & METRICS CARD (≈60%) ────────────────────────────
  Widget _buildResultsAndMetricsCard(
      Map<String, dynamic> scenario, bool isDarkMode) {
    final double blocked = scenario['blockedRate'] as double;
    final double leaked = scenario['leakedRate'] as double;
    final double falsePos = scenario['falsePositive'] as double;

    return CyberHudCard(
      tag: 'RES-01',
      borderColor:
          isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFCDD4B2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ConsoleRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConsoleRow(
                  children: [
                    Icon(Icons.analytics_outlined,
                        color: isDarkMode
                            ? const Color(0xFF5DD62C)
                            : const Color(0xFF5E7343),
                        size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'RESULTS & MITIGATION METRICS',
                      style: CyberTextStyles.technical(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF0A0A0E),
                      ),
                    ),
                  ],
                ),
                Text(
                  'OPA ZERO-TRUST STATUS',
                  style: CyberTextStyles.technical(
                    fontSize: 9.5,
                    color: isDarkMode
                        ? const Color(0xFF5DD62C)
                        : const Color(0xFF5E7343),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
                color: isDarkMode
                    ? const Color(0xFF252525)
                    : const Color(0xFFCDD4B2),
                height: 1),
            const SizedBox(height: 14),

            // Big Key Metrics (Blocked vs Leaked)
            Row(
              children: [
                // Threat Vectors Blocked (Big %)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF5DD62C).withOpacity(0.08)
                          : const Color(0xFFEBECCC),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF5DD62C).withOpacity(0.4)
                              : const Color(0xFFCDD4B2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THREAT VECTORS BLOCKED',
                            style: CyberTextStyles.technical(
                                fontSize: 10,
                                color: isDarkMode
                                    ? const Color(0xFF5DD62C)
                                    : const Color(0xFF08652C),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$blocked%',
                            style: GoogleFonts.barlow(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode
                                    ? const Color(0xFF5DD62C)
                                    : const Color(0xFF08652C))),
                        Text(
                          'Quarantined before core mesh penetration',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white54
                                  : const Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Leaked / Uncontained (Big %)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFFDF2531).withOpacity(0.08)
                          : const Color(0xFFF7D4D6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFFDF2531).withOpacity(0.4)
                              : const Color(0xFFE87D85)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LEAKED / UNCONTAINED',
                            style: CyberTextStyles.technical(
                                fontSize: 10,
                                color: const Color(0xFFD82734),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$leaked%',
                            style: GoogleFonts.barlow(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFD82734))),
                        Text(
                          leaked == 0
                              ? 'Zero blast radius exposure'
                              : 'Surged packets during policy handshake',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white54
                                  : const Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // False Positive Risk Gauge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF141414)
                    : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color:
                        isDarkMode ? Colors.white12 : const Color(0xFFCDD4B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConsoleRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FALSE POSITIVE RISK GAUGE',
                        style: CyberTextStyles.technical(
                          fontSize: 10.5,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0A0A0E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$falsePos% RISK INDEX',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? const Color(0xFFFFE997)
                              : const Color(0xFF08652C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (falsePos / 10).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDarkMode
                          ? const Color(0xFF222222)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                          ? const Color(0xFFFFE997)
                          : const Color(0xFF5E7343)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Policy Recommendation Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF070707)
                    : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFFC4E320).withOpacity(0.4)
                        : const Color(0xFFCDD4B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConsoleRow(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: isDarkMode
                              ? const Color(0xFFC4E320)
                              : const Color(0xFF80A416),
                          size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'AI REGO POLICY RECOMMENDATION',
                        style: CyberTextStyles.technical(
                          fontSize: 10.5,
                          color: isDarkMode
                              ? const Color(0xFFC4E320)
                              : const Color(0xFF80A416),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenario['regoRule'] as String,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      color: isDarkMode
                          ? const Color(0xFFC4E320)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Live Sandbox Execution Terminal Feed
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF050505)
                    : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color:
                        isDarkMode ? Colors.white10 : const Color(0xFFCDD4B2)),
              ),
              child: _simLogs.isEmpty
                  ? Center(
                      child: Text(
                        'Awaiting simulation trigger...',
                        style: CyberTextStyles.technical(
                            fontSize: 10.5,
                            color: isDarkMode
                                ? Colors.white30
                                : const Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _simLogs.length,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _simLogs[idx],
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: idx == _simLogs.length - 1
                                  ? (isDarkMode
                                      ? const Color(0xFF5DD62C)
                                      : const Color(0xFF80A416))
                                  : (isDarkMode
                                      ? Colors.white60
                                      : const Color(0xFF334155)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter rendering the exact Cyberpunk HUD Scenario Card from Image 4
/// Features:
/// - 45-degree chamfer-cut top-right corner with solid accent triangle
/// - Stepped-up bottom-right ledge with diagonal hazard stripes (///)
/// - Dashed interior grid lines (cross-hairs)
/// - Thick bright glowing bottom edge and left edge highlight
class _SimulationHudCardPainter extends CustomPainter {
  final Color accentColor;
  final bool isSelected;
  final bool isHovered;
  final bool isDarkMode;

  _SimulationHudCardPainter({
    required this.accentColor,
    required this.isSelected,
    required this.isHovered,
    this.isDarkMode = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double chamfer = 24.0;
    final double stepW = 58.0;
    final double stepH = 14.0;
    final double stepDiag = 12.0;

    // 1. Main polygon path
    final mainPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w - chamfer, 0)
      ..lineTo(w, chamfer)
      ..lineTo(w, h - stepH)
      ..lineTo(w - stepW + stepDiag, h - stepH)
      ..lineTo(w - stepW, h)
      ..lineTo(0, h)
      ..close();

    // 2. Fill background
    final bgPaint = Paint()
      ..color = isDarkMode
          ? (isSelected
              ? accentColor.withOpacity(0.18)
              : (isHovered ? const Color(0xFF141812) : const Color(0xFF0C0E0B)))
          : accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainPath, bgPaint);

    final overlayPaint = Paint()
      ..color = isDarkMode
          ? accentColor
              .withOpacity(isSelected ? 0.10 : (isHovered ? 0.08 : 0.04))
          : (isSelected
              ? Colors.black.withOpacity(0.08)
              : (isHovered
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent))
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainPath, overlayPaint);

    // 3. Faint dashed interior grid lines
    final gridPaint = Paint()
      ..color = isDarkMode
          ? accentColor
              .withOpacity(isSelected ? 0.28 : (isHovered ? 0.20 : 0.12))
          : const Color(0xFF0A0A0E)
              .withOpacity(isSelected ? 0.16 : (isHovered ? 0.10 : 0.05))
      ..strokeWidth = 1.0;

    // Center horizontal dashed line
    _drawDashedLine(canvas, Offset(8, h * 0.48),
        Offset(w - chamfer - 4, h * 0.48), gridPaint);
    // Vertical dashed lines
    _drawDashedLine(
        canvas, Offset(w * 0.28, 6), Offset(w * 0.28, h - 8), gridPaint);
    _drawDashedLine(
        canvas, Offset(w * 0.54, 6), Offset(w * 0.54, h - 8), gridPaint);
    _drawDashedLine(canvas, Offset(w * 0.78, chamfer),
        Offset(w * 0.78, h - stepH - 4), gridPaint);

    // 4. Solid accent triangle at top-right corner
    final trianglePath = Path()
      ..moveTo(w - chamfer + 5, 0)
      ..lineTo(w, 0)
      ..lineTo(w, chamfer - 5)
      ..close();
    final trianglePaint = Paint()
      ..color = isDarkMode
          ? accentColor.withOpacity(isSelected || isHovered ? 1.0 : 0.85)
          : const Color(0xFF0A0A0E)
              .withOpacity(isSelected || isHovered ? 0.85 : 0.50)
      ..style = PaintingStyle.fill;
    canvas.drawPath(trianglePath, trianglePaint);

    // 5. Bottom-Right Hazard Stripes
    final hazardClip = Path()
      ..moveTo(w - stepW + stepDiag + 2, h)
      ..lineTo(w - stepW + stepDiag + 10, h - stepH + 2)
      ..lineTo(w - 2, h - stepH + 2)
      ..lineTo(w - 2, h)
      ..close();

    canvas.save();
    canvas.clipPath(hazardClip);
    final hazardBgPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF070906)
          : const Color(0xFF0A0A0E).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(w - stepW, h - stepH, w, h), hazardBgPaint);

    final stripePaint = Paint()
      ..color = isDarkMode
          ? accentColor.withOpacity(isSelected || isHovered ? 1.0 : 0.75)
          : const Color(0xFF0A0A0E)
              .withOpacity(isSelected || isHovered ? 0.65 : 0.40)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    for (double x = w - stepW - 10; x < w + 20; x += 7.0) {
      canvas.drawLine(
          Offset(x, h + 5), Offset(x + 10, h - stepH - 5), stripePaint);
    }
    canvas.restore();

    // 6. Left edge thick accent bar
    final leftBarPaint = Paint()
      ..color = isDarkMode
          ? accentColor
              .withOpacity(isSelected ? 0.95 : (isHovered ? 0.85 : 0.60))
          : const Color(0xFF0A0A0E)
              .withOpacity(isSelected ? 0.95 : (isHovered ? 0.80 : 0.55))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(1.5, 3), Offset(1.5, h - 3), leftBarPaint);

    // 7. Outer border stroke around main path
    final outerBorderPaint = Paint()
      ..color = isDarkMode
          ? (isSelected
              ? accentColor
              : (isHovered
                  ? accentColor.withOpacity(0.85)
                  : accentColor.withOpacity(0.50)))
          : (isSelected
              ? const Color(0xFF0A0A0E)
              : (isHovered
                  ? const Color(0xFF0A0A0E)
                  : const Color(0xFF0A0A0E).withOpacity(0.25)))
      ..strokeWidth = isSelected ? 2.2 : (isHovered ? 1.8 : 1.2)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(mainPath, outerBorderPaint);

    // 8. Glowing / thick bottom accent line
    final bottomLedgePath = Path()
      ..moveTo(0, h)
      ..lineTo(w - stepW, h)
      ..lineTo(w - stepW + stepDiag, h - stepH)
      ..lineTo(w, h - stepH);

    final bottomLedgePaint = Paint()
      ..color = isDarkMode
          ? accentColor
          : const Color(0xFF0A0A0E)
              .withOpacity(isSelected ? 1.0 : (isHovered ? 0.85 : 0.60))
      ..strokeWidth = isSelected ? 2.8 : 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bottomLedgePath, bottomLedgePaint);

    // Glowing blur when selected or hovered (in dark mode only)
    if (isDarkMode && (isSelected || isHovered)) {
      final glowPaint = Paint()
        ..color = accentColor.withOpacity(isSelected ? 0.35 : 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(mainPath, glowPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double dist = sqrt(dx * dx + dy * dy);
    if (dist <= 0) return;
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double current = 0.0;
    while (current < dist) {
      final double startFraction = current / dist;
      final double endFraction = min(dist, current + dashWidth) / dist;
      canvas.drawLine(
        Offset(p1.dx + dx * startFraction, p1.dy + dy * startFraction),
        Offset(p1.dx + dx * endFraction, p1.dy + dy * endFraction),
        paint,
      );
      current += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _SimulationHudCardPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
