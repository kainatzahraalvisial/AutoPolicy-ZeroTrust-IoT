import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/policy.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/cyber_stat_card.dart';

class PolicyDeployment extends ConsumerWidget {
  const PolicyDeployment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final deployedPolicies = securityState.policies
        .where((p) => p.status == PolicyStatus.deployed)
        .toList();
    final opaLogs = securityState.opaLogs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OPA POLICY PIPELINE STATUS', style: CyberTextStyles.heading2),
                const SizedBox(height: 4),
                Text('REAL-TIME EDGE AGENT DEPLOYMENT STACK LOGS', style: CyberTextStyles.techMuted),
              ],
            ),
            const SizedBox(height: 14),

            // Top Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: CyberStatCard(
                    title: 'DEPLOYED BUNDLES',
                    value: '${deployedPolicies.length}',
                    sub: 'Active Rego Rules',
                    borderColor: const Color(0xFFFFE997), // 1. Yellow (#FFE997)
                    tag: 'H17',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'ENVOY SIDECARS',
                    value: '12',
                    sub: 'Edge Enforcement Gateways',
                    borderColor: const Color(0xFFA88AED), // 2. Indigo Purple (#A88AED)
                    tag: 'H18',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'PIPELINE HEALTH',
                    value: '100%',
                    sub: 'Sync Channel Active',
                    borderColor: const Color(0xFFC4E320), // 3. Bright Light Green (#C4E320)
                    tag: 'H19',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'EVAL LATENCY',
                    value: '0.8ms',
                    sub: 'Sub-Millisecond Speed',
                    borderColor: const Color(0xFF80A416), // 4. Olive Green (#80A416)
                    tag: 'H20',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pipeline Stage Visualizer
            _buildPipelineVisualizer(context),
            const SizedBox(height: 16),

            // Split views
            Expanded(
              child: ResponsiveLayout(
                mobile: Column(
                  children: [
                    Expanded(child: _buildDeployedPoliciesCard(deployedPolicies)),
                    const SizedBox(height: 16),
                    Expanded(child: _buildOpaLogsCard(opaLogs)),
                  ],
                ),
                desktop: Row(
                  children: [
                    // Deployed Policies Directory list
                    Expanded(
                      flex: 4,
                      child: _buildDeployedPoliciesCard(deployedPolicies),
                    ),
                    const SizedBox(width: 16),
                    // Live OPA Compiler Logs Feed
                    Expanded(
                      flex: 5,
                      child: _buildOpaLogsCard(opaLogs),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineVisualizer(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final stages = [
      {'label': 'AI GEN', 'icon': Icons.psychology},
      {'label': 'COMPILE', 'icon': Icons.code},
      {'label': 'BUNDLE', 'icon': Icons.inventory_2_outlined},
      {'label': 'EDGE SYNC', 'icon': Icons.sync},
      {'label': 'ENFORCE', 'icon': Icons.shield},
    ];

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPA RULES BUNDLE ENFORCEMENT PATHWAY', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stages.asMap().entries.map((entry) {
              final int idx = entry.key;
              final stage = entry.value;
              final bool isLast = idx == stages.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CyberColors.panelBg,
                              border: Border.all(color: CyberColors.neonCyan),
                            ),
                            child: Icon(stage['icon'] as IconData, color: CyberColors.neonGreen, size: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stage['label'] as String,
                            style: CyberTextStyles.technical(fontSize: 8.5, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast && !isMobile)
                      Container(
                        width: 24,
                        height: 1,
                        color: CyberColors.neonCyan.withOpacity(0.4),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeployedPoliciesCard(List<SecurityPolicy> policies) {
    return GlassContainer(
      borderColor: CyberColors.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ENFORCED ACTIVE POLICIES', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 8),
          Expanded(
            child: policies.isEmpty
                ? Center(child: Text('NO ACTIVE ENFORCED POLICIES', style: CyberTextStyles.techMuted))
                : ListView.builder(
                    itemCount: policies.length,
                    itemBuilder: (context, idx) {
                      final policy = policies[idx];
                      final timeStr = '${policy.timestamp.hour.toString().padLeft(2, '0')}:${policy.timestamp.minute.toString().padLeft(2, '0')}:${policy.timestamp.second.toString().padLeft(2, '0')}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 6.0,
                          borderColor: CyberColors.neonGreen,
                          showHUDCorners: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    policy.deviceName.toUpperCase(),
                                    style: CyberTextStyles.technical(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TARGET: ${policy.deviceId} | IP: ${policy.rawJsonPolicy.contains('ip_address') ? '10.128.4.X' : 'LOCAL'}',
                                    style: CyberTextStyles.interface(fontSize: 10, color: CyberColors.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CyberColors.neonGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: CyberTextStyles.techMuted.copyWith(fontSize: 8.0),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildOpaLogsCard(List<dynamic> logs) {
    return GlassContainer(
      borderColor: CyberColors.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPA EDGE RULES COMPILER LOGS', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
          const Divider(color: CyberColors.borderNeonGreen),
          const SizedBox(height: 8),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text('LOG FEED IS EMPTY', style: CyberTextStyles.techMuted))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, idx) {
                      final log = logs[idx];
                      final isError = log.level == 'ERROR';
                      final timeStr = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white12)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timestamp
                            Text(
                              '[$timeStr]',
                              style: CyberTextStyles.techMuted.copyWith(fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            // Level
                            Text(
                              '${log.level}:',
                              style: CyberTextStyles.technical(
                                color: isError ? CyberColors.alertRed : CyberColors.neonGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Message
                            Expanded(
                              child: Text(
                                log.message.toUpperCase(),
                                style: CyberTextStyles.technical(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
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
