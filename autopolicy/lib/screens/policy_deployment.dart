import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/policy.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_stat_card.dart';

class PolicyDeployment extends ConsumerWidget {
  const PolicyDeployment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final isDarkMode = ref.watch(themeModeProvider);
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
                Text(
                  'OPA POLICY PIPELINE STATUS',
                  style: CyberTextStyles.heading2.copyWith(
                    color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'REAL-TIME EDGE AGENT DEPLOYMENT STACK LOGS',
                  style: CyberTextStyles.techMutedFor(isDarkMode),
                ),
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
            _buildPipelineVisualizer(context, isDarkMode),
            const SizedBox(height: 16),

            // Split views
            Expanded(
              child: ResponsiveLayout(
                mobile: Column(
                  children: [
                    Expanded(child: _buildDeployedPoliciesCard(deployedPolicies, isDarkMode)),
                    const SizedBox(height: 16),
                    Expanded(child: _buildOpaLogsCard(opaLogs, isDarkMode)),
                  ],
                ),
                desktop: Row(
                  children: [
                    // Deployed Policies Directory list
                    Expanded(
                      flex: 4,
                      child: _buildDeployedPoliciesCard(deployedPolicies, isDarkMode),
                    ),
                    const SizedBox(width: 16),
                    // Live OPA Compiler Logs Feed
                    Expanded(
                      flex: 5,
                      child: _buildOpaLogsCard(opaLogs, isDarkMode),
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

  Widget _buildPipelineVisualizer(BuildContext context, bool isDarkMode) {
    final bool isMobile = Responsive.isMobile(context);
    final stages = [
      {'label': 'AI GEN', 'icon': Icons.psychology},
      {'label': 'COMPILE', 'icon': Icons.code},
      {'label': 'BUNDLE', 'icon': Icons.inventory_2_outlined},
      {'label': 'EDGE SYNC', 'icon': Icons.sync},
      {'label': 'ENFORCE', 'icon': Icons.shield},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2),
          width: 1.0,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPA RULES BUNDLE ENFORCEMENT PATHWAY',
            style: CyberTextStyles.technical(
              color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ).copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Divider(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), height: 1),
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
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkMode ? const Color(0xFF142416) : const Color(0xFFEBECCC),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              stage['icon'] as IconData,
                              color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stage['label'] as String,
                            style: CyberTextStyles.technical(
                              fontSize: 9.5,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast && !isMobile)
                      Container(
                        width: 24,
                        height: 1.5,
                        color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.4) : const Color(0xFFCDD4B2),
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

  Widget _buildDeployedPoliciesCard(List<SecurityPolicy> policies, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2),
          width: 1.0,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416), size: 15),
              const SizedBox(width: 6),
              Text(
                'ENFORCED ACTIVE POLICIES',
                style: CyberTextStyles.technical(
                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ).copyWith(letterSpacing: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: policies.isEmpty
                ? Center(
                    child: Text(
                      'NO ACTIVE ENFORCED POLICIES',
                      style: CyberTextStyles.technical(
                        color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: policies.length,
                    itemBuilder: (context, idx) {
                      final policy = policies[idx];
                      final timeStr = '${policy.timestamp.hour.toString().padLeft(2, '0')}:${policy.timestamp.minute.toString().padLeft(2, '0')}:${policy.timestamp.second.toString().padLeft(2, '0')}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.3) : const Color(0xFFCDD4B2),
                            width: 1.0,
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
                                    policy.deviceName.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.0,
                                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TARGET: ${policy.deviceId} | IP: ${policy.rawJsonPolicy.contains('ip_address') ? '10.128.4.X' : 'LOCAL'}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                                    ),
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
                                    color: isDarkMode
                                        ? const Color(0xFF5DD62C).withOpacity(0.15)
                                        : const Color(0xFF15803D).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF15803D),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: CyberTextStyles.technical(
                                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF15803D),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: CyberTextStyles.techMutedFor(isDarkMode).copyWith(fontSize: 8.5),
                                ),
                              ],
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

  Widget _buildOpaLogsCard(List<dynamic> logs, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2),
          width: 1.0,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416), size: 15),
              const SizedBox(width: 6),
              Text(
                'OPA EDGE RULES COMPILER LOGS',
                style: CyberTextStyles.technical(
                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ).copyWith(letterSpacing: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'LOG FEED IS EMPTY',
                      style: CyberTextStyles.technical(
                        color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, idx) {
                      final log = logs[idx];
                      final isError = log.level == 'ERROR';
                      final timeStr = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';
                      final Color levelColor = isError
                          ? const Color(0xFFDF2531)
                          : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF15803D));

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode ? const Color(0xFF181818) : const Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timestamp
                            Text(
                              '[$timeStr]',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF80A416),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Level
                            Text(
                              '${log.level}:',
                              style: CyberTextStyles.technical(
                                color: levelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Message
                            Expanded(
                              child: Text(
                                log.message.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
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
