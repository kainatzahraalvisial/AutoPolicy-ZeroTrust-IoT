import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_gauge.dart';
import '../widgets/cyber_hud_frame.dart';
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

    // Build the stats grid with 4 distinct cyber hacking frame designs
    final Widget statsGrid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isMobile ? 2.8 : 1.5,
      ),
      itemCount: statCards.length,
      itemBuilder: (context, idx) {
        final card = statCards[idx];
        final Color themeColor = card['color'] as Color;

        // Distinct frame design for every single card
        final CyberFrameDesign design = switch (idx) {
          0 => CyberFrameDesign.topTabWedge,   // Variant 1: Glowing top tab + corner wedge
          1 => CyberFrameDesign.hazardStripes, // Variant 2: Hazard warning stripes for threat
          2 => CyberFrameDesign.ladderFins,    // Variant 3: Barcode heat ladder fins
          _ => CyberFrameDesign.techDots,      // Variant 4: Vertical tech dot array
        };

        return CyberHudFrame(
          design: design,
          baseBorderColor: themeColor.withValues(alpha: 0.65),
          hoverBorderColor: const Color(0xFFC5C764), // Palette yellow hover
          surfaceColor: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          showGrid: true,
          child: Row(
            children: [
              Icon(card['icon'] as IconData, color: themeColor, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card['title'] as String,
                      style: CyberTextStyles.techMuted.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? CyberColors.textMuted : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card['value'] as String,
                      style: CyberTextStyles.displayTitle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card['sub'] as String,
                      style: CyberTextStyles.techMuted.copyWith(
                        fontSize: 12.0,
                        color: isDarkMode ? CyberColors.textMuted : Colors.black87,
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
                    Text('SECURITY OPERATIONS CENTER', style: CyberTextStyles.heading2.copyWith(fontSize: 26, letterSpacing: 1.0)),
                    const SizedBox(height: 6),
                    Text('REAL-TIME SEC-ML TELESCOPE OVERVIEW', style: CyberTextStyles.techMuted.copyWith(fontSize: 13.5)),
                  ],
                ),
                if (!isMobile)
                  // ML accuracy stat banner with stealth hex
                  CyberHudFrame(
                    design: CyberFrameDesign.stealthHex,
                    baseBorderColor: CyberColors.neonGreen.withValues(alpha: 0.65),
                    hoverBorderColor: const Color(0xFFC5C764),
                    surfaceColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.psychology, color: CyberColors.neonGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'GNN MODEL ACCURACY: ${securityState.mlModelAccuracy.toStringAsFixed(1)}%',
                          style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 13, fontWeight: FontWeight.bold),
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
    return CyberHudFrame(
      design: CyberFrameDesign.cornerPlate,
      baseBorderColor: healthColor.withValues(alpha: 0.65),
      hoverBorderColor: const Color(0xFFC5C764),
      surfaceColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      showGrid: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NETWORK FLEET SECURITY STATUS',
                style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: healthColor, width: 0.8),
                ),
                child: Text(
                  'SYSTEM::LIVE',
                  style: CyberTextStyles.technical(fontSize: 9.5, color: healthColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
                size: 135.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricLabel('GATEWAY CLUSTERS', '100% ONLINE', CyberColors.neonCyan, isDarkMode),
                      const SizedBox(height: 10),
                      _buildMetricLabel('FIREWALL AUDITING', 'ACTIVE', CyberColors.neonGreen, isDarkMode),
                      const SizedBox(height: 10),
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
        Text(name, style: CyberTextStyles.techMuted.copyWith(fontSize: 12, color: isDarkMode ? CyberColors.textMuted : Colors.black87)),
        const SizedBox(height: 3),
        Text(status, style: CyberTextStyles.technical(color: displayColor, fontSize: 13.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGlobeCard(bool isDarkMode) {
    return CyberHudFrame(
      design: CyberFrameDesign.reticleCut,
      baseBorderColor: CyberColors.neonCyan.withValues(alpha: 0.65),
      hoverBorderColor: const Color(0xFFC5C764),
      surfaceColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      showGrid: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GLOBAL SOC PACKET INGRESS MAP',
                style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.radar, color: CyberColors.neonCyan, size: 18),
            ],
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 16),
          const Center(
            child: HolographicGlobe(size: 240),
          ),
          const SizedBox(height: 16),
          Text(
            'PROJECTION SYSTEM ACTIVE: TAP AND DRAG TO YAW/ROTATE',
            style: CyberTextStyles.techMuted.copyWith(fontSize: 11.5),
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

    return CyberHudFrame(
      design: CyberFrameDesign.tacticalBrackets,
      baseBorderColor: threatColor.withValues(alpha: 0.65),
      hoverBorderColor: const Color(0xFFC5C764),
      surfaceColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      showGrid: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REAL-TIME INCIDENT RESPONSE LOGS',
                style: CyberTextStyles.technical(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: threatColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: threatColor, width: 0.8),
                ),
                child: Text(
                  'TELEMETRY::ONLINE',
                  style: CyberTextStyles.technical(fontSize: 9.5, color: threatColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('NO SYSTEM VIOLATIONS CURRENTLY FLAGGED', style: CyberTextStyles.techMuted.copyWith(fontSize: 13)),
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
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF141414) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                        width: 4.0,
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
                                fontSize: 13.5,
                                color: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              anm.details.toUpperCase(),
                              style: CyberTextStyles.interface(fontSize: 12.0, color: isDarkMode ? CyberColors.textMuted : const Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: anm.isMitigated ? CyberColors.neonGreen.withValues(alpha: 0.12) : CyberColors.alertRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          anm.isMitigated ? 'MITIGATED' : 'ACTIVE',
                          style: CyberTextStyles.technical(
                            fontSize: 11.0,
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
