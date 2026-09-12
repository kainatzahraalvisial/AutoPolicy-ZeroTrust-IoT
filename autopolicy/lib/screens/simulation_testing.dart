import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/device.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
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
      'color': const Color(0xFFFFE997),
      'tag': 'SCN-1',
      'packetsPerSec': '12,500 pkts/s',
      'vector': 'TCP SYN + UDP Flood',
      'blockedRate': 99.2,
      'leakedRate': 0.8,
      'falsePositive': 0.8,
      'regoRule': 'deny[msg] {\n  input.packet_rate > 5000\n  msg := "Rate limit exceeded (DDoS SYN Mitigation)"\n}',
    },
    {
      'title': 'Port Scanner & Lateral Movement',
      'subtitle': 'Aggressive Nmap SYN-scan across subnets looking for open ports',
      'icon': Icons.radar_outlined,
      'color': const Color(0xFFA88AED),
      'tag': 'SCN-2',
      'packetsPerSec': '3,400 pkts/s',
      'vector': 'Stealth SYN Scan',
      'blockedRate': 98.6,
      'leakedRate': 1.4,
      'falsePositive': 1.4,
      'regoRule': 'deny[msg] {\n  input.port_sweep_count > 15\n  not input.admin_authorized\n  msg := "Lateral scan detected"\n}',
    },
    {
      'title': 'Modbus MitM Injection',
      'subtitle': 'Unauthorized Function Code 0x05 write to PLC coil registers',
      'icon': Icons.precision_manufacturing_outlined,
      'color': const Color(0xFFC4E320),
      'tag': 'SCN-3',
      'packetsPerSec': '450 pkts/s',
      'vector': 'Modbus TCP Register Override',
      'blockedRate': 100.0,
      'leakedRate': 0.0,
      'falsePositive': 0.0,
      'regoRule': 'deny[msg] {\n  input.protocol == "modbus"\n  input.function_code == 5\n  input.role != "scada_admin"\n  msg := "Modbus write denied"\n}',
    },
    {
      'title': 'Data Exfiltration Stress Test',
      'subtitle': 'Simulated payload exfiltration via DNS tunneling and HTTPS',
      'icon': Icons.cloud_upload_outlined,
      'color': const Color(0xFF80A416),
      'tag': 'SCN-4',
      'packetsPerSec': '1,200 pkts/s',
      'vector': 'DNS Tunneling Chunking',
      'blockedRate': 97.8,
      'leakedRate': 2.2,
      'falsePositive': 2.1,
      'regoRule': 'deny[msg] {\n  input.dns_query_len > 180\n  not input.fqdn_whitelisted\n  msg := "DNS Tunneling signature blocked"\n}',
    },
    {
      'title': 'Custom PCAP Replay',
      'subtitle': 'Replay recorded attack capture against current OPA Rego policies',
      'icon': Icons.upload_file_outlined,
      'color': const Color(0xFFDF2531),
      'tag': 'SCN-5',
      'packetsPerSec': '5,000 pkts/s',
      'vector': 'Recorded PCAP Tracefile',
      'blockedRate': 99.5,
      'leakedRate': 0.5,
      'falsePositive': 0.5,
      'regoRule': 'deny[msg] {\n  input.signature_matched\n  msg := "Known threat payload signature quarantined"\n}',
    },
  ];

  final List<String> _simLogs = [];

  void _runSimulation() {
    if (_isExecuting || _selectedScenarioIdx == null) return;
    final currentScenario = _scenarios[_selectedScenarioIdx!];

    setState(() {
      _isExecuting = true;
      _execProgress = 0.0;
      _simLogs.clear();
      _simLogs.add('[INIT] Isolating simulation virtual sandbox environment...');
      _simLogs.add('[PCAP] Streaming ${currentScenario['vector']} payload across virtual interfaces...');
    });

    Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _execProgress += 0.20;
        if (_execProgress >= 0.4 && _simLogs.length < 3) {
          _simLogs.add('[OPA] Sidecar microsegments evaluating ${currentScenario['packetsPerSec']}...');
        }
        if (_execProgress >= 0.7 && _simLogs.length < 4) {
          _simLogs.add('[GNN] Node correlation updated: Threat signature confirmed.');
        }
        if (_execProgress >= 1.0) {
          _execProgress = 1.0;
          _isExecuting = false;
          _simLogs.add('[SUCCESS] Simulation complete: ${currentScenario['blockedRate']}% of attack vectors blocked.');
          timer.cancel();

          if (_selectedTargetDeviceId != null) {
            ref.read(securityProvider.notifier).manualAttackTrigger(
              _selectedTargetDeviceId!,
              currentScenario['vector'] as String,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final eligibleDevices = securityState.devices.where((d) => d.status == DeviceStatus.safe).toList();
    final bool isMobile = Responsive.isMobile(context);

    // Bulletproof device ID resolution to prevent dropdown assertion crashes
    String? effectiveDeviceId = _selectedTargetDeviceId;
    if (eligibleDevices.isNotEmpty && (effectiveDeviceId == null || !eligibleDevices.any((d) => d.id == effectiveDeviceId))) {
      effectiveDeviceId = eligibleDevices.first.id;
      _selectedTargetDeviceId = effectiveDeviceId;
    }

    final activeScenario = _selectedScenarioIdx != null ? _scenarios[_selectedScenarioIdx!] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header with Badge
            _buildPageHeader(),
            const SizedBox(height: 16),

            // SECTION 1: Scenario Selection (Horizontal 5 Selectable Cards)
            _buildScenarioSelectionRow(),
            const SizedBox(height: 16),

            // SECTION 2: Two-Column Workstation (Left 40% Config, Right 60% Results)
            if (activeScenario == null)
              _buildEmptyState()
            else if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (~40%): Scenario Configuration
                  Expanded(
                    flex: 4,
                    child: _buildScenarioConfigCard(activeScenario, eligibleDevices, effectiveDeviceId),
                  ),
                  const SizedBox(width: 16),
                  // Right Column (~60%): Results & Metrics
                  Expanded(
                    flex: 6,
                    child: _buildResultsAndMetricsCard(activeScenario),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildScenarioConfigCard(activeScenario, eligibleDevices, effectiveDeviceId),
                  const SizedBox(height: 16),
                  _buildResultsAndMetricsCard(activeScenario),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIMULATION TESTING WORKSTATION',
              style: CyberTextStyles.displayTitle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF5DD62C),
              ).copyWith(letterSpacing: 2.0),
            ),
            const SizedBox(height: 3),
            Text(
              'Stress-test Zero-Trust policies in a safe sandbox',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Badge on right side
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5DD62C).withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF5DD62C), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF5DD62C), size: 16),
              const SizedBox(width: 6),
              Text(
                'SANDBOX ISOLATED – ZERO PROD LEAKAGE',
                style: CyberTextStyles.technical(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── SECTION 1: SCENARIO SELECTION (HORIZONTAL 5 CARDS) ─────────────────────
  Widget _buildScenarioSelectionRow() {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return SizedBox(
        height: 126,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _scenarios.length,
          itemBuilder: (context, idx) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildScenarioTile(idx, 260),
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
              padding: EdgeInsets.only(right: idx < _scenarios.length - 1 ? 10.0 : 0.0),
              child: _buildScenarioTile(idx, null),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScenarioTile(int idx, double? width) {
    final scn = _scenarios[idx];
    final bool isSelected = _selectedScenarioIdx == idx;
    final bool isHovered = _hoveredScenarioIdx == idx;
    final Color color = scn['color'] as Color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredScenarioIdx = idx),
      onExit: (_) => setState(() => _hoveredScenarioIdx = null),
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
          ),
          child: Container(
            width: width,
            height: 126,
            padding: const EdgeInsets.only(top: 10, left: 14, right: 26, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(scn['icon'] as IconData, size: 20, color: color),
                    Text(
                      scn['tag'] as String,
                      style: CyberTextStyles.technical(
                        fontSize: 11.5,
                        color: color,
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
                        color: Colors.white,
                      ).copyWith(letterSpacing: 0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scn['subtitle'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70,
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
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.touch_app_outlined, size: 36, color: Colors.white30),
            const SizedBox(height: 12),
            Text(
              'Select a simulation scenario above to begin',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ── LEFT COLUMN: SCENARIO CONFIGURATION (≈40%) ─────────────────────────────
  Widget _buildScenarioConfigCard(Map<String, dynamic> scenario, List<IoTDevice> eligibleDevices, String? effectiveDeviceId) {
    final Color color = scenario['color'] as Color;

    return CyberHudCard(
      tag: scenario['tag'] as String,
      borderColor: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            Row(
              children: [
                Icon(Icons.tune_outlined, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  'SCENARIO CONFIGURATION',
                  style: CyberTextStyles.technical(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF252525), height: 1),
            const SizedBox(height: 14),

            // Target System Asset (SAFE DROPDOWN)
            Text('TARGET SYSTEM ASSET', style: CyberTextStyles.technical(fontSize: 10.5, color: const Color(0xFF5DD62C), fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (eligibleDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(4)),
                child: Text('NO SAFE DEVICES DETECTED (ALL QUARANTINED)', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: effectiveDeviceId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF161616),
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                    items: eligibleDevices.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text('${d.name.toUpperCase()} (${d.ipAddress})'),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      if (val != null) setState(() => _selectedTargetDeviceId = val);
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
                      Text('THROUGHPUT VOLUME', style: CyberTextStyles.technical(fontSize: 10, color: Colors.white54)),
                      const SizedBox(height: 3),
                      Text(scenario['packetsPerSec'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTACK VECTOR SIGNATURE', style: CyberTextStyles.technical(fontSize: 10, color: Colors.white54)),
                      const SizedBox(height: 3),
                      Text(scenario['vector'] as String, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
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
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildConfigParamRow('VIRTUAL SANDBOX INTERFACE', 'veth_isolated_0'),
                  const SizedBox(height: 6),
                  _buildConfigParamRow('OPA SIDECAR ENFORCEMENT', 'ACTIVE (Localhost:8181)'),
                  const SizedBox(height: 6),
                  _buildConfigParamRow('CONCURRENT THREAT WORKERS', '16 Workers (Multi-threaded)'),
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
                  backgroundColor: const Color(0xFF222222),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
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
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: Icon(_isExecuting ? Icons.hourglass_top : Icons.play_arrow, size: 18, color: Colors.black),
                label: Text(
                  _isExecuting ? 'SIMULATING THREAT SURGE...' : 'EXECUTE ISOLATED SIMULATION',
                  style: CyberTextStyles.technical(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onPressed: _isExecuting ? null : _runSimulation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigParamRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CyberTextStyles.technical(fontSize: 9.5, color: Colors.white54)),
        Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, color: const Color(0xFFC5C764), fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── RIGHT COLUMN: RESULTS & METRICS CARD (≈60%) ────────────────────────────
  Widget _buildResultsAndMetricsCard(Map<String, dynamic> scenario) {
    final Color color = scenario['color'] as Color;
    final double blocked = scenario['blockedRate'] as double;
    final double leaked = scenario['leakedRate'] as double;
    final double falsePos = scenario['falsePositive'] as double;

    return CyberHudCard(
      tag: 'RES-01',
      borderColor: const Color(0xFF5DD62C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: Color(0xFF5DD62C), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'RESULTS & MITIGATION METRICS',
                      style: CyberTextStyles.technical(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  'OPA ZERO-TRUST STATUS',
                  style: CyberTextStyles.technical(fontSize: 9.5, color: const Color(0xFF5DD62C)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF252525), height: 1),
            const SizedBox(height: 14),

            // Big Key Metrics (Blocked vs Leaked)
            Row(
              children: [
                // Threat Vectors Blocked (Big %)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5DD62C).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THREAT VECTORS BLOCKED', style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFF5DD62C), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$blocked%', style: GoogleFonts.barlow(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF5DD62C))),
                        Text('Quarantined before core mesh penetration', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
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
                      color: const Color(0xFFDF2531).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFDF2531).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LEAKED / UNCONTAINED', style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFFDF2531), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$leaked%', style: GoogleFonts.barlow(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFDF2531))),
                        Text(leaked == 0 ? 'Zero blast radius exposure' : 'Surged packets during policy handshake', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
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
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FALSE POSITIVE RISK GAUGE', style: CyberTextStyles.technical(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('$falsePos% RISK INDEX', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFFFE997))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (falsePos / 10).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFF222222),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFE997)),
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
                color: const Color(0xFF070707),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFC4E320).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFC4E320), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'AI REGO POLICY RECOMMENDATION',
                        style: CyberTextStyles.technical(fontSize: 10.5, color: const Color(0xFFC4E320), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenario['regoRule'] as String,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFFC4E320)),
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
                color: const Color(0xFF050505),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white10),
              ),
              child: _simLogs.isEmpty
                  ? Center(child: Text('Awaiting simulation trigger...', style: CyberTextStyles.technical(fontSize: 10.5, color: Colors.white30)))
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
                              color: idx == _simLogs.length - 1 ? const Color(0xFF5DD62C) : Colors.white60,
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

  _SimulationHudCardPainter({
    required this.accentColor,
    required this.isSelected,
    required this.isHovered,
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
      ..color = isSelected
          ? accentColor.withOpacity(0.18)
          : (isHovered ? const Color(0xFF141812) : const Color(0xFF0C0E0B))
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainPath, bgPaint);

    final overlayPaint = Paint()
      ..color = accentColor.withOpacity(isSelected ? 0.10 : (isHovered ? 0.08 : 0.04))
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainPath, overlayPaint);

    // 3. Faint dashed interior grid lines
    final gridPaint = Paint()
      ..color = accentColor.withOpacity(isSelected ? 0.28 : (isHovered ? 0.20 : 0.12))
      ..strokeWidth = 1.0;

    // Center horizontal dashed line
    _drawDashedLine(canvas, Offset(8, h * 0.48), Offset(w - chamfer - 4, h * 0.48), gridPaint);
    // Vertical dashed lines
    _drawDashedLine(canvas, Offset(w * 0.28, 6), Offset(w * 0.28, h - 8), gridPaint);
    _drawDashedLine(canvas, Offset(w * 0.54, 6), Offset(w * 0.54, h - 8), gridPaint);
    _drawDashedLine(canvas, Offset(w * 0.78, chamfer), Offset(w * 0.78, h - stepH - 4), gridPaint);

    // 4. Solid accent triangle at top-right corner
    final trianglePath = Path()
      ..moveTo(w - chamfer + 5, 0)
      ..lineTo(w, 0)
      ..lineTo(w, chamfer - 5)
      ..close();
    final trianglePaint = Paint()
      ..color = accentColor.withOpacity(isSelected || isHovered ? 1.0 : 0.85)
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
      ..color = const Color(0xFF070906)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(w - stepW, h - stepH, w, h), hazardBgPaint);

    final stripePaint = Paint()
      ..color = accentColor.withOpacity(isSelected || isHovered ? 1.0 : 0.75)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    for (double x = w - stepW - 10; x < w + 20; x += 7.0) {
      canvas.drawLine(Offset(x, h + 5), Offset(x + 10, h - stepH - 5), stripePaint);
    }
    canvas.restore();

    // 6. Left edge thick accent bar
    final leftBarPaint = Paint()
      ..color = accentColor.withOpacity(isSelected ? 0.95 : (isHovered ? 0.85 : 0.60))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(1.5, 3), Offset(1.5, h - 3), leftBarPaint);

    // 7. Outer border stroke around main path
    final outerBorderPaint = Paint()
      ..color = isSelected
          ? accentColor
          : (isHovered ? accentColor.withOpacity(0.85) : accentColor.withOpacity(0.50))
      ..strokeWidth = isSelected ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(mainPath, outerBorderPaint);

    // 8. Glowing / thick bottom accent line (as in Image 4)
    final bottomLedgePath = Path()
      ..moveTo(0, h)
      ..lineTo(w - stepW, h)
      ..lineTo(w - stepW + stepDiag, h - stepH)
      ..lineTo(w, h - stepH);

    final bottomLedgePaint = Paint()
      ..color = accentColor
      ..strokeWidth = isSelected ? 2.8 : 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bottomLedgePath, bottomLedgePaint);

    // Glowing blur when selected or hovered
    if (isSelected || isHovered) {
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
        oldDelegate.isHovered != isHovered;
  }
}
