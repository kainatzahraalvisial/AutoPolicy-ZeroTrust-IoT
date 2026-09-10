import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_hud_frame.dart';
import '../widgets/global_soc_ingress_map.dart';
import '../widgets/cyber_flow_bar_chart.dart';
import '../widgets/cyber_radial_donut_chart.dart';
import '../widgets/cyber_stat_card.dart';
import '../models/policy.dart';

class DashboardOverview extends ConsumerStatefulWidget {
  const DashboardOverview({super.key});

  @override
  ConsumerState<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends ConsumerState<DashboardOverview> {
  late final Timer _logTimer;
  final List<String> _systemLogs = [
    '[13:42:10] IDS Engine -> Captured 1.4k MQTT pkts/s',
    '[13:42:12] GNN Model -> Evaluated IoT graph topology',
    '[13:42:15] OPA Rego -> Microsegmentation rule #1042 compiled',
    '[13:42:18] Zero-Trust -> Microsegment quarantine enforced',
    '[13:42:20] All 12 IoT Edge gateways online & safe',
  ];

  @override
  void initState() {
    super.initState();
    _logTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        final now = DateTime.now();
        final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        final sampleLogs = [
          '[$timeStr] IDS Engine -> MQTT ingress flow scanned clean',
          '[$timeStr] GNN Model -> IoT communication graph evaluated',
          '[$timeStr] OPA Policy -> Rego rule active on EU-Central',
          '[$timeStr] IDS Engine -> CoAP DTLS handshake verified',
          '[$timeStr] GNN Model -> Threat anomaly score: 0.01',
        ];
        setState(() {
          _systemLogs.insert(0, sampleLogs[now.second % sampleLogs.length]);
          if (_systemLogs.length > 8) _systemLogs.removeLast();
        });
      }
    });
  }

  @override
  void dispose() {
    _logTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final totalDevices = securityState.devices.length;
    final activeThreats = securityState.anomalies.where((anm) => !anm.isMitigated).length;
    final generatedPoliciesCount = securityState.policies.length;
    final blockedAttacksCount = securityState.totalBlockedAttacks;
    final pendingApprovalsCount = securityState.policies.where((p) => p.status == PolicyStatus.pending).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. TOP TERMINAL HEADER BAR ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40), width: 1.0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUTOPOLICY ZERO-TRUST SOC DASHBOARD',
                        style: CyberTextStyles.displayTitle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF5DD62C),
                        ).copyWith(letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'ROLE: ADMINISTRATOR (RBAC ENFORCED)',
                            style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: const Color(0xFF8B5CF6), // Purple Accent!
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'SYSTEM STATUS: ZERO-TRUST ENFORCING',
                            style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: const Color(0xFFC5C764),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── 2. ESSENTIAL FIGURE CARDS GRID (EXACT 5-COLOR SEQUENCE) ──
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 5),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isMobile ? 2.5 : 1.5,
              children: [
                CyberStatCard(
                  title: 'TOTAL IOT DEVICES',
                  value: '$totalDevices',
                  sub: '12 Connected Nodes',
                  icon: Icons.router_outlined,
                  borderColor: const Color(0xFFFFE997), // 1. Yellow (#FFE997)
                  tag: 'H17',
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).state = 6;
                  },
                ),
                CyberStatCard(
                  title: 'POLICIES DEPLOYED',
                  value: '$generatedPoliciesCount',
                  sub: 'OPA Rego Enforced',
                  icon: Icons.rule_folder_outlined,
                  borderColor: const Color(0xFFA88AED), // 2. Indigo Purple (#A88AED)
                  tag: 'H18',
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).state = 5;
                  },
                ),
                CyberStatCard(
                  title: 'BLOCKED ATTACKS',
                  value: '$blockedAttacksCount',
                  sub: 'Quarantined Flows',
                  icon: Icons.gpp_good_outlined,
                  borderColor: const Color(0xFFC4E320), // 3. Bright Light Green (#C4E320)
                  tag: 'H19',
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).state = 1;
                  },
                ),
                CyberStatCard(
                  title: 'PENDING APPROVALS',
                  value: '$pendingApprovalsCount',
                  sub: 'Awaiting Sign-off',
                  icon: Icons.pending_actions_outlined,
                  borderColor: const Color(0xFF80A416), // 4. Olive Green (#80A416)
                  tag: 'H20',
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).state = 5;
                  },
                ),
                CyberStatCard(
                  title: 'ACTIVE THREATS [IDS/GNN]',
                  value: '$activeThreats',
                  sub: activeThreats > 0 ? 'Critical Quarantine' : 'Zero Threat Spikes',
                  icon: Icons.gpp_maybe_outlined,
                  borderColor: const Color(0xFFB91C1D), // 5. Crimson Red (#B91C1D)
                  isAlert: activeThreats > 0,
                  tag: 'H21',
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).state = 2;
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── 3. MAIN 3-COLUMN TERMINAL SECTION (HERO MAP & CONTROLS) ──────
            if (!isMobile && !isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Quick Actions & Architecture Status
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildLeftQuickActions(),
                        const SizedBox(height: 12),
                        _buildLeftModelArchitectureStatus(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // CENTER COLUMN: Global SOC Ingress Map (Hero)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: const [
                        GlobalSocIngressMap(height: 380),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // RIGHT COLUMN: Policy Controls & Real-Time Feed
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildRightPolicyControls(),
                        const SizedBox(height: 12),
                        _buildRightRealTimeFeed(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const GlobalSocIngressMap(height: 340),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildLeftQuickActions(),
                            const SizedBox(height: 12),
                            _buildLeftModelArchitectureStatus(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRightPolicyControls(),
                            const SizedBox(height: 12),
                            _buildRightRealTimeFeed(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 14),

            // ── 4. BOTTOM ROW GRID (DONUT CHART & LIVE SYSTEM LOG) ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donut Chart: Threat Classification
                const Expanded(
                  flex: 5,
                  child: CyberRadialDonutChart(height: 190),
                ),
                const SizedBox(width: 12),

                // Live Security & Audit Log Panel
                Expanded(
                  flex: 6,
                  child: _buildSystemLogPanel(height: 190),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── 5. BOTTOM SYSTEM MESSAGE FOOTER ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.45), width: 1.0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PIPELINE STATUS: IDS Capture → GNN Classification → OPA Enforcement Active.',
                        style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: const Color(0xFF5DD62C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '99.4% HEALTH',
                        style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 0.994,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF202020),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
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

  // ── HELPER WIDGETS & INTERACTIVE ACTION LISTENERS ─────────────────────────

  Widget _windowBtn(String symbol, {bool isClose = false}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isClose ? const Color(0x35DF2531) : const Color(0x208B5CF6),
        border: Border.all(
          color: isClose ? const Color(0xFFDF2531) : const Color(0xFF8B5CF6).withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isClose ? const Color(0xFFDF2531) : const Color(0xFFF8F8F8),
          ),
        ),
      ),
    );
  }

  // Tactical Figure Card with Frame (media_1788769893400.png) - Fixed Padding & Spacing!
  Widget _buildTacticalFigureCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color borderColor,
    required int targetTab,
    bool isValueAlert = false,
  }) {
    final Color valueColor = isValueAlert ? const Color(0xFFDF2531) : const Color(0xFFF8F8F8);

    return CyberHudFrame(
      design: CyberFrameDesign.tacticalArmorNotch,
      baseBorderColor: borderColor,
      hoverBorderColor: borderColor,
      surfaceColor: borderColor.withOpacity(0.14),
      // Increased top padding to 24px so title is NOT squished against upper armor notch!
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      onTap: () {
        ref.read(navigationTabProvider.notifier).state = targetTab;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: CyberTextStyles.technical(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC5C764),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: borderColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: CyberTextStyles.displayTitle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sub,
                  style: CyberTextStyles.techMuted.copyWith(
                    fontSize: 9,
                    color: const Color(0xFF5E7343),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Segmented baseline indicator
          Row(
            children: List.generate(
              10,
              (idx) => Expanded(
                child: Container(
                  height: 2.5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  color: idx < 7 ? borderColor : borderColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Panel (Left Column)
  Widget _buildLeftQuickActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B5CF6), // Purple Accent!
            ),
          ),
          const SizedBox(height: 10),
          _actionItem('[+] Generate OPA Policy', 4),
          _actionItem('[⚡] Trigger GNN Graph Scan', 3),
          _actionItem('[📡] Inspect IDS Packet Feed', 1),
          _actionItem('[🛡️] Quarantine IoT Device', 6),
          _actionItem('[📋] View Pending Sign-offs', 5),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF8B5CF6), width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  'IDS → GNN → OPA ACTIVE 🛡️',
                  style: CyberTextStyles.technical(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8F8F8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(String label, int targetTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: InkWell(
        onTap: () => ref.read(navigationTabProvider.notifier).state = targetTab,
        borderRadius: BorderRadius.circular(3),
        child: Text(
          label,
          style: CyberTextStyles.technical(
            fontSize: 9.5,
            color: const Color(0xFF5DD62C),
          ),
        ),
      ),
    );
  }

  // Model & Pipeline Health (Left Column)
  Widget _buildLeftPipelineHealth() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIPELINE & MODEL HEALTH',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5DD62C),
            ),
          ),
          const SizedBox(height: 10),
          _healthRow('IDS Ingress Rate', '1.4k pkts/s', 1),
          _healthRow('GNN Graph Accuracy', '98.6%', 3),
          _healthRow('OPA Rego Latency', '1.2 ms', 4),
          _healthRow('IoT Mesh Status', '99.4%', 6),
          _healthRow('RBAC Security', 'Enforced', 9),
        ],
      ),
    );
  }

  Widget _healthRow(String k, String v, int targetTab) {
    return InkWell(
      onTap: () => ref.read(navigationTabProvider.notifier).state = targetTab,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                k,
                style: CyberTextStyles.technical(fontSize: 9.5, color: const Color(0xFF5E7343)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              v,
              style: CyberTextStyles.technical(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)),
            ),
          ],
        ),
      ),
    );
  }

  // Policy & Threat Controls (Right Column)
  Widget _buildRightPolicyControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIPELINE STAGE CONTROLS',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 10),
          _controlRow('1. IDS CAPTURE', '> ACTIVE', 1),
          _controlRow('2. GNN CLASSIFIER', '> SCANNING', 3),
          _controlRow('3. OPA REGO ENGINE', '> ENFORCING', 4),
          _controlRow('4. AUTO QUARANTINE', '> ENABLED', 5),
        ],
      ),
    );
  }

  Widget _controlRow(String k, String v, int targetTab) {
    return InkWell(
      onTap: () => ref.read(navigationTabProvider.notifier).state = targetTab,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                k,
                style: CyberTextStyles.technical(fontSize: 9, color: const Color(0xFF5E7343)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              v,
              style: CyberTextStyles.technical(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)),
            ),
          ],
        ),
      ),
    );
  }

  // Live IoT Protocol Feed (Right Column)
  Widget _buildRightRealTimeFeed() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIVE IOT TELEMETRY FEED',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5DD62C),
            ),
          ),
          const SizedBox(height: 10),
          _feedItem('MQTT / TLS 1.3', '542 pkts/s'),
          _feedItem('CoAP / DTLS', '318 pkts/s'),
          _feedItem('HTTP/2 REST', '142 pkts/s'),
          _feedItem('gRPC / REGO', '595 rules/s'),
        ],
      ),
    );
  }

  Widget _feedItem(String proto, String val) {
    return InkWell(
      onTap: () => ref.read(navigationTabProvider.notifier).state = 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                proto,
                style: CyberTextStyles.technical(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              val,
              style: CyberTextStyles.technical(fontSize: 9, color: const Color(0xFFAD9F3C)),
            ),
          ],
        ),
      ),
    );
  }

  // Model & AI Architecture Status (Left Column 3rd Card)
  Widget _buildLeftModelArchitectureStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODEL ARCHITECTURE STATUS',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00F0FF),
            ),
          ),
          const SizedBox(height: 10),
          _healthRow('PyTorch Transformer', '1.07M Params', 4),
          _healthRow('GNN Node Embeddings', '64 Dim', 3),
          _healthRow('Zero-Leakage Hash', 'Verified (H0)', 4),
          _healthRow('OPA Rego Compiler', '100% Valid', 5),
        ],
      ),
    );
  }

  // Active Rule Summary (Right Column 3rd Card)
  Widget _buildRightActiveRuleSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE POLICY RULE SUMMARY',
            style: CyberTextStyles.technical(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00F0FF),
            ),
          ),
          const SizedBox(height: 10),
          _controlRow('DENY ALL ATTACKS', 'ENFORCED', 5),
          _controlRow('MQTT MICROSEGMENT', 'ACTIVE', 5),
          _controlRow('COAP RATE-LIMIT', 'ACTIVE', 5),
          _controlRow('DEVICE QUARANTINE', 'ENABLED', 2),
        ],
      ),
    );
  }

  // System & Incident Log Panel (Bottom Row Right)
  Widget _buildSystemLogPanel({required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SECURITY & AUDIT LOG',
                style: CyberTextStyles.technical(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5DD62C),
                ),
              ),
              InkWell(
                onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                child: Text(
                  'VIEW ANOMALIES →',
                  style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5, color: const Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _systemLogs.length,
              itemBuilder: (context, idx) {
                return InkWell(
                  onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Text(
                      _systemLogs[idx],
                      style: CyberTextStyles.technical(
                        fontSize: 9.5,
                        color: idx == 0 ? const Color(0xFF5DD62C) : const Color(0xFF5E7343),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
