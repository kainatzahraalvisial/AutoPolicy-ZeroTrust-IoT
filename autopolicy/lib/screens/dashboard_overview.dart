import '../widgets/cyber_hud_frame.dart';
import '../widgets/console_row.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_radial_donut_chart.dart';
import '../widgets/cyber_stat_card.dart';
import '../widgets/cyber_traffic_line_chart.dart';
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

  // Recent 5 alerts mock data per admin specification
  final List<Map<String, dynamic>> _recentAlerts = [
    {
      'time': '14:18:22',
      'device': 'Edge Gateway 01',
      'ip': '10.128.4.12',
      'attack': 'Syn-Flood DDoS Surge',
      'severity': 'CRITICAL',
      'color': const Color(0xFFD82734),
    },
    {
      'time': '14:12:05',
      'device': 'Smart Meter Alpha',
      'ip': '10.128.4.45',
      'attack': 'Port Scan Sweep',
      'severity': 'HIGH',
      'color': const Color(0xFFE87D85),
    },
    {
      'time': '13:58:40',
      'device': 'Valve Actuator 04',
      'ip': '10.128.8.19',
      'attack': 'Unauthorized Modbus Write',
      'severity': 'CRITICAL',
      'color': const Color(0xFFD82734),
    },
    {
      'time': '13:45:11',
      'device': 'Camera Edge Node',
      'ip': '10.128.8.88',
      'attack': 'Data Exfiltration Spike',
      'severity': 'HIGH',
      'color': const Color(0xFFE87D85),
    },
    {
      'time': '13:20:00',
      'device': 'HVAC Controller',
      'ip': '10.128.4.99',
      'attack': 'ARP Poisoning Attempt',
      'severity': 'MEDIUM',
      'color': const Color(0xFFFFF4E1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _logTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        final now = DateTime.now();
        final timeStr =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
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
    final isDarkMode = ref.watch(themeModeProvider);
    final securityState = ref.watch(securityProvider);
    final authSession = ref.watch(authProvider);
    final String activeRole = authSession?.role ?? 'Admin';
    final bool isEngineer = activeRole.toLowerCase().contains('engineer');
    final bool isManager = activeRole.toLowerCase().contains('manager');

    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;

    final totalDevices =
        securityState.devices.isNotEmpty ? securityState.devices.length : 1248;
    final activeThreats =
        securityState.anomalies.where((anm) => !anm.isMitigated).length;
    final generatedPoliciesCount =
        securityState.policies.isNotEmpty ? securityState.policies.length : 342;
    final blockedAttacksCount = securityState.totalBlockedAttacks > 0
        ? securityState.totalBlockedAttacks
        : 4892;
    final pendingApprovalsCount = securityState.policies
        .where((p) => p.status == PolicyStatus.pending)
        .length;
    final int pendingCount =
        pendingApprovalsCount > 0 ? pendingApprovalsCount : 24;

    String headerTitle = 'AUTOPOLICY ZERO-TRUST SOC DASHBOARD';
    if (isEngineer) {
      headerTitle = 'OPERATIONAL SECURITY & INCIDENT CONSOLE';
    } else if (isManager) {
      headerTitle = 'EXECUTIVE SECURITY POSTURE & COMPLIANCE SUMMARY';
    }

    final cards = _buildRoleSpecificStatCards(
        context,
        isEngineer,
        isManager,
        totalDevices,
        activeThreats,
        generatedPoliciesCount,
        blockedAttacksCount,
        pendingCount);
    final left = Column(children: [
      CyberTrafficLineChart(
          height: 220,
          onViewDetails: () =>
              ref.read(navigationTabProvider.notifier).state = 1),
      const SizedBox(height: 8),
      _buildRecentAlertsTable(),
    ]);
    final right =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _buildPolicyStatusSummaryCard(),
      const SizedBox(height: 8),
      const CyberRadialDonutChart(height: 190),
      const SizedBox(height: 8),
      _buildSystemComponentHealthPanel(),
    ]);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width < 600 ? 12 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CyberHudFrame(
            design: CyberFrameDesign.tacticalArmorNotch,
            baseBorderColor: const Color(0xFFC4E326),
            hoverBorderColor: const Color(0xFFC4E326),
            ambientGlow: true,
            isInteractive: false,
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 850;
              final headerContent = [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(headerTitle,
                      style: CyberTextStyles.displayTitle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode
                              ? const Color(0xFF5DD62C)
                              : const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(
                      'ROLE: ${activeRole.toUpperCase()} - ZERO-TRUST ENFORCING',
                      style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold)),
                ]),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  _buildQuickActionBtn(
                      icon: Icons.pending_actions_outlined,
                      label: 'REVIEW POLICIES ($pendingCount)',
                      color: const Color(0xFFC4E320),
                      onTap: () =>
                          ref.read(navigationTabProvider.notifier).state = 4),
                  _buildQuickActionBtn(
                      icon: Icons.warning_amber_outlined,
                      label:
                          'CRITICAL ALERTS (${activeThreats > 0 ? activeThreats : 1})',
                      color: const Color(0xFFD82734),
                      onTap: () =>
                          ref.read(navigationTabProvider.notifier).state = 2),
                ]),
              ];

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent[0],
                    const SizedBox(height: 10),
                    headerContent[1],
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: headerContent[0]),
                  const SizedBox(width: 12),
                  headerContent[1],
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          GridView(
              clipBehavior: Clip.none,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width >= 768 ? 6 : (width >= 480 ? 3 : 2),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 114),
              children: cards),
          const SizedBox(height: 16),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 7, child: left),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: right),
            ])
          else ...[left, const SizedBox(height: 8), right],
          const SizedBox(height: 8),
          _buildSystemLogPanel(height: 95),
          const SizedBox(height: 8),
          Text(
              'ZERO-TRUST ENFORCING  ·  ZEEK / GNN / OPA  ·  99.4% HEALTH NOMINAL',
              style: GoogleFonts.inter(
                  fontSize: 9,
                  color: isDarkMode
                      ? const Color(0xFFB1A9DA)
                      : const Color(0xFF5E7343))),
        ]),
      ),
    );
  }

  List<Widget> _buildRoleSpecificStatCards(
    BuildContext context,
    bool isEngineer,
    bool isManager,
    int totalDevices,
    int activeThreats,
    int generatedPoliciesCount,
    int blockedAttacksCount,
    int pendingCount,
  ) {
    if (isManager) {
      return [
        CyberStatCard(
          title: 'SECURITY POSTURE SCORE',
          value: '94.0%',
          sub: '+2.4% this week',
          icon: Icons.shield_outlined,
          borderColor: const Color(0xFFFFF9E1),
          tag: 'M01',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 8,
        ),
        CyberStatCard(
          title: 'COMPLIANCE SCORE',
          value: '91.2%',
          sub: 'ISO 27001 / NIST SP 800-207',
          icon: Icons.verified_outlined,
          borderColor: const Color(0xFFEBECCC),
          tag: 'M02',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 8,
        ),
        CyberStatCard(
          title: 'MTTR (AVG RESP TIME)',
          value: '18 min',
          sub: '-4 min vs last month',
          icon: Icons.timer_outlined,
          borderColor: const Color(0xFFCDD4B2),
          tag: 'M03',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 8,
        ),
        CyberStatCard(
          title: 'TOTAL IOT ASSETS',
          value: totalDevices > 1000 ? '1,248' : '$totalDevices',
          sub: '1,220 Online · 22 Offline',
          icon: Icons.router_outlined,
          borderColor: const Color(0xFFD4C9D8),
          tag: 'M04',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 6,
        ),
        CyberStatCard(
          title: 'MITIGATED (30D)',
          value: '12.4K',
          sub: '100% Ingress Quarantined',
          icon: Icons.gpp_good_outlined,
          borderColor: const Color(0xFFB8A9C1),
          tag: 'M05',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 8,
        ),
        CyberStatCard(
          title: 'ACTIVE THREATS',
          value: activeThreats > 0 ? '$activeThreats' : '1',
          sub: '5 Critical · 12 High',
          icon: Icons.gpp_maybe_outlined,
          borderColor: const Color(0xFFD82734),
          isAlert: true,
          tag: 'M06',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
        ),
      ];
    }

    if (isEngineer) {
      return [
        CyberStatCard(
          title: 'PENDING REVIEWS',
          value: '$pendingCount',
          sub: 'Requires SOC Approval',
          icon: Icons.pending_actions_outlined,
          borderColor: const Color(0xFFFFF9E1),
          tag: 'E01',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
        ),
        CyberStatCard(
          title: 'BLOCKED ATTACKS 24H',
          value: '$blockedAttacksCount',
          sub: '100% Ingress Quarantined',
          icon: Icons.gpp_good_outlined,
          borderColor: const Color(0xFFEBECCC),
          tag: 'E02',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 1,
        ),
        CyberStatCard(
          title: 'INSPECTED FLOWS',
          value: '1.4M',
          sub: 'Zeek Packet Capture',
          icon: Icons.radar_outlined,
          borderColor: const Color(0xFFCDD4B2),
          tag: 'E03',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 1,
        ),
        CyberStatCard(
          title: 'GNN ACCURACY',
          value: '98.6%',
          sub: 'PyTorch Graph Model',
          icon: Icons.hub_outlined,
          borderColor: const Color(0xFFD4C9D8),
          tag: 'E04',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 3,
        ),
        CyberStatCard(
          title: 'ACTIVE POLICIES',
          value: '298',
          sub: 'OPA Rego Microsegments',
          icon: Icons.shield_outlined,
          borderColor: const Color(0xFFB8A9C1),
          tag: 'E05',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 5,
        ),
        CyberStatCard(
          title: 'ACTIVE THREATS',
          value: activeThreats > 0 ? '$activeThreats' : '1',
          sub: '5 Critical · 12 High',
          icon: Icons.gpp_maybe_outlined,
          borderColor: const Color(0xFFD82734),
          isAlert: true,
          tag: 'E06',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
        ),
      ];
    }

    // Default / Admin 6 Cards matching user image exactly
    return [
      CyberStatCard(
        title: 'TOTAL IOT DEVICES',
        value: '12',
        sub: '1,220 Online · 22 Offline',
        borderColor: const Color(0xFFFFEDA8),
        tag: '//17',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 6,
      ),
      CyberStatCard(
        title: 'POLICIES GENERATED',
        value: '1',
        sub: '1 Pending Review',
        borderColor: const Color(0xFFC4E326),
        tag: '//18',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
      ),
      CyberStatCard(
        title: 'POLICIES DEPLOYED',
        value: '298',
        sub: 'Active in OPA Sidecars',
        borderColor: const Color(0xFFB1A9DA),
        tag: '//19',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 5,
      ),
      CyberStatCard(
        title: 'BLOCKED ATTACKS 24H',
        value: '1420',
        sub: '100% Ingress Quarantined',
        borderColor: const Color(0xFF80A416),
        tag: '//20',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 1,
      ),
      CyberStatCard(
        title: 'SYSTEM HEALTH',
        value: '99.4%',
        sub: 'Zeek, GNN & OPA Nominal',
        borderColor: const Color(0xFF9D8DF1),
        tag: '//21',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 9,
      ),
      CyberStatCard(
        title: 'ACTIVE THREATS',
        value: '1',
        sub: '5 Critical · 12 High',
        icon: Icons.gpp_maybe_outlined,
        borderColor: const Color(0xFFD82734),
        isAlert: true,
        tag: '//22',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
      ),
    ];
  }

  // ── RECENT ALERTS TABLE (LAST 5) ──────────────────────────────────────────
  Widget _buildRecentAlertsTable() {
    final dark = ref.watch(themeModeProvider);
    return LayoutBuilder(builder: (context, bounds) {
      final compactRows = bounds.maxWidth >= 560;
      return CyberHudFrame(
        design: CyberFrameDesign.cornerPlate,
        baseBorderColor: const Color(0xFF9D8DF1),
        hoverBorderColor: const Color(0xFF9D8DF1),
        ambientGlow: true,
        isInteractive: false,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('RECENT THREAT ALERTS',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dark
                            ? const Color(0xFFC4E320)
                            : const Color(0xFF0F172A)))),
            TextButton(
                onPressed: () =>
                    ref.read(navigationTabProvider.notifier).state = 2,
                child:
                    const Text('View all >', style: TextStyle(fontSize: 10))),
          ]),
          ..._recentAlerts.map((alert) => InkWell(
                onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(children: [
                      Expanded(
                          flex: 5,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert['device'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: dark
                                            ? Colors.white
                                            : const Color(0xFF0F172A))),
                                const SizedBox(height: 3),
                                Text(alert['attack'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: dark
                                            ? const Color(0xFFB1A9DA)
                                            : const Color(0xFF777181))),
                              ])),
                      if (compactRows)
                        Expanded(
                            flex: 3,
                            child: Text('${alert['time']}  ·  ${alert['ip']}',
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: dark
                                        ? const Color(0xFFB1A9DA)
                                        : const Color(0xFF777181)))),
                      const SizedBox(width: 8),
                      _buildSeverityLegendChip(alert['severity'] as String,
                          alert['color'] as Color, dark),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right,
                          size: 14,
                          color: dark ? Colors.white38 : Colors.black38),
                    ])),
              )),
        ]),
      );
    });
  }

  Widget _buildSeverityLegendChip(String label, Color color, bool isDarkMode) {
    Color chipBg = color;
    Color chipBorder = color;
    Color chipText = Colors.white;
    if (label == 'MEDIUM') {
      chipBg = const Color(0xFFFFF4E1);
      chipBorder = const Color(0xFFE6D6B8);
      chipText = const Color(0xFF0F172A);
    }

    final chipWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: chipBorder, width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: chipText,
        ),
      ),
    );

    return chipWidget;
  }

  // ── POLICY STATUS SUMMARY CARD ────────────────────────────────────────────
  Widget _buildPolicyStatusSummaryCard() {
    final isDarkMode = ref.watch(themeModeProvider);

    return CyberHudFrame(
      design: CyberFrameDesign.topTabWedge,
      baseBorderColor: const Color(0xFFE9D86B),
      hoverBorderColor: const Color(0xFFE9D86B),
      ambientGlow: true,
      isInteractive: false,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConsoleRow(
                children: [
                  Icon(Icons.shield_outlined,
                      color: isDarkMode
                          ? const Color(0xFF80A416)
                          : const Color(0xFF5E7343),
                      size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'POLICY STATUS BREAKDOWN',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color(0xFFC4E320)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
                child: Text(
                  'REVIEW ALL →',
                  style: CyberTextStyles.technical(
                    fontSize: 9,
                    color: isDarkMode
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF5E7343),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPolicyStatusRow(
              '1. PENDING APPROVAL',
              '24 Policies',
              isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFB8A9C1),
              0.15,
              isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow(
              '2. APPROVED BY ADMIN',
              '20 Policies',
              isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFCDD4B2),
              0.12,
              isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow(
              '3. DEPLOYED IN OPA',
              '298 Policies',
              isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
              0.85,
              isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow('4. REJECTED / AUDITED', '8 Policies',
              const Color(0xFFD82734), 0.05, isDarkMode),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFFC4E320).withOpacity(0.12)
                    : const Color(0xFFEBECCC),
                border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF80A416)
                        : const Color(0xFFCDD4B2),
                    width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  'MANAGE ZERO-TRUST POLICIES',
                  style: CyberTextStyles.technical(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color(0xFFC4E320)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyStatusRow(String label, String count, Color color,
      double progress, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E293B))),
            Text(count,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor:
                isDarkMode ? const Color(0xFF222222) : const Color(0xFFEBECCC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── SYSTEM COMPONENT HEALTH PANEL ─────────────────────────────────────────
  Widget _buildSystemComponentHealthPanel() {
    final isDarkMode = ref.watch(themeModeProvider);

    return CyberHudFrame(
      design: CyberFrameDesign.circuitHud,
      baseBorderColor: const Color(0xFFC4E326),
      hoverBorderColor: const Color(0xFFC4E326),
      ambientGlow: true,
      isInteractive: false,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConsoleRow(
                children: [
                  Icon(Icons.hub_outlined,
                      color: isDarkMode
                          ? const Color(0xFF80A416)
                          : const Color(0xFF5E7343),
                      size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ZERO-TRUST ENGINE HEALTH',
                    style: CyberTextStyles.technical(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color(0xFF80A416)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'ALL NOMINAL',
                style: CyberTextStyles.technical(
                  fontSize: 10.5,
                  color: isDarkMode
                      ? const Color(0xFF5DD62C)
                      : const Color(0xFF08652C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _healthRowItem(
              'Zeek Network Sensor',
              '1.4k pkts/s · 1.2ms latency',
              isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF5E7343),
              isDarkMode),
          _healthRowItem(
              'PyTorch GNN Embeddings',
              '64-dim · 4.8ms inference',
              isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFB8A9C1),
              isDarkMode),
          _healthRowItem(
              'Open Policy Agent (OPA)',
              '298 Active Microsegments',
              isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416),
              isDarkMode),
          _healthRowItem(
              'RBAC Zero-Trust Enclave',
              '100% Policy Sync',
              isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFCDD4B2),
              isDarkMode),
        ],
      ),
    );
  }

  Widget _healthRowItem(
      String title, String val, Color color, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.white70 : const Color(0xFF334155))),
          Text(val,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ── QUICK ACTION BUTTON HELPER ────────────────────────────────────────────
  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final ink =
        !ref.watch(themeModeProvider) && color == const Color(0xFFC4E320)
            ? const Color(0xFF617D10)
            : color;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: CyberTextStyles.technical(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LIVE SYSTEM LOG PANEL (BOTTOM) ────────────────────────────────────────
  Widget _buildSystemLogPanel({required double height}) {
    final isDarkMode = ref.watch(themeModeProvider);

    return CyberHudFrame(
      design: CyberFrameDesign.ladderFins,
      baseBorderColor: const Color(0xFF9D8DF1),
      hoverBorderColor: const Color(0xFF9D8DF1),
      ambientGlow: true,
      isInteractive: false,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SECURITY & AUDIT EVENT LEDGER',
                style: CyberTextStyles.technical(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color(0xFF5DD62C)
                      : const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                child: Text(
                  'VIEW INCIDENTS →',
                  style: CyberTextStyles.technical(
                    fontSize: 10,
                    color: isDarkMode
                        ? const Color(0xFFA88AED)
                        : const Color(0xFF5E7343),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: _systemLogs.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Text(
                    _systemLogs[idx],
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: idx == 0 ? FontWeight.w700 : FontWeight.w500,
                      color: idx == 0
                          ? (isDarkMode
                              ? const Color(0xFF5DD62C)
                              : const Color(0xFF08652C))
                          : (isDarkMode
                              ? Colors.white60
                              : const Color(0xFF64748B)),
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
