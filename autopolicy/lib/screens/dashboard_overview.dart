import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_gauge.dart';
import '../widgets/glass_container.dart';
import '../widgets/holographic_globe.dart';
import '../models/anomaly.dart';

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    final bool isDarkMode = ref.watch(themeModeProvider);

    final totalDevices = securityState.devices.length;
    final activeThreats = securityState.anomalies.where((anm) => !anm.isMitigated).length;
    final generatedPoliciesCount = securityState.policies.length;
    final blockedAttacksCount = securityState.totalBlockedAttacks;

    // Stat Cards configuration
    final List<Map<String, dynamic>> statCards = [
      {
        'title': 'TOTAL IOT DEVICES',
        'value': '$totalDevices',
        'sub': 'Telemetry active',
        'icon': Icons.router_outlined,
        'color': CyberColors.neonCyan
      },
      {
        'title': 'ACTIVE THREATS',
        'value': '$activeThreats',
        'sub': 'ML flagged anomalous',
        'icon': Icons.gpp_maybe_outlined,
        'color': activeThreats > 0 ? CyberColors.alertRed : CyberColors.neonGreen
      },
      {
        'title': 'POLICIES DEPLOYED',
        'value': '$generatedPoliciesCount',
        'sub': 'OPA microsegment rule',
        'icon': Icons.rule_folder_outlined,
        'color': CyberColors.neonCyan
      },
      {
        'title': 'BLOCKED ATTACKS',
        'value': '$blockedAttacksCount',
        'sub': 'Zero-Trust quarantined',
        'icon': Icons.gpp_good_outlined,
        'color': CyberColors.neonGreen
      },
    ];

    // Build the stats grid dynamically
    final Widget statsGrid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 3.0 : 1.7,
      ),
      itemCount: statCards.length,
      itemBuilder: (context, idx) {
        final card = statCards[idx];
        final Color themeColor = card['color'] as Color;

        return GlassContainer(
          borderColor: themeColor,
          child: Row(
            children: [
              Icon(card['icon'] as IconData, color: themeColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card['title'] as String,
                      style: CyberTextStyles.techMuted.copyWith(
                        fontSize: 10,
                        color: isDarkMode ? CyberColors.textMuted : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card['value'] as String,
                      style: CyberTextStyles.displayTitle(
                        fontSize: 20,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card['sub'] as String,
                      style: CyberTextStyles.techMuted.copyWith(
                        fontSize: 9,
                        color: isDarkMode ? CyberColors.textMuted : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    // Layout configuration
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SECURITY OPERATIONS CENTER', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('REAL-TIME SEC-ML TELESCOPE OVERVIEW', style: CyberTextStyles.techMuted),
                  ],
                ),
                if (!isMobile)
                  // ML accuracy stat banner
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderColor: CyberColors.neonGreen,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.psychology, color: CyberColors.neonGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'GNN MODEL ACCURACY: ${securityState.mlModelAccuracy.toStringAsFixed(1)}%',
                          style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // stats cards
            statsGrid,
            const SizedBox(height: 16),

            // Split analytics and globe views
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildHealthGaugeCard(securityState.networkHealth, isDarkMode),
                  const SizedBox(height: 16),
                  _buildGlobeCard(isDarkMode),
                  const SizedBox(height: 16),
                  _buildRecentThreatFeed(securityState.anomalies, isDarkMode),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel: Network health gauge & alerts
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildHealthGaugeCard(securityState.networkHealth, isDarkMode),
                        const SizedBox(height: 16),
                        _buildRecentThreatFeed(securityState.anomalies, isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right panel: 3D Holographic spinning globe
                  Expanded(
                    flex: 2,
                    child: _buildGlobeCard(isDarkMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthGaugeCard(double health, bool isDarkMode) {
    final Color healthColor = health > 80 ? CyberColors.neonGreen : (health > 50 ? CyberColors.warningOrange : CyberColors.alertRed);
    return GlassContainer(
      borderColor: healthColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NETWORK FLEET SECURITY STATUS',
            style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CyberGauge(
                value: health,
                label: 'System Health',
                color: health > 80 ? CyberColors.neonGreen : (health > 50 ? CyberColors.warningOrange : CyberColors.alertRed),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricLabel('GATEWAY CLUSTERS', '100% ONLINE', CyberColors.neonCyan, isDarkMode),
                      const SizedBox(height: 8),
                      _buildMetricLabel('FIREWALL AUDITING', 'ACTIVE', CyberColors.neonGreen, isDarkMode),
                      const SizedBox(height: 8),
                      _buildMetricLabel('GNN COMPLIANCE', 'SHIELD LOADED', CyberColors.neonGreen, isDarkMode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLabel(String name, String status, Color color, bool isDarkMode) {
    final Color displayColor = isDarkMode 
        ? color 
        : (color == CyberColors.neonCyan 
            ? const Color(0xFF007A87) 
            : (color == CyberColors.neonGreen ? const Color(0xFF00875A) : color));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: CyberTextStyles.techMuted.copyWith(fontSize: 9, color: isDarkMode ? CyberColors.textMuted : Colors.black)),
        const SizedBox(height: 2),
        Text(status, style: CyberTextStyles.technical(color: displayColor, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGlobeCard(bool isDarkMode) {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        children: [
          Text(
            'GLOBAL SOC PACKET INGRESS MAP',
            style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 16),
          const Center(
            child: HolographicGlobe(size: 240),
          ),
          const SizedBox(height: 16),
          Text(
            'PROJECTION SYSTEM ACTIVE: TAP AND DRAG TO YAW/ROTATE',
            style: CyberTextStyles.techMuted.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentThreatFeed(List<Anomaly> anomalies, bool isDarkMode) {
    final recent = anomalies.take(4).toList();
    final bool hasUnresolvedCritical = anomalies.any((a) => !a.isMitigated && a.severity == SeverityLevel.critical);
    final bool hasUnresolvedWarning = anomalies.any((a) => !a.isMitigated && a.severity == SeverityLevel.high);
    final Color threatColor = hasUnresolvedCritical 
        ? CyberColors.alertRed 
        : (hasUnresolvedWarning ? CyberColors.warningOrange : CyberColors.neonGreen);

    return GlassContainer(
      borderColor: threatColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REAL-TIME INCIDENT RESPONSE LOGS',
            style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('NO SYSTEM VIOLATIONS CURRENTLY FLAGGED', style: CyberTextStyles.techMuted),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, idx) {
                final anm = recent[idx];
                final isCritical = anm.severity == SeverityLevel.critical;

                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${anm.attackType.toUpperCase()} ON ${anm.deviceName.toUpperCase()}',
                              style: CyberTextStyles.technical(
                                fontSize: 11,
                                color: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              anm.details.toUpperCase(),
                              style: CyberTextStyles.interface(fontSize: 10, color: isDarkMode ? CyberColors.textMuted : const Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: anm.isMitigated ? CyberColors.neonGreen.withOpacity(0.1) : CyberColors.alertRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          anm.isMitigated ? 'MITIGATED' : 'ACTIVE',
                          style: CyberTextStyles.technical(
                            fontSize: 9,
                            color: anm.isMitigated ? CyberColors.neonGreen : CyberColors.alertRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
