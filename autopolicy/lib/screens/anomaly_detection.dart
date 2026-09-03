import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anomaly.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';

class AnomalyDetection extends ConsumerStatefulWidget {
  const AnomalyDetection({super.key});

  @override
  ConsumerState<AnomalyDetection> createState() => _AnomalyDetectionState();
}

class _AnomalyDetectionState extends ConsumerState<AnomalyDetection> {
  String _severityFilter = 'ALL';
  String _statusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final anomalies = securityState.anomalies;

    // Filters logic
    final filteredAnomalies = anomalies.where((anm) {
      final bool matchesSeverity = _severityFilter == 'ALL' ||
          anm.severity.toString().split('.').last.toUpperCase() == _severityFilter;
      
      final bool matchesStatus;
      if (_statusFilter == 'ALL') {
        matchesStatus = true;
      } else if (_statusFilter == 'ACTIVE') {
        matchesStatus = !anm.isMitigated;
      } else {
        matchesStatus = anm.isMitigated;
      }

      return matchesSeverity && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INCIDENT ANALYSIS FEED', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('AI-POWERED ML THREAT DETECTION ALERTS', style: CyberTextStyles.techMuted),
                  ],
                ),
                // Summary pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CyberColors.alertRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CyberColors.alertRed.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${anomalies.where((a) => !a.isMitigated).length} UNRESOLVED INCIDENTS',
                    style: CyberTextStyles.technical(color: CyberColors.alertRed, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Advanced Filters Bar
            Row(
              children: [
                // Severity Filter Dropdowns
                _buildFilterLabel('SEVERITY:'),
                const SizedBox(width: 8),
                _buildFilterButton('ALL', 'severity', _severityFilter == 'ALL'),
                _buildFilterButton('CRITICAL', 'severity', _severityFilter == 'CRITICAL'),
                _buildFilterButton('HIGH', 'severity', _severityFilter == 'HIGH'),
                
                const SizedBox(width: 24),
                
                // Status Filters
                _buildFilterLabel('STATUS:'),
                const SizedBox(width: 8),
                _buildFilterButton('ALL', 'status', _statusFilter == 'ALL'),
                _buildFilterButton('ACTIVE', 'status', _statusFilter == 'ACTIVE'),
                _buildFilterButton('MITIGATED', 'status', _statusFilter == 'MITIGATED'),
              ],
            ),
            const SizedBox(height: 16),

            // Incident Feed Lists
            Expanded(
              child: filteredAnomalies.isEmpty
                  ? GlassContainer(
                      borderColor: CyberColors.neonGreen,
                      child: Center(
                        child: Text(
                          'NO FLAGGED INCIDENTS MATCHING CRITERIA',
                          style: CyberTextStyles.techMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAnomalies.length,
                      itemBuilder: (context, idx) {
                        final anm = filteredAnomalies[idx];
                        final isCritical = anm.severity == SeverityLevel.critical;
                        final String timeStr = '${anm.timestamp.hour.toString().padLeft(2, '0')}:${anm.timestamp.minute.toString().padLeft(2, '0')}:${anm.timestamp.second.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            borderColor: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: severity + confidence + timestamp
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Severity Tag
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCritical ? CyberColors.alertRed : CyberColors.warningOrange,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            anm.severity.toString().split('.').last.toUpperCase(),
                                            style: CyberTextStyles.displayTitle(fontSize: 10, color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Confidence Index
                                        Text(
                                          'CONFIDENCE: ${(anm.confidenceScore * 100).toStringAsFixed(1)}%',
                                          style: CyberTextStyles.technical(
                                            color: CyberColors.neonGreen,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'LOG TIME: $timeStr',
                                      style: CyberTextStyles.technical(color: CyberColors.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Incident description body
                                Text(
                                  'FLAGGED THREAT: ${anm.attackType.toUpperCase()}',
                                  style: CyberTextStyles.displayTitle(fontSize: 14, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  anm.details.toUpperCase(),
                                  style: CyberTextStyles.interface(fontSize: 12, color: CyberColors.textMuted),
                                ),
                                const SizedBox(height: 16),

                                // Actions section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Target device IP/MAC info
                                    Row(
                                      children: [
                                        const Icon(Icons.router, size: 14, color: CyberColors.neonCyan),
                                        const SizedBox(width: 8),
                                        Text(
                                          'DEVICE: ${anm.deviceName.toUpperCase()} (${anm.deviceId})',
                                          style: CyberTextStyles.technical(fontSize: 10, color: CyberColors.neonCyan),
                                        ),
                                      ],
                                    ),

                                    // Action buttons
                                    Row(
                                      children: [
                                        if (!anm.isAcknowledged)
                                          TextButton(
                                            onPressed: () {
                                              ref.read(securityProvider.notifier).acknowledgeAnomaly(anm.id);
                                            },
                                            child: Text(
                                              'ACKNOWLEDGE',
                                              style: CyberTextStyles.technical(color: CyberColors.neonCyan, fontSize: 11),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        // Manual Investigate action
                                        TextButton(
                                          onPressed: () => _showInvestigateDialog(context, anm),
                                          child: Text(
                                            'DIAGNOSE',
                                            style: CyberTextStyles.technical(color: Colors.white70, fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Block/Isolate device
                                        if (!anm.isMitigated)
                                          NeonButton(
                                            text: 'Isolate Device',
                                            color: CyberColors.alertRed,
                                            onPressed: () {
                                              // Find policy and trigger OPA deploy
                                              final policy = securityState.policies.firstWhere(
                                                (p) => p.anomalyId == anm.id,
                                                orElse: () => securityState.policies.first,
                                              );
                                              ref.read(securityProvider.notifier).deployPolicy(
                                                    policy.id,
                                                    policy.rawJsonPolicy,
                                                  );
                                            },
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: CyberColors.neonGreen.withOpacity(0.08),
                                              border: Border.all(color: CyberColors.neonGreen),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.check, size: 12, color: CyberColors.neonGreen),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'QUARANTINED',
                                                  style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
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
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: CyberTextStyles.technical(color: CyberColors.textMuted, fontSize: 10),
    );
  }

  Widget _buildFilterButton(String label, String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (type == 'severity') {
            _severityFilter = label;
          } else {
            _statusFilter = label;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: isSelected ? CyberColors.panelBg : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? CyberColors.neonCyan : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: CyberTextStyles.technical(
            fontSize: 9,
            color: isSelected ? Colors.white : CyberColors.textMuted,
          ),
        ),
      ),
    );
  }

  void _showInvestigateDialog(BuildContext context, Anomaly anm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CyberColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: CyberColors.neonCyan),
          ),
          title: Text(
            'THREAT CLASSIFIER ANALYSIS: ${anm.id}',
            style: CyberTextStyles.displayTitle(fontSize: 14.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TARGET DEVICE ID: ${anm.deviceId}',
                style: CyberTextStyles.technical(color: CyberColors.neonCyan, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                'CLASSIFICATION MODEL: GNN GraphSAGE AutoEncoder Clusterer',
                style: CyberTextStyles.interface(color: CyberColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                'EXPLANATION:',
                style: CyberTextStyles.technical(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                anm.details.toUpperCase(),
                style: CyberTextStyles.interface(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                'RECOMMENDED ACTION: DEPLOY REGULATED OPA MICROSEGMENTATION RULE OR DISPATCH ON-SITE ENGINEER FOR SYSTEM INTEGRITY RE-VERIFICATION.',
                style: CyberTextStyles.technical(color: CyberColors.warningOrange, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CLOSE DIAGNOSTIC',
                style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }
}
