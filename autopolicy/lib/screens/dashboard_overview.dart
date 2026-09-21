import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/responsive.dart';
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

class _DashboardOverviewState extends ConsumerState<DashboardOverview> with SingleTickerProviderStateMixin {
  late final Timer _logTimer;
  late final AnimationController _pulseController;
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

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
    _pulseController.dispose();
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

    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final totalDevices = securityState.devices.isNotEmpty ? securityState.devices.length : 1248;
    final activeThreats = securityState.anomalies.where((anm) => !anm.isMitigated).length;
    final generatedPoliciesCount = securityState.policies.isNotEmpty ? securityState.policies.length : 342;
    final blockedAttacksCount = securityState.totalBlockedAttacks > 0 ? securityState.totalBlockedAttacks : 4892;
    final pendingApprovalsCount = securityState.policies.where((p) => p.status == PolicyStatus.pending).length;
    final int pendingCount = pendingApprovalsCount > 0 ? pendingApprovalsCount : 24;

    String headerTitle = 'AUTOPOLICY ZERO-TRUST SOC DASHBOARD';
    String headerRoleLabel = 'ROLE: ROOT ADMINISTRATOR (FULL CONTROL)';
    if (isEngineer) {
      headerTitle = 'OPERATIONAL SECURITY & INCIDENT CONSOLE';
      headerRoleLabel = 'ROLE: SECURITY ENGINEER (TRIAGE & AI POLICY)';
    } else if (isManager) {
      headerTitle = 'EXECUTIVE SECURITY POSTURE & COMPLIANCE SUMMARY';
      headerRoleLabel = 'ROLE: SECURITY MANAGER (GOVERNANCE & SLA)';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. TOP TERMINAL HEADER & QUICK ACTIONS ───────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                border: Border.all(
                  color: isDarkMode 
                      ? const Color(0xFF5DD62C).withOpacity(0.40) 
                      : const Color(0xFFCDD4B2), 
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerTitle,
                              style: CyberTextStyles.displayTitle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                              ).copyWith(letterSpacing: 1.8),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  headerRoleLabel,
                                  style: CyberTextStyles.technical(
                                    fontSize: 10,
                                    color: isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF5E7343),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'SYSTEM STATUS: ZERO-TRUST ENFORCING',
                                  style: CyberTextStyles.technical(
                                    fontSize: 10,
                                    color: isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF08652C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Quick Action Buttons directly in header
                      if (!isMobile)
                        Row(
                          children: [
                            _buildQuickActionBtn(
                              icon: Icons.pending_actions_outlined,
                              label: 'REVIEW PENDING POLICIES ($pendingCount)',
                              color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF5E7343),
                              onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
                            ),
                            const SizedBox(width: 8),
                            _BeatingCriticalBox(
                              animation: _pulseController,
                              isChip: true,
                              child: _buildQuickActionBtn(
                                icon: Icons.warning_amber_outlined,
                                label: 'VIEW CRITICAL ALERTS (${activeThreats > 0 ? activeThreats : 17})',
                                color: const Color(0xFFD82734),
                                onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickActionBtn(
                          icon: Icons.pending_actions_outlined,
                          label: 'REVIEW POLICIES ($pendingCount)',
                          color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF5E7343),
                          onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
                        ),
                        _BeatingCriticalBox(
                          animation: _pulseController,
                          isChip: true,
                          child: _buildQuickActionBtn(
                            icon: Icons.warning_amber_outlined,
                            label: 'CRITICAL ALERTS (${activeThreats > 0 ? activeThreats : 17})',
                            color: const Color(0xFFD82734),
                            onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── 2. TOP 6 STATISTICS CARDS (ROLE-TAILORED SPECIFICATION GRID) ──
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 6),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.6 : (isTablet ? 1.3 : 1.16),
              children: _buildRoleSpecificStatCards(context, isEngineer, isManager, totalDevices, activeThreats, generatedPoliciesCount, blockedAttacksCount, pendingCount),
            ),
            const SizedBox(height: 8),

            // ── 3. MAIN DASHBOARD CONTENT SPLIT (NO MAP) ─────────────────────
            if (!isMobile && !isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN (Hero Line Chart + Recent Alerts Table)
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        // 1-Hour Real-Time Traffic Line Chart
                        CyberTrafficLineChart(
                          height: 250,
                          onViewDetails: () => ref.read(navigationTabProvider.notifier).state = 1,
                        ),
                        const SizedBox(height: 8),
                        // Recent Alerts (Last 5)
                        _buildRecentAlertsTable(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // RIGHT COLUMN (Policy Status Summary + Donut Chart + Health)
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // Policy Status Summary
                        _buildPolicyStatusSummaryCard(),
                        const SizedBox(height: 8),
                        // Top Attack Types Donut Chart
                        const CyberRadialDonutChart(height: 200),
                        const SizedBox(height: 8),
                        // System Component Health Panel
                        _buildSystemComponentHealthPanel(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  // 1-Hour Real-Time Traffic Line Chart
                  CyberTrafficLineChart(
                    height: 230,
                    onViewDetails: () => ref.read(navigationTabProvider.notifier).state = 1,
                  ),
                  const SizedBox(height: 8),
                  // Recent Alerts (Last 5)
                  _buildRecentAlertsTable(),
                  const SizedBox(height: 8),
                  // Policy Status Summary
                  _buildPolicyStatusSummaryCard(),
                  const SizedBox(height: 8),
                  // Top Attack Types Donut Chart
                  const CyberRadialDonutChart(height: 200),
                  const SizedBox(height: 8),
                  // System Component Health Panel
                  _buildSystemComponentHealthPanel(),
                ],
              ),

            const SizedBox(height: 8),

            // ── 4. BOTTOM LOG & AUDIT FEED BAR ───────────────────────────────
            _buildSystemLogPanel(height: 95),

            const SizedBox(height: 8),

            // ── 5. BOTTOM SYSTEM MESSAGE FOOTER ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF8B5CF6).withOpacity(0.45) : const Color(0xFFCDD4B2), 
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PIPELINE STATUS: Zeek IDS Capture → PyTorch GNN Inference → OPA Rego Microsegmentation Active.',
                        style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '99.4% HEALTH NOMINAL',
                        style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF5E7343),
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
                      backgroundColor: isDarkMode ? const Color(0xFF202020) : const Color(0xFFEBECCC),
                      valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFCDD4B2)),
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

  // ── ROLE-SPECIFIC 6 STAT CARDS BUILDER ─────────────────────────────────────
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
          sub: '1,226 Online · 22 Offline',
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
        _BeatingCriticalBox(
          animation: _pulseController,
          child: CyberStatCard(
            title: 'ACTIVE THREATS',
            value: activeThreats > 0 ? '$activeThreats' : '17',
            sub: '5 Critical · 12 High',
            icon: Icons.gpp_maybe_outlined,
            borderColor: const Color(0xFFD82734),
            isAlert: true,
            tag: 'M06',
            onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
          ),
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
        _BeatingCriticalBox(
          animation: _pulseController,
          child: CyberStatCard(
            title: 'ACTIVE THREATS',
            value: activeThreats > 0 ? '$activeThreats' : '17',
            sub: '5 Critical · 12 High',
            icon: Icons.gpp_maybe_outlined,
            borderColor: const Color(0xFFD82734),
            isAlert: true,
            tag: 'E06',
            onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
          ),
        ),
      ];
    }

    // Default / Admin 6 Cards
    return [
      CyberStatCard(
        title: 'TOTAL IOT DEVICES',
        value: totalDevices > 1000 ? '1,248' : '$totalDevices',
        sub: '1,226 Online · 22 Offline',
        icon: Icons.router_outlined,
        borderColor: const Color(0xFFFFF9E1),
        tag: 'H17',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 6,
      ),
      CyberStatCard(
        title: 'POLICIES GENERATED',
        value: '$generatedPoliciesCount',
        sub: '$pendingCount Pending Review',
        icon: Icons.auto_awesome_outlined,
        borderColor: const Color(0xFFEBECCC),
        tag: 'H18',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
      ),
      CyberStatCard(
        title: 'POLICIES DEPLOYED',
        value: '298',
        sub: 'Active in OPA Sidecars',
        icon: Icons.shield_outlined,
        borderColor: const Color(0xFFCDD4B2),
        tag: 'H19',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 5,
      ),
      CyberStatCard(
        title: 'BLOCKED ATTACKS 24H',
        value: '$blockedAttacksCount',
        sub: '100% Ingress Quarantined',
        icon: Icons.gpp_good_outlined,
        borderColor: const Color(0xFFD4C9D8),
        tag: 'H20',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 1,
      ),
      CyberStatCard(
        title: 'SYSTEM HEALTH',
        value: '99.4%',
        sub: 'Zeek, GNN & OPA Nominal',
        icon: Icons.health_and_safety_outlined,
        borderColor: const Color(0xFFB8A9C1),
        tag: 'H21',
        onTap: () => ref.read(navigationTabProvider.notifier).state = 9,
      ),
      _BeatingCriticalBox(
        animation: _pulseController,
        child: CyberStatCard(
          title: 'ACTIVE THREATS',
          value: activeThreats > 0 ? '$activeThreats' : '17',
          sub: '5 Critical · 12 High',
          icon: Icons.gpp_maybe_outlined,
          borderColor: const Color(0xFFD82734),
          isAlert: true,
          tag: 'H22',
          onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
        ),
      ),
    ];
  }

  // ── RECENT ALERTS TABLE (LAST 5) ──────────────────────────────────────────
  Widget _buildRecentAlertsTable() {
    final isDarkMode = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        border: Border.all(
          color: isDarkMode ? const Color(0xFFD82734).withOpacity(0.35) : const Color(0xFFD82734).withOpacity(0.25), 
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, color: Color(0xFFD82734), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'RECENT THREAT ALERTS (LAST 5 INCIDENTS)',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD82734),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Severity Index Legend Chips
                  _buildSeverityLegendChip('CRITICAL', const Color(0xFFD82734), isDarkMode),
                  const SizedBox(width: 6),
                  _buildSeverityLegendChip('HIGH', const Color(0xFFE87D85), isDarkMode),
                  const SizedBox(width: 6),
                  _buildSeverityLegendChip('MEDIUM', const Color(0xFFFFF4E1), isDarkMode),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                    child: Text(
                      'ALL ANOMALIES FEED →',
                      style: CyberTextStyles.technical(
                        fontSize: 9,
                        color: isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF80A416),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 6),

          // Table Header
          Row(
            children: [
              Expanded(flex: 2, child: Text('TIMESTAMP', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : const Color(0xFF64748B)))),
              Expanded(flex: 3, child: Text('DEVICE ASSET', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : const Color(0xFF64748B)))),
              Expanded(flex: 4, child: Text('ATTACK VECTOR', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : const Color(0xFF64748B)))),
              Expanded(flex: 2, child: Text('SEVERITY', style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : const Color(0xFF64748B)))),
              Expanded(flex: 2, child: Text('ACTION', textAlign: TextAlign.right, style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : const Color(0xFF64748B)))),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), height: 1),

          // Table Rows
          ..._recentAlerts.map((alert) {
            final String sev = alert['severity'] as String;
            Color badgeBg;
            Color badgeBorder;
            Color badgeTextColor = Colors.white;

            if (sev == 'CRITICAL') {
              badgeBg = const Color(0xFFD82734);
              badgeBorder = const Color(0xFFD82734);
            } else if (sev == 'HIGH') {
              badgeBg = const Color(0xFFE87D85);
              badgeBorder = const Color(0xFFE87D85);
            } else {
              badgeBg = const Color(0xFFFFF4E1);
              badgeBorder = const Color(0xFFE6D6B8);
              badgeTextColor = const Color(0xFF0F172A);
            }

            final badgeContainer = Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: badgeBorder, width: 0.8),
              ),
              child: Text(
                sev,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.5, 
                  fontWeight: FontWeight.bold, 
                  color: badgeTextColor,
                ),
              ),
            );

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDarkMode ? const Color(0xFF181818) : const Color(0xFFF1F5F9), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      alert['time'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600, 
                        color: isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF80A416),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['device'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12.5, 
                            fontWeight: FontWeight.w700, 
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          alert['ip'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11, 
                            color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      alert['attack'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        fontWeight: FontWeight.w500, 
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: sev == 'CRITICAL'
                          ? _BeatingCriticalBox(
                              animation: _pulseController,
                              isChip: true,
                              child: badgeContainer,
                            )
                          : badgeContainer,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF8B5CF6).withOpacity(0.20) : const Color(0xFFB1A9DA).withOpacity(0.30),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFFA88AED) : const Color(0xFF80A416), 
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'TRIAGE',
                            style: CyberTextStyles.technical(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? const Color(0xFFA88AED) : const Color(0xFF5E7343),
                            ),
                          ),
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

    if (label == 'CRITICAL') {
      return _BeatingCriticalBox(
        animation: _pulseController,
        isChip: true,
        child: chipWidget,
      );
    }
    return chipWidget;
  }

  // ── POLICY STATUS SUMMARY CARD ────────────────────────────────────────────
  Widget _buildPolicyStatusSummaryCard() {
    final isDarkMode = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        border: Border.all(
          color: isDarkMode ? const Color(0xFFC4E320).withOpacity(0.35) : const Color(0xFFCDD4B2), 
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFF5E7343), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'POLICY STATUS BREAKDOWN',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF0F172A),
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
                    color: isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF5E7343),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildPolicyStatusRow('1. PENDING APPROVAL', '24 Policies', isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFB8A9C1), 0.15, isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow('2. APPROVED BY ADMIN', '20 Policies', isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFCDD4B2), 0.12, isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow('3. DEPLOYED IN OPA', '298 Policies', isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416), 0.85, isDarkMode),
          const SizedBox(height: 8),
          _buildPolicyStatusRow('4. REJECTED / AUDITED', '8 Policies', const Color(0xFFD82734), 0.05, isDarkMode),

          const SizedBox(height: 12),
          InkWell(
            onTap: () => ref.read(navigationTabProvider.notifier).state = 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFFC4E320).withOpacity(0.12) : const Color(0xFFEBECCC),
                border: Border.all(color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFFCDD4B2), width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  'MANAGE ZERO-TRUST POLICIES',
                  style: CyberTextStyles.technical(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyStatusRow(String label, String count, Color color, double progress, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF1E293B))),
            Text(count, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: isDarkMode ? const Color(0xFF222222) : const Color(0xFFEBECCC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── SYSTEM COMPONENT HEALTH PANEL ─────────────────────────────────────────
  Widget _buildSystemComponentHealthPanel() {
    final isDarkMode = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        border: Border.all(color: isDarkMode ? const Color(0xFF80A416).withOpacity(0.35) : const Color(0xFFCDD4B2), width: 1.0),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.hub_outlined, color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFF5E7343), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ZERO-TRUST ENGINE HEALTH',
                    style: CyberTextStyles.technical(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'ALL NOMINAL',
                style: CyberTextStyles.technical(
                  fontSize: 10.5,
                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF08652C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _healthRowItem('Zeek Network Sensor', '1.4k pkts/s · 1.2ms latency', isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF5E7343), isDarkMode),
          _healthRowItem('PyTorch GNN Embeddings', '64-dim · 4.8ms inference', isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFB8A9C1), isDarkMode),
          _healthRowItem('Open Policy Agent (OPA)', '298 Active Microsegments', isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF80A416), isDarkMode),
          _healthRowItem('RBAC Zero-Trust Enclave', '100% Policy Sync', isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFCDD4B2), isDarkMode),
        ],
      ),
    );
  }

  Widget _healthRowItem(String title, String val, Color color, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white70 : const Color(0xFF334155))),
          Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.7), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: CyberTextStyles.technical(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
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

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.35) : const Color(0xFFCDD4B2), 
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SECURITY & AUDIT EVENT LEDGER',
                style: CyberTextStyles.technical(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => ref.read(navigationTabProvider.notifier).state = 2,
                child: Text(
                  'VIEW INCIDENTS →',
                  style: CyberTextStyles.technical(
                    fontSize: 10,
                    color: isDarkMode ? const Color(0xFFA88AED) : const Color(0xFF5E7343),
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
                          ? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF08652C)) 
                          : (isDarkMode ? Colors.white60 : const Color(0xFF64748B)),
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

class _BeatingCriticalBox extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool isChip;

  const _BeatingCriticalBox({
    required this.child,
    required this.animation,
    this.isChip = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final scale = 1.0 + (isChip ? 0.035 * t : 0.02 * t);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isChip ? 3 : 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD82734).withOpacity(isChip ? 0.35 + 0.35 * t : 0.30 + 0.35 * t),
                  blurRadius: isChip ? 4 + 6 * t : 8 + 10 * t,
                  spreadRadius: isChip ? 0.5 + 1.2 * t : 1.0 + 2.5 * t,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}
